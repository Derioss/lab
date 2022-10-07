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
