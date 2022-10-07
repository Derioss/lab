#!/usr/bin/env bash
CERTIFICATE_PATH="files"
ROOT_CA_KEY="${CERTIFICATE_PATH}/rootCA.key"
ROOT_CA_CRT="${CERTIFICATE_PATH}/rootCA.crt"
TRAEFIK_DEST_CERT="../../roles/traefik/files/etc/certs/"
LOCAL_KEY="${TRAEFIK_DEST_CERT}/local.fr.key"
LOCAL_CRT="${TRAEFIK_DEST_CERT}/local.fr.crt"
LOCAL_CSR="${TRAEFIK_DEST_CERT}/local.fr.csr"
