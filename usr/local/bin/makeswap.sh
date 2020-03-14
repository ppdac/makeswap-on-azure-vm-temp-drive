#!/bin/bash

#sdb is already mounted at /mnt so let's use it
FILE=/mnt/swapfile

#clean up bug that made directory instead of file.
if [ -d /var/local/makeswap-on-azure/swap_size ]; then
    rm -rf /var/local/makeswap-on-azure/swap_size
fi

#The parameter needs to exist.
PARAMETER_FILE=/var/local/makeswap-on-azure/swap_size

if test -f $PARAMETER_FILE; then
    #Use the value from the parameter file if it exists
    SWAP_SIZE=$(<$PARAMETER_FILE)
else
    #Otherwise make one with a reasonable value
    mkdir -p /var/local/makeswap-on-azure/
    touch $PARAMETER_FILE
    echo 3333M > $PARAMETER_FILE
fi

#https://github.com/ppdac/makeswap-on-azure.service/issues/3
chmod ugo+w $PARAMETER_FILE

# Set /var/local/makeswap-on-azure/swap_size to your desired size and restart service.
# For example sudo su; echo 3600M > /var/local/makeswap-on-azure/swap_size; exit;
# It can be something like:
# 1024K
# 1024M
# 3.5G
# The default is 3333M
SWAP_SIZE=$(<$PARAMETER_FILE)


#This writes do dmesg, but not enough.
if test -f "$FILE"; then
    #swap file exists, so remove it
    echo "makeswap-on-azure-vm-tmp-drive: swapfile file alreaedy exists." > /dev/kmsg
    swapoff $FILE
    rm $FILE
    echo "makeswap-on-azure-vm-tmp-drive: Deleted it." > /dev/kmsg
    
    #recreate swapfile
    fallocate -l $SWAP_SIZE $FILE
    chmod 600 $FILE
    mkswap $FILE
    swapon $FILE
else
    #create swapfile for the first time
    fallocate -l $SWAP_SIZE $FILE
    chmod 600 $FILE
    mkswap $FILE
    swapon $FILE
fi  
