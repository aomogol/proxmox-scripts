#!/bin/bash

# ilk kurulumda bulunan lvm yapısını değiştirmek için
# lvm yapısı silinip tüm diski kullanmak için

# disk yapısını kontrol etmek içim
lsblk

# lvm silmek için 
lvremove /dev/pve/data

# disk yapısını resize etmek için
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root

#işlem tamamlandıktan sonra  tekrar kontrol 
 lsblk