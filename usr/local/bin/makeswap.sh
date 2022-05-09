#!/bin/bash
#
# Creates swap file on the temp drive

# Use the value from the parameter file if it exists
<<<<<<< Updated upstream
# You can always set /var/local/makeswap-on-azure/swap_size to your desired size and restart service.
readonly PARAMETER_FILE='/var/local/makeswap-on-azure/swap_size'
=======
# You can always set /etc/makeswap-on-azure/swap_size to your desired size and restart service.
# See https://github.com/soyfrien/makeswap-on-azure.service#adjust-size-of-virtual-memory
readonly CONFIG_DIR='/etc/makeswap-on-azure'
readonly PARAMETER_FILE="$CONFIG_DIR/swap_size"
>>>>>>> Stashed changes
readonly SWAP_FILE='/mnt/pagefile'

# Usage: logger "This will be logged."
logger() {
    echo "[makeswap-on-azure]: $*" >&1
}

# Usage: err "This is sent to STDERR before returning 1 on exit."
err() {
    echo "[makeswap-on-azure]: $*" >&2
    exit 1
}

#######################################
# Allocates disk space, creates swap file and enables it
# Globals:
#   PARAMETER_FILE
#   SWAP_FILE
# Arguments:
#   None
# Returns:
#   0 or non-zero on error.
#######################################
commit_swap() {
    # https://github.com/ppdac/makeswap-on-azure.service/issues/3
    chmod ugo+w "$PARAMETER_FILE"
    local readonly SWAP_SIZE=$(cat $PARAMETER_FILE)
    fallocate -l $SWAP_SIZE $SWAP_FILE
    if (($? == 0)); then
        logger "Allocated $SWAP_SIZE for $SWAP_FILE"
    else
        err "Failed to allocate $SWAP_FILE to $SWAP_FILE"
    fi

    chmod 600 "$SWAP_FILE"
    if (($? == 0)); then
        logger "Set 600 permissions on $SWAP_FILE"
    else
        err "Failed to set 600 permissions on $SWAP_FILE"
    fi

    mkswap "$SWAP_FILE"
    if (($? == 0)); then
        logger "Recreated swap file $SWAP_FILE"
    else
        err "Failed to recreate swap file $SWAP_FILE"
    fi

    swapon $SWAP_FILE
    if (($? == 0)); then
        logger "The ${SWAP_FILE} swap file was enabled as $SWAP_FILE."
    else
        err "Failed to enable the swap file $SWAP_FILE"
    fi
}

#######################################
# Turns off he swap function and deletes the swap file
# Globals:
#   PARAMETER_FILE
# Arguments:
#   None
# Returns:
#   0 or non-zero on error.
#######################################
remove_swap() {
    # https://github.com/ppdac/makeswap-on-azure.service/issues/3
    chmod ugo+w "$PARAMETER_FILE"

    if [ -f "$SWAP_FILE"] ; then
    logger "Swap file already exists, removing it."
    swapoff "$SWAP_FILE"
    if (($? == 0)); then
        logger "Swap disabled."
    else
        err  "Failed to disable swap."
    fi
    
    rm $SWAP_FILE
    if (($? == 0)); then
        logger "$SWAP_FILE was removed."
    else
        err "Failed to remove swap file from $SWAP_FILE"
    fi
}

