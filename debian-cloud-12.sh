#!/bin/bash

## Debian (12)
#wget "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"

set -e

# Set environment variables. Change these as necessary.
export STORAGE_POOL="local"
export VM_ID="8012"
export VM_NAME="debian-12-cloudimg"
export VM_DISK_SIZE="8G"
export VM_DISK_FORMAT="qcow2"
export VM_DISK_PATH="/var/lib/libvirt/images"
export VM_DISK_FILE="$VM_NAME.qcow2"
export VM_MEMORY="1024"
export VM_CPU="2"
export VM_OS_TYPE="l26"
export VM_OS_VARIANT="debian"
export VM_OS_VERSION="12"
export VM_OS_ARCH="amd64"
export VM_OS_CLOUD_INIT_FILE="cloud-init.iso"
export VM_OS_CLOUD_INIT_PATH="/var/lib/libvirt/images"
export VM_OS_CLOUD_INIT_ISO_URL="https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
export VM_OS_CLOUD_INIT_ISO_FILE="debian-12-genericcloud-amd64.qcow2"
export VM_CPU_TYPE="host"   
export username="aom"
export password="a"

#Create template

function create_template() {
    #Print all of the configuration
    echo "Creating template $VM_NAME  ($VM_ID)"
    echo "#Create new VM "
        qm create $VM_ID --name $VM_NAME --ostype $VM_OS_TYPE 
#       qm create ${TEMPLATE_ID} --name "${TEMPLATE_IMAGE}-$(date +%Y%M%d)" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
    echo "#Set networking to default bridge"
        qm set $VM_ID --net0 virtio,bridge=vmbr0
    
    echo "#Set display to serial"
        qm set $VM_ID --serial0 socket --vga serial0
    
    echo "#Set memory, cpu, type defaults"
    #If you are in a cluster, you might need to change cpu type
        qm set $VM_ID --memory $VM_MEMORY --cores $VM_CPU --cpu $VM_CPU_TYPE
    
    echo "#Set boot device to new file"
        qm set $VM_ID --scsi0 $STORAGE_POOL:0,import-from="$(pwd)/$VM_OS_CLOUD_INIT_ISO_FILE",discard=on
    
    echo "#Set scsi hardware as default boot disk using virtio scsi single"
        qm set $VM_ID --boot order=scsi0 --scsihw virtio-scsi-single
    
    echo "#Enable Qemu guest agent in case the guest has it available"
        qm set $VM_ID --agent enabled=1,fstrim_cloned_disks=1
    
    echo "#Add cloud-init device"
        qm set $VM_ID --ide2 $STORAGE_POOL:cloudinit
    
    echo "#Set CI ip config"
    #IP6 = auto means SLAAC (a reliable default with no bad effects on non-IPv6 networks)
    #IP = DHCP means what it says, so leave that out entirely on non-IPv4 networks to avoid DHCP delays
    #qm set $VM_ID --ipconfig0 "ip6=auto,ip=dhcp"
        qm set $VM_ID --ipconfig0 "ip=dhcp"
    
    #Import the ssh keyfile
        #qm set $VM_ID --sshkeys ${ssh_keyfile}
    
    echo "#Add the User & Password"
        qm set $VM_ID --ciuser $username
    #If you want to do password-based auth instaed
    #Then use this option and comment out the line above
        qm set $VM_ID --cipassword $password
    
    echo "#Resize the disk."
    #If the disk is already bigger than 8G, this will fail, and that is okay.
        qm disk resize $VM_ID scsi0 $VM_DISK_SIZE
    
    echo "#Make it a template"
        qm template $VM_ID
    
    echo "#Remove file when done"
        rm $VM_OS_CLOUD_INIT_ISO_FILE
}

#Path to your ssh authorized_keys file
#Alternatively, use /etc/pve/priv/authorized_keys if you are already authorized on the Proxmox system
#export ssh_keyfile=/root/id_rsa.pub

imagefile=/root/download/$VM_OS_CLOUD_INIT_ISO_FILE

if test -f "$imagefile"; then
    echo "found img file skipping download..."
else
    echo "downloading img file..."
    cd /root/download
    wget $VM_OS_CLOUD_INIT_ISO_URL
fi

# Install apps on Ubuntu image.

    ###      --firstboot-install PKG,PKG..

virt-customize -a $VM_OS_CLOUD_INIT_ISO_FILE --install qemu-guest-agent,neofetch,git,bash-completion
# Enable password authentication in the template. Obviously, not recommended for except for testing.
virt-customize -a $VM_OS_CLOUD_INIT_ISO_FILE --run-command "sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
virt-customize -a $VM_OS_CLOUD_INIT_ISO_FILE --run-command "sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"

create_template $VM_ID $VM_NAME $VM_OS_CLOUD_INIT_ISO_FILE

echo " $VM_NAME işlemleri tamamlandı."