#!/bin/bash
## 
## https://technotim.live/posts/cloud-init-cloud-image/
## https://cloud-images.ubuntu.com/

### Instructions
# Choose your Ubuntu Cloud Image

# Download Ubuntu (replace with the url of the one you chose from above)
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create a new virtual machine
qm create 8000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0

# Import the downloaded Ubuntu disk to local-lvm storage
qm importdisk 8000 jammy-server-cloudimg-amd64.img local

# Attach the new disk to the vm as a scsi drive on the scsi controller
qm set 8000 --scsihw virtio-scsi-pci --scsi0 local:vm-8000-disk-0

# Add cloud init drive
qm set 8000 --ide2 local:cloudinit

#Make the cloud init drive bootable and restrict BIOS to boot from disk only
qm set 8000 --boot c --bootdisk scsi0

# Add serial console
qm set 8000 --serial0 socket --vga serial0

#DO NOT START YOUR VM

# Now, configure hardware and cloud init, then create a template and clone.
# If you want to expand your hard drive you can on this base image before creating a template or after you clone a new machine.
# I prefer to expand the hard drive after I clone a new machine based on need.

# Create template.
qm template 8020

# Clone template.
qm clone 8020 8135 --name yoshi --full

# Troubleshooting

# If you need to reset your machine-id

sudo rm -f /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id

# Then shut it down and do not boot it up.A new id will be generated the next time it boots.If it does not you can run:

sudo systemd-machine-id-setup

#### 

wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 8020 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
qm importdisk 8020 jammy-server-cloudimg-amd64.img local
qm set 8020 --scsihw virtio-scsi-pci --scsi0 local:vm-8020-disk-0
qm set 8020 --ide2 local:cloudinit
qm set 8020 --boot c --bootdisk scsi0
qm set 8020 --serial0 socket --vga serial0
qm set 8003 --agent enabled=1