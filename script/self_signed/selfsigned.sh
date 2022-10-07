#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage:       selfsigned.sh
#/ Version:     1.0
#/ Description: Script de génération automatique de certificat
#/ Examples:
#/   selfsigned.sh

#/
#/ Options:
#/   -h|--help              : Display this help message
#/   -g|--generate-rootca : regenerate root ca, if present clean it
#/   -v|--verbose : verbose mode default: false




function usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }

#######################################################
## LOGGING FRAMEWORK
readonly NORMAL="\\e[0m"
readonly RED="\\e[1;31m"
readonly BOLD="\\e[1m"
readonly YELLOW="\\e[1;33m"
readonly GREEN="\\e[32m"
readonly DIM="\\e[2m"
LOG_FILE="/tmp/$(basename "$0").log"; readonly LOG_FILE
function log() {
  ( flock -n 200
    color="$1"; level="$2"; message="$3"
    printf "${color}%-9s %s\\e[m\\n" "[${level}]" "$message" | tee -a "$LOG_FILE" >&2 
  ) 200>"/var/lock/.$(basename "$0").log.lock"
}
function debug() { if [ "$verbose" = true ]; then log "$DIM"    "DEBUG  "   "$*"; fi }
function info()  { log "$NORMAL" "INFO   " "$*"; }
function important()  { log "$YELLOW" "IMPORTANT   " "$*"; }
function warn()  { log "$YELLOW" "WARNING" "$*"; }
function error() { log "$RED"    "ERROR  " "$*"; }
function fatal() { log "$RED"    "FATAL  " "$*"; exit 1 ; }
function source_defs {
    resource=$1
    if [ -f "$resource" ]; then
        # shellcheck source=_functions.sh
        # shellcheck disable=SC1091
        source "$resource"
    else
        # shellcheck source=_functions.sh
        # shellcheck disable=SC1091
        source "${0%/*}/.irun-resources/$resource"
    fi
}

#######################################################

function cleanup() {
    # Remove temporary files
    # Restart services
    # ...
    return
}

function check_prerequisites() {
    if ! command -v openssl > /dev/null; then
        echo "Missing openssl: install it "
        return
    fi
}

function cleaning_files() {
  local files; files="$1"
  if [[ -f "${files}" ]]; then
    debug "${files} exists."
    info "cleaning..${files}"
    rm -f "${files}"
  else
    info "${files} doesn't exist no need clean"
  fi
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    # Parse command line arguments
    # All entry parameters quand be used globally
    POSITIONAL=()
    verbose=false
    generate_root_ca=false
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -h|--help)
            usage
            ;;
            -v|--verbose)
            declare -r verbose=true
            shift
            ;;
            -g|--generate-rootca)
            declare -r generate_root_ca=true
            shift
            ;;
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    source_defs conf/_conf.sh
    check_prerequisites
    if [ "${generate_root_ca}" = "true" ]; then
      cleaning_files "${ROOT_CA_KEY}"
      cleaning_files "${ROOT_CA_CRT}"
      openssl genrsa -out "${ROOT_CA_KEY}" 4096
      openssl req -x509 -new -nodes -key "${ROOT_CA_KEY}" -sha256 -days 1024 -out "${ROOT_CA_CRT}"
      openssl genrsa -out "${LOCAL_KEY}"
    fi
    openssl genrsa -out "${LOCAL_KEY}"
    openssl req -config "${CERTIFICATE_PATH}/local.cnf" -new -key "${LOCAL_KEY}" -out "${LOCAL_CSR}"
    openssl x509 -req -in "${LOCAL_CSR}" \
    -CA "${ROOT_CA_CRT}" -CAkey "${ROOT_CA_KEY}" -CAcreateserial \
    -out "${LOCAL_CRT}" -extfile "${CERTIFICATE_PATH}/local.fr.v3.ext" -days 365 -sha256
fi