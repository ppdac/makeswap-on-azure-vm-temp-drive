#!/bin/bash

#sdb is already mounted at /mnt so let's use it
FILE=/mnt/swapfile

# Set /var/local/makeswap-on-azure/swap_size to your desired size.
# For example sudo su; echo 3600M > /var/local/makeswap-on-zure/swap_size; exit;
# It can be something like:
# 1024K
# 1024M
# 3.5G
# The default is 3333M
SWAP_SIZE=$(</var/local/makeswap-on-azure/swap_size)


#This writes do dmesg, but not enough.
if test -f "$FILE"; then
    echo "makeswap-on-azure-vm-tmp-drive: swapfile file alreaedy exists." >  /dev/kmsg
else
    fallocate -l $SWAP_SIZE $FILE
    chmod 600 $FILE
    mkswap $FILE
    swapon $FILE
fi  
