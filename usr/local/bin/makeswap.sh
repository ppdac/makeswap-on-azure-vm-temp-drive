#!/bin/bash

#sdb is already mounted at /mnt so let's use it
FILE=/mnt/swapfile

# Use the value from the parameter file if it exists
# You can always set /var/local/makeswap-on-azure/swap_size to your desired size and restart service.
if test -f $parameterFile; then
    swapSize=$(<$parameterFile)
    echo "makeswap-on-azure: Found $parameterFile." > /dev/kmsg
    if [[ ! -z $F ]]; then
        echo -e "makeswap-on-azure: Swap size set to $swapSize. To change this:\nmakeswap-on-azure: 1. Edit $parameterFile.\nmakeswap-on-azure: 2. Restart the service: systemctl restart make-swap-on-azure.service." > /dev/kmsg
    else
        echo "makeswap-on-azure: $parameterFile is not set." > /dev/kmsg
    fi
fi
if ! test -f $parameterFile || [ -z $swapSize ]; then
    echo "makeswap-on-azure: Calulating new swap size." > /dev/kmsg

    mkdir -p /var/local/makeswap-on-azure
    touch $parameterFile
    freeDiskSpace=$(df -h | grep sdb1 | awk '{print $4+0}')
    if [ $freeDiskSpace -gt 0 ]; then
        echo "makeswap-on-azure: ${freeDiskSpace}G available disk space on temdrive." > /dev/kmsg
    else
        echo "makeswap-on-azure: ${freeDiskSpace}G is not enough to proceed. Please free up some space on /dev/sdb1."
    fi

    # Azure won't give you the full amount of RAM as some of it is taken by platform services.
    # Approximating 512 MiB to 500,000 kB, anso on, is close enough for these increments
    memTotal=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    echo "makeswap-on-azure: Total of ${memTotal}kB RAM." > /dev/kmsg

    # Fork me ¯\_(ツ)_/¯
    if [ $freeDiskSpace -gt 4 ]; then
        if [ $memTotal -lt 500000 ]; then
            echo 512MB > $parameterFile
        elif [ $memTotal -le 1000000 ]; then
            echo 1G > $parameterFile
        elif [ $memTotal -le 4000000 ]; then
            echo 2G > $parameterFile
        elif [ $memTotal -le 16000000 ]; then
            echo 4G > $parameterFile
        elif [ $memTotal -le 32000000 ]; then
            echo 6G > $parameterFile
        elif [ $memTotal -le 48000000 ]; then
            echo 7G > $parameterFile
        elif [ $memTotal -le 64000000 ]; then
            echo 8G > $parameterFile
        elif [ $memTotal -le 128000000 ]; then
            echo 12G > $parameterFile
        elif [ $memTotal -le 1000000000 ]; then
            echo 16G > $parameterFile
        elif [ $memTotal -ge 1000000000 ]; then
            echo 32G > $parameterFile
        fi
    fi

    echo "makeswap-on-azure: New swap size is now $(cat $parameterFile)." > /dev/kmsg
fi

# https://github.com/ppdac/makeswap-on-azure.service/issues/3
chmod ugo+w $PARAMETER_FILE

# Finally swapon
if test -f "$FILE"; then
    #swap file exists, so remove it
    echo "makeswap-on-azure: swap file file alreaedy exists." > /dev/kmsg
    swapoff $FILE
    rm $FILE
    echo "makeswap-on-azure: Deleted it." > /dev/kmsg
    
    #recreate swapfile
    fallocate -l $swapSize $FILE
    chmod 600 $FILE
    mkswap $FILE
    swapon $FILE
    echo "makeswap-on-azure: Recreated ${swapSize}G swapfile." > /dev/kmsg
else
    #create swapfile for the first time
    fallocate -l $swapSize $FILE
    chmod 600 $FILE
    mkswap $FILE
    swapon $FILE
    echo "makeswap-on-azure: New ${swapSize}G swapfile created." > /dev/kmsg
fi  
