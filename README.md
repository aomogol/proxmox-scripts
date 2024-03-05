# Proxmox  Scripts

Proxmox kullanırken işime yarayan çeşitli scriptker.

Proxmox doesn't have virt-customize installed, so just did a quick  

```bash
apt install libguestfs-tools -y
```

```bash

 ```

## Ubuntu Server 23.10 LTS (Mantic) daily builds

```bash
    wget https://cloud-images.ubuntu.com/mantic/current/mantic-server-cloudimg-amd64.img
 ```

## Ubuntu Server 24.04 LTS (Noble Numbat) daily build

```bash
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

## Ubuntu 20.04 cloudimg

```bash
    wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
```

## Debian (12)

```bash
    wget "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
```

## Debian (13)

```bash
    wget "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"   
```

The following links/tutorials were used to help develop this example.

[https://registry.terraform.io/modules/sdhibit/cloud-init-vm/proxmox/latest/examples/ubuntu_single_vm]

[https://pawa.lt/posts/2019/07/automating-k3s-deployment-on-proxmox/]

[https://forum.proxmox.com/threads/installing-virt-customize-ok.78572/]

## Kontrol edilecekler

virt-builder xxxxx --firstboot-command 'localectl set-keymap uk'
