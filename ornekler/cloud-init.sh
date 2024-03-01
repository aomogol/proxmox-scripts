#!/bin/bash

# installing libguestfs-tools only required once, prior to first run
# apt update -y
# apt install libguestfs-tools -y

# remove existing image in case last execution did not complete successfully
#rm mantic-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/mantic/current/mantic-server-cloudimg-amd64.img

# create cloud-init user & password
virt-customize -a mantic-server-cloudimg-amd64.img --install qemu-guest-agent, neofetch, bash-completion
#virt-customize -a mantic-server-cloudimg-amd64.img --install neofetch
#virt-customize -a mantic-server-cloudimg-amd64.img --install bash-completion
#virt-customize -a mantic-server-cloudimg-amd64.img --install 
virt-customize -a mantic-server-cloudimg-amd64.img --run-command "useradd -m -s /bin/bash aom"
virt-customize -a mantic-server-cloudimg-amd64.img --root-password password:aom

 qm create 8003 --name "ubuntu-2310-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
 qm importdisk 8003 mantic-server-cloudimg-amd64.img local

qm set 8003 --scsi0 local:0,import-from=/root/download/mantic-server-cloudimg-amd64.img

 qm set 8003 --scsihw virtio-scsi-pci --scsi0 local:vm-8003-disk-0
 qm set 8003 --boot c --bootdisk scsi0
 qm set 8003 --ide2 local:cloudinit
 qm set 8003 --serial0 socket --vga serial0
 qm set 8003 --agent enabled=1
 qm template 8003
#rm mantic-server-cloudimg-amd64.img
echo "next up, clone VM, then expand the disk"
echo "you also still need to copy ssh keys to the newly cloned VM"



