for cloud_img_url in $(cat images.txt); 
do 
image_name=${cloud_img_url##*/};
echo "Downloading ${image_name}";
wget ${cloud_img_url};
do 
echo "Editing ${image_name}";
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/disable_root: [Tt]rue/disable_root: False/'; 
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/disable_root: 1/disable_root: 0/';
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/ssh_pwauth:   0/ssh_pwauth:   1/';
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/lock_passwd: [Tt]rue/lock_passwd: False/';
virt-edit -a ${image_name} /etc/cloud/cloud.cfg -e 's/lock_passwd: 1/lock_passwd: 0/';
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/PasswordAuthentication no/PasswordAuthentication yes/';
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/PermitRootLogin [Nn]o/PermitRootLogin yes/';
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/#PermitRootLogin [Yy]es/PermitRootLogin yes/';
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/';
virt-edit -a ${image_name} /etc/ssh/sshd_config -e 's/#MaxAuthTries 6/MaxAuthTries 20/';
virt-customize --install cloud-init,atop,htop,nano,vim,qemu-guest-agent,curl,wget -a ${image_name};
mv ${image_name} /var/lib/vz/template/kvm/${image_name};
done