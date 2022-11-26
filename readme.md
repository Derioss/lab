# gitlab
**important** : On est sur les "nouvelles synthaxes" d'ansible, les versions < 2.10 sont compatibles cependant j'ai déja vu des effets de bords.

## First

Generate self signed certificate for traefik

cd script/self_signed

il y a un help : selfsigned.sh -v

## Hyperviseur

### virtualbox

bon voila

### kvm

#### Install

```
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
## check if active
sudo systemctl is-active libvirtd
## Add you user and tune for use virt-manager with your's user
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
newgrp libvirt
sudo systemctl restart libvirtd.service
## enjoy
virt-manager
```

## Vm prérequisites

tester sur debian11 au moins 4G de ram, tester avec 2vcpu (j'en use 12 merci le ryzen 5950X )
sudo nécessaire

**note** : 

## Todo

* Tester si le ssh est bien fonctionnel sur gitlab
```
    ports:
      - '{{ansible_default_ipv4.address}}:22:22'
```
* Mise en place du role ansible runner

# OkD (openshit) version 4.11


Une grosse partie de ce taff revient à un de mes collegues de travail.

## Mise en place d'OKD (work in progress)

>- De plus, le repertoire d'install contient des fichier cachés qui contiennent les certificats donc ne pas oublier de tout clean avant chaque tentative d'install.

>- Les certificats sont valables 24 heures ! il faut faire absolument toute l'installation dans les 24 heures.

```
sudo timedatectl set-timezone Europe/Paris
sudo hostnamectl set-hostname mail.linuxize.com
```

### Source

[doc officielle](https://docs.okd.io/4.11/welcome/index.html)
[guide sur la 4.5](https://itnext.io/guide-installing-an-okd-4-5-cluster-508a2631cbee)

Dans la doc, il est partit sur pfsense, on est partit sur du bind.

### "Archi"

La stack est composé d'un 1 vm bootsrap, 3 master (control plane) et 2 node d'execution. (4 vcpu, 120 G, 16 giga de ram)
(sandbox-okd-boostrap, sandbox-okd-master[1:3], sandbox-okd-services, sandbox-okd-node[1:2])


Elle nécessite un proxy (haproxy), un serveur web (httpd) dont le role est de fournir les fichiers gérer par ignition (système de provisionning de redhat), du dns avec le service named (bind9).
Sur le POc c'est installé sur la vm de service ce n'est pas "mandatory"



### Modification par rapport au guide.

#### Provisionning

Il faut prendre les dernières versions de fedoracoreos [ici](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable&arch=x86_64), ce qui nous intéresse c'est les "bare métal"

Ce qui donne (après avoir gérer le fichier ignition)

```
cd /var/www/html/okd4/
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221030.3.0/x86_64/fedora-coreos-36.20221030.3.0-metal.x86_64.raw.xz
sudo wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221030.3.0/x86_64/fedora-coreos-36.20221030.3.0-metal.x86_64.raw.xz.sig
sudo mv fedora-coreos-36.20221030.3.0-metal.x86_64.raw.xz fcos.raw.xz
sudo mv fedora-coreos-36.20221030.3.0-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
sudo chown -R apache: /var/www/html/
sudo chmod -R 755 /var/www/html/
```

Sur le guide, il provisionne les vm au premier boot, c'est une solution.

[guide sur ignition](https://hackmd.io/@yujungcheng/Hyik85Whq)

L'autre solution, c'est de laisser boot la vm.

```
# changer la locale
localectl set-keymap fr # c'est temporaire, et au stade de l'install ne semble pas bloquant.
# Lancer le provisionning
sudo coreos-installer install --insecure-ignition --ignition-url http://socket_apache/okd4/boostrap.ign /dev/sda
## Je note qu'il est tjrs possible de relancer l'ignition sur une vm provisionné tant qu'elle n'est pas reboot.
```

#### Installation de openshift

Après, avoir lancé `openshift-install --dir=install_dir/ wait-for bootstrap-complete --log-level=info`

On pourra avoir l'état d'avancement sur la vm bootstrap

```
journalctl -b -f  -u bootkube.service
```

Je note qu'il y a de forte probabilité que le démarrage de l'etcd (merde).

Je rappelle que c'est podman qui démarre un pod etcl sur crio, pod qui provisionne les containers.

Donc en cas, de problème, il supprimer le pod sur podman (pas crio)

```
sudo podman ps -a
```

Une fois l'install terminé

```
 sudo sed '/ sandbox-okd-bootstrap /s/^/#/' /etc/haproxy/haproxy.cfg
```
