vm_id='2010'
cloud_img_url='https://cloud-images.ubuntu.com/daily/server/groovy/current/groovy-server-cloudimg-amd64-disk-kvm.img'
image_name=${cloud_img_url##*/} # focal-server-cloudimg-amd64.img
wget ${cloud_img_url}
# virt-edit -a ${image_name} /etc/cloud/cloud.cfg
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/disable_root: [Tt]rue/disable_root: False/'
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/disable_root: 1/disable_root: 0/' 
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/lock_passwd: [Tt]rue/lock_passwd: False/'
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/lock_passwd: 1/lock_passwd: 0/' 
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/ssh_pwauth:   0/ssh_pwauth:   1/'
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/PasswordAuthentication no/PasswordAuthentication yes/'
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/PermitRootLogin [Nn]o/PermitRootLogin yes/'
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/#PermitRootLogin [Yy]es/PermitRootLogin yes/'
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/'
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/[#M]axAuthTries 6/MaxAuthTries 20/'
virt-customize --install cloud-init,atop,htop,nano,vim,qemu-guest-agent,curl,wget -a ${image_name}
qm create ${vm_id} --memory 512 --net0 virtio,bridge=vmbr0,firewall=1
qm importdisk ${vm_id} ${image_name} local
qm set ${vm_id} --ide0 local:cloudinit
qm set ${vm_id} --boot c --bootdisk scsi0
qm set ${vm_id} --serial0 socket --vga serial0
qm template ${vm_id}



