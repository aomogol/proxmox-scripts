#!/bin/bash
    # Ubuntu Server 24.04 LTS (Noble Numbat) daily builds
    # https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
set -e
function echocolor() { # $1 = string
    COLOR='\033[1;33m'
    NC='\033[0m'
    printf "${COLOR}$1${NC}\n"
}

#Create template
#args:
# vm_id
# vm_name
# file name in the current directory
function create_template() {
    #Print all of the configuration
    echocolor "Creating template $2 ($1)"
    echocolor "#Create new VM "
        qm create $1 --name $2 --ostype l26 
    echocolor "#Set networking to default bridge"
        qm set $1 --net0 virtio,bridge=vmbr0
    echocolor "#Set display to serial"
        qm set $1 --serial0 socket --vga serial0
    echocolor "#Set memory, cpu, type defaults"
    #If you are in a cluster, you might need to change cpu type
        qm set $1 --memory 1024 --cores 2 --cpu host
    echocolor "#Set boot device to new file"
        qm set $1 --scsi0 ${storage}:0,import-from="$(pwd)/$3",discard=on
    echocolor "#Set scsi hardware as default boot disk using virtio scsi single"
        qm set $1 --boot order=scsi0 --scsihw virtio-scsi-single
    echocolor "#Enable Qemu guest agent in case the guest has it available"
       qm set $1 --agent enabled=1,fstrim_cloned_disks=1
    echocolor "#Add cloud-init device"
        qm set $1 --ide2 ${storage}:cloudinit
    echocolor "#Set CI ip config"
    #IP6 = auto means SLAAC (a reliable default with no bad effects on non-IPv6 networks)
    #IP = DHCP means what it says, so leave that out entirely on non-IPv4 networks to avoid DHCP delays
    #qm set $1 --ipconfig0 "ip6=auto,ip=dhcp"
        qm set $1 --ipconfig0 "ip=dhcp"
    #Import the ssh keyfile
        #qm set $1 --sshkeys ${ssh_keyfile}
    echocolor "#Add the User & Password"
        qm set $1 --ciuser ${username}
    #If you want to do password-based auth instaed
    #Then use this option and comment out the line above
        qm set $1 --cipassword ${password}
    echocolor "#Resize the disk to 8G, a reasonable minimum. You can expand it more later."
    #If the disk is already bigger than 8G, this will fail, and that is okay.
        qm disk resize $1 scsi0 8G
    echocolor "#Make it a template"
        qm template $1
    echocolor "#Remove file when done"
        rm $3
}

#Path to your ssh authorized_keys file
#Alternatively, use /etc/pve/priv/authorized_keys if you are already authorized on the Proxmox system
#export ssh_keyfile=/root/id_rsa.pub

#Username to create on VM template
export username=aom
export password=a

#Name of your storage
export storage=local

# Ubuntu Server 24.04 LTS (Noble Numbat) daily builds
# https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

imagefile=/root/download/noble-server-cloudimg-amd64.img
if test -f "$imagefile"; then
     echo "found img file skipping download..."
else
     echocolor "downloading img file..."
     cd /root/download
     wget "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"   
fi


create_template 8001 "temp-ubuntu-24-04" "noble-server-cloudimg-amd64.img"

echocolor " işlemler tamamlandı."