#######################################
# Calculate size of swap appropriate with respect to space and memory
# Globals:
#   PARAMETER_FILE
# Arguments:
#   None
# Returns:
#   0 if calculation completed, non-zero on error.
#######################################
calculate_swap_size() {
    local readonly FILESYSTEM=$(df | grep /mnt | gawk '{print $1}')

    # Azure won't give you the full amount of RAM as some of it is taken by platform services.
    # Approximating 512 MiB to 512 * 1024, and so on, is close enough for these increments
    # lop off decimals with int(float)
    local memTotal=$(cat /proc/meminfo | grep MemTotal | gawk '{print int($2/1024)}')
    logger "Total RAM: ${memTotal}M."

    # Kilobyes/1024+0.5 is good for general rounding, but we don't want more than is available
    local FREE_DISK_SPACE=$(df | grep /mnt | gawk '{print int($4/1024)}')
    logger "$FREE_DISK_SPACE megabyes available on $FILESYSTEM (rounding down for safety)."

    if [ $FREE_DISK_SPACE -gt 0 ]; then
        logger "${FREE_DISK_SPACE}M available disk space on $FILESYSTEM."
    else
        err "{FREE_DISK_SPACE} bytes is not enough to proceed. Please free up some space on $FILESYSTEM."
    fi

    # Fork me ¯\_(ツ)_/¯  
    if [ $FREE_DISK_SPACE -ge 256 ]; then
        if [ $memTotal -lt 512 ]; then
            echo 256M > $PARAMETER_FILE
        elif [ $memTotal -le 1024 ] && [ 512 -le $FREE_DISK_SPACE ];then
            echo 512M > $PARAMETER_FILE
        elif [ $memTotal -le 3072 ] && [ 1024 -le $FREE_DISK_SPACE ]; then
            echo 1G > $PARAMETER_FILE
        elif [ $memTotal -le 4096 ] && [ 2048 -le $FREE_DISK_SPACE ]; then
            echo 2G > $PARAMETER_FILE
        elif [ $memTotal -le 6144 ] && [ 4096 -le $FREE_DISK_SPACE ]; then
            echo 4G > $PARAMETER_FILE
        elif [ $memTotal -le 7168 ] && [ 6144 -le $FREE_DISK_SPACE ]; then
            echo 6G > $PARAMETER_FILE
        elif [ $memTotal -le 8192 ] && [ 7168 -le $FREE_DISK_SPACE ]; then
            echo 7G > $PARAMETER_FILE
        elif [ $memTotal -le 12288 ] && [ 8192 -le $FREE_DISK_SPACE ]; then
            echo 8G > $PARAMETER_FILE
        elif [ $memTotal -le 16384 ] && [ 12288 -le $FREE_DISK_SPACE ]; then
            echo 12G > $PARAMETER_FILE
        elif [ $memTotal -ge 16384 ] && [ 16384 -le $FREE_DISK_SPACE ]; then
            echo 16G > $PARAMETER_FILE
        elif [ $memTotal -le $FREE_DISK_SPACE ]; then
            echo "${FREE_DISK_SPACE}M" > $PARAMETER_FILE
        else
            err "Failed to calculate swap size."
        fi
    fi

    logger "Calculated swap size of $(cat $PARAMETER_FILE)."
}

#######################################
# Program flow structure. Called from final line.
# Globals:
#   PARAMETER_FILE
#   SWAP_FILE
# Arguments:
#   None
#######################################
main() {
    if [ -f "$PARAMETER_FILE" ]; then
        logger "Found $PARAMETER_FILE."
        if [[ ! -z $PARAMETER_FILE ]]; then
<<<<<<< Updated upstream
            # Set the size of swap using the value stored in /var/local/makeswap-on-azure/swap_size
            local readonly SWAP_SIZE=$(cat $PARAMETER_FILE)
=======
            # Set the size of swap using the value stored in /etc/makeswap-on-azure/swap_size
            readonly SWAP_SIZE=$(cat $PARAMETER_FILE)
>>>>>>> Stashed changes
            logger "Set the swap size to $SWAP_SIZE"
        else
            err "$PARAMETER_FILE is not set."
        fi
    fi

    if [ ! -f $PARAMETER_FILE ] || [ -z $SWAP_SIZE ]; then
        logger "$PARAMETER_FILE is not present or is not set."

        mkdir -p "/var/local/makeswap-on-azure"
        if (($? == 0)); then
            logger "Created directory /var/local/makeswap-on-azure"
        else
            err "Failed create directory /var/local/makeswap-on-azure"
        fi

        touch $PARAMETER_FILE
        if (($? == 0)); then
            logger "Created $PARAMETER_FILE to hold swap size configuration."
        else
            err "Failed to create configuration file $PARAMETER_FILE"
        fi

        if [ -f $SWAP_FILE ]; then
            logger "Removing a swap file that is already present."
            remove_swap
            if (($? != 0)); then
                err "Failed to remove existing swap file. https://github.com/soyfrien/makeswap-on-azure.service/issues/new?assignees=soyfrien&labels=bug&template=bug_report.md&title=%5BBUG%5D%20Unchecked%20exception%20in%20main%20Line%20210"
            fi
        fi

        logger "Calulating appropriate swap size."
        calculate_swap_size
        if (($? != 0)); then
            err "Exception in calculate_swap_size. Please report this https://github.com/soyfrien/makeswap-on-azure.service/issues/new?assignees=soyfrien&labels=bug&template=bug_report.md&title=%5BBUG%5D%20Unchecked%20exception%20in%20main%20Line%20217"
        fi
    fi

    commit_swap
    if (($? != 0)); then
        err "Exception in commit_swap. Please report this https://github.com/soyfrien/makeswap-on-azure.service/issues/new?assignees=soyfrien&labels=bug&template=bug_report.md&title=%5BBUG%5D%20Unchecked%20exception%20in%20main%20Line%202"
    fi
}

main "$@"