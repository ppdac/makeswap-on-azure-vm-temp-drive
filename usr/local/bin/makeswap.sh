#!/bin/bash
#
# Creates swapfile on the temp drive

# Use the value from the parameter file if it exists
# You can always set /var/local/makeswap-on-azure/swap_size to your desired size and restart service.
readonly parameterFile='/var/local/makeswap-on-azure/swap_size'
readonly swapFile='/mnt/pagefile'

# Logging function
logger() {
    echo "[makeswap-on-azure]: $*" >&1
}

# STDERR logging function
err() {
    echo "[makeswap-on-azure]: $*" >&2
    esit 1
}

# Allocates disk space, creates swap file and enables it
commit_swap() {
    # https://github.com/ppdac/makeswap-on-azure.service/issues/3
    chmod ugo+w "$parameterFile"

    fallocate -l "$swapSize $swapFile"
    if (($? == 0)); then
        logger = "Allocated $swapSize for $swapFile"
    else
        err "Failed to allocate $swapSize to $swapFile"
    fi

    chmod 600 "$swapFile"
    if (($? == 0)); then
        logger "Set 600 permissions on $swapFile"
    else
        err "Failed to set 600 permissions on $swapFile"
    fi

    mkswap "$swapFile"
    if (($? == 0)); then
        logger "Recreated swap file $swapFile"
    else
        err "Failed to recreate swap file $swapFile"
    fi

    swapon $swapFile
    if (($? == 0)); then
        logger "The ${swapSize} swapfile was enabled as $swapFile."
    else
        err "Failed to enable the swap file $swapFile"
    fi
}

remove_swap()
{
    # https://github.com/ppdac/makeswap-on-azure.service/issues/3
    chmod ugo+w "$parameterFile"

    if [ -f "$swapFile"] ; then
    logger "Swap file already exists, removing it."
    swapoff "$swapFile"
    if (($? == 0)); then
        logger "Swap disabled."
    else
        err  "Failed to disable swap."
    fi
    
    rm $swapFile
    if (($? == 0)); then
        logger "$swapFile was removed."
    else
        err "Failed to remove swap file from $swapFile"
    fi
fi
}

calculate_swap_size() {
    # Azure won't give you the full amount of RAM as some of it is taken by platform services.
    # Approximating 512 MiB to 512 * 1024, and so on, is close enough for these increments
    memTotal=$(cat /proc/meminfo | grep MemTotal | gawk '{print $2/1024}')
    logger "Total RAM: ${memTotal}M."

    # Kilobyes/1024+0.5 is good for general rounding, but we don't want more than is available, so
    # lop off decimals with int(float)
    freeDiskSpace=$(df | grep /mnt | gawk '{print int($4/1024)}')
    logger "$freeDiskSpace megabyes available on $filesystem(rounding down for safety)."

    if [ $freeDiskSpace -gt 0 ]; then
        logger "${freeDiskSpace}M available disk space on $filesystem."
    else
        err "{freeDiskSpace} bytes is not enough to proceed. Please free up some space on $filesystem."
    fi

    # Fork me ¯\_(ツ)_/¯  
    if [ $freeDiskSpace -ge 256 ]; then
        if [ $memTotal -lt 512 ]; then
            echo 256M > $parameterFile
        elif [ $memTotal -le 1024 ] && [ 512 -le $freeDiskSpace ];then
            echo 512M > $parameterFile
        elif [ $memTotal -le  2048 ] && [ 1024 -le $freeDiskSpace ]; then
            echo 1G > $parameterFile
        elif [ $memTotal -le 3072 ] && [ 1024 -le $freeDiskSpace ]; then
            echo 1G > $parameterFile
        elif [ $memTotal -le 4096 ] && [ 2048 -le $freeDiskSpace ]; then
            echo 2G > $parameterFile
        elif [ $memTotal -le 6144 ] && [ 4096 -le $freeDiskSpace ]; then
            echo 4G > $parameterFile
        elif [ $memTotal -le 7168 ] && [ 6144 -le $freeDiskSpace ]; then
            echo 6G > $parameterFile
        elif [ $memTotal -le 8192 ] && [ 7168 -le $freeDiskSpace ]; then
            echo 7G > $parameterFile
        elif [ $memTotal -le 12288 ] && [ 8192 -le $freeDiskSpace ]; then
            echo 8G > $parameterFile
        elif [ $memTotal -le 16384 ] && [ 12288 -le $freeDiskSpace ]; then
            echo 12G > $parameterFile
        elif [ $memTotal -ge 16384 ] && [ 16384 -le $freeDiskSpace ]; then
            echo 16G > $parameterFile
        elif [ $memTotal -le $freeDiskSpace ]; then
            echo "${freeDiskSpace}M" > $parameterFile
        else
            err "Failed to calculate swap size."
        fi
    fi

    logger "Calculated swap size of $(cat $parameterFile)."
}

main() {
    local filesystem=$(df | grep /mnt | gawk '{print $1}')

    if [ -f "$parameterFile" ]; then
        logger "Found $parameterFile."
        if [[ ! -z $parameterFile ]]; then
            # Set the size of swap using the value stored in /var/local/makeswap-on-azure/swap_size
            swapSize=$(<$parameterFile)
            logger "Set the swap size to $swapSize"
        else
            err "$parameterFile is not set."
        fi
    fi

    if [ ! -f $parameterFile ] || [ -z $swapSize ]; then
        logger "$parameterFile is not present or is not set."

        mkdir -p "/var/local/makeswap-on-azure"
        if (($? == 0)); then
            logger "Created directory /var/local/makeswap-on-azure"
        else
            err "Failed create directory /var/local/makeswap-on-azure"
        fi

        touch $parameterFile
        if (($? == 0)); then
            logger "Created $parameterFile to hold swap size configuration."
        else
            err "Failed to create configuration file $parameterFile"
        fi

        if [ -f $swapFile ]; then
            logger "Removing a swap file that is already present."
            remove_swap
            if (($? != 0)); then
                err "Failed to remove existing swap file."
            fi
        fi

        logger "Calulating appropriate swap size."
        calculate_swap_size
        if (($? != 0)); then
            err "Exception in calculate_swap_size. Please report this https://github.com/soyfrien/makeswap-on-azure"
        fi
    fi

    commit_swap
    if (($? != 0)); then
        err "Exception in commit_swap. Please report this https://github.com/soyfrien/makeswap-on-azure"
    fi
}

main "$@"