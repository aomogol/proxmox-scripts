#!/bin/bash

#Create template
#args:
# vm_id
# vm_name
# file name in the current directory
function create_template() {
    #Print all of the configuration
    echo "Creating template $2 ($1)"

    #Create new VM 
    echo "#Create new VM "
    #Feel free to change any of these to your liking
    qm create $1 --name $2 --ostype l26 
    
    echo "#Set networking to default bridge"
    qm set $1 --net0 virtio,bridge=vmbr0

    echo "#Set display to serial"
    qm set $1 --serial0 socket --vga serial0

    echo "#Set memory, cpu, type defaults"
    #If you are in a cluster, you might need to change cpu type
    qm set $1 --memory 1024 --cores 2 --cpu host

    echo "#Set boot device to new file"
    qm set $1 --scsi0 ${storage}:0,import-from="$(pwd)/$3",discard=on

    echo "#Set scsi hardware as default boot disk using virtio scsi single"
    qm set $1 --boot order=scsi0 --scsihw virtio-scsi-single
    
    echo "#Enable Qemu guest agent in case the guest has it available"
    qm set $1 --agent enabled=1,fstrim_cloned_disks=1
    
    echo "#Add cloud-init device"
    qm set $1 --ide2 ${storage}:cloudinit
    
    echo "#Set CI ip config"
    #IP6 = auto means SLAAC (a reliable default with no bad effects on non-IPv6 networks)
    #IP = DHCP means what it says, so leave that out entirely on non-IPv4 networks to avoid DHCP delays
    qm set $1 --ipconfig0 "ip6=auto,ip=dhcp"
    #Import the ssh keyfile
    #qm set $1 --sshkeys ${ssh_keyfile}
    #If you want to do password-based auth instaed
    #Then use this option and comment out the line above
    #qm set $1 --cipassword password
    
    echo "#Add the user"
    qm set $1 --ciuser ${username}
    
    echo "#Resize the disk to 8G, a reasonable minimum. You can expand it more later."
    #If the disk is already bigger than 8G, this will fail, and that is okay.
    qm disk resize $1 scsi0 8G

    echo "#Make it a template"
    qm template $1

    echo "#Remove file when done"
    rm $3
}


#Path to your ssh authorized_keys file
#Alternatively, use /etc/pve/priv/authorized_keys if you are already authorized
#on the Proxmox system
#export ssh_keyfile=/root/id_rsa.pub
#Username to create on VM template
export username=aom

#Name of your storage
export storage=local

#The images that I've found premade
#Feel free to add your own

## Debian
#Trixie (13) (testing) dailies
#wget "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"
#create_template 8013 "temp-debian-13-daily" "debian-13-genericcloud-amd64-daily.qcow2"

## Ubuntu
#23.10 (Manic Minotaur)
wget https://cloud-images.ubuntu.com/mantic/current/mantic-server-cloudimg-amd64.img
#wget "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img"
create_template 8003 "temp-ubuntu-23-10" "mantic-server-cloudimg-amd64.img"
#As 23.10 has *just released*, the next LTS (24.04) is not in dailies yet

echo "İndirme işlemleri tamamlandı."