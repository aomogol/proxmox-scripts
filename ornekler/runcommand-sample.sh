#!/usr/bin/env bash

#sudo virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent

# not quite working yet. skip this and continue
#sudo virt-customize -a focal-server-cloudimg-amd64.img --run-command 'useradd austin'
#sudo virt-customize -a focal-server-cloudimg-amd64.img --run-command 'mkdir -p /home/austin/.ssh'
#sudo virt-customize -a focal-server-cloudimg-amd64.img --ssh-inject austin:file:/home/austin/.ssh/id_rsa.pub
#sudo virt-customize -a focal-server-cloudimg-amd64.img --run-command 'chown -R austin:austin /home/austin'

#sudo qm set 999 --sshkey ~/.ssh/id_rsa.pub
#sudo qm set 999 --ipconfig0 ip=10.98.1.96/24,gw=10.98.1.1

# Use mkpasswd -m SHA-512 to create a password for the usermod -p command,
# ensure to escape any $ chars to avoid variable substitution:

#virt-customize -a jammy-server-cloudimg-amd64.img –run-command ‘useradd -m viscous -s /bin/bash’
#virt-customize -a jammy-server-cloudimg-amd64.img –run-command ‘usermod -aG adm,sudo,dialout,cdrom,floppy,audio,dip,video,plugdev,netdev,lxd viscous’
#virt-customize -a jammy-server-cloudimg-amd64.img –run-command “usermod -p ‘<ENCRYPTED PASSWORD HERE WITH \ ESCAPED $ CHARS' viscous"
#virt-customize -a jammy-server-cloudimg-amd64.img –run-command 'mkdir -p /home/viscous/.ssh'
#virt-customize -a jammy-server-cloudimg-amd64.img –ssh-inject viscous:file:/root/id_rsa.pub
#virt-customize -a jammy-server-cloudimg-amd64.img –run-command 'chown -R viscous. /home/viscous'


#!/usr/bin/env bash
create_clone(){
qm clone 9000 999 –name test-clone-cloud-init
qm set 999 –sshkey ~/.ssh/id_rsa.pub
qm set 999 –ipconfig0 ip=6.6.6.25/24,gw=6.6.6.1
qm start 999
}

create_template() {
virt-customize -a focal-server-cloudimg-amd64.img –install qemu-guest-agent
virt-customize -a focal-server-cloudimg-amd64.img –run-command ‘useradd -ms /bin/bash zac’
virt-customize -a focal-server-cloudimg-amd64.img –run-command ‘mkdir -p /home/zac/.ssh’
virt-customize -a focal-server-cloudimg-amd64.img –ssh-inject zac:file:/home/zac/.ssh/id_rsa.pub
virt-customize -a focal-server-cloudimg-amd64.img –run-command ‘chown -R zac:zac /home/zac’
virt-customize -a focal-server-cloudimg-amd64.img –run-command ‘echo “zac:changemenow” | chpasswd’

qm create 9000 –name “ubuntu-cloudinit-template” –memory 2048 –cores 2 –net0 virtio,bridge=vmbr0
qm importdisk 9000 focal-server-cloudimg-amd64.img local-lvm
qm set 9000 –scsihw virtio-scsi-pci –scsi0 local-lvm:vm-9000-disk-0
qm set 9000 –boot c –bootdisk scsi0
qm set 9000 –ide2 local-lvm:cloudinit
qm set 9000 –serial0 socket –vga serial0
qm set 9000 –agent enabled=1
qm template 9000
}

remove_img(){
[[ -f focal-server-cloudimg-amd64.img ]] && rm -f focal-server-cloudimg-amd64.img
}

main() {
if qm status 9000 &> /dev/null; then
qm stop 9000
qm destroy 9000
fi
remove_img
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
create_template
create_clone
remove_img
}

main

# Ubuntu Server 24.04 LTS (Noble Numbat) daily builds
# https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img