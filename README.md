# makeswap-on-azure.service
Ensures a swapfile exists or is created on the volatile temporary drive in an Azure VM.
> **Temporary disk**
>
> Every VM contains a temporary disk, which is not a managed disk. The temporary disk provides short-term storage for 
> applications and processes and is intended to only store data such as page or swap files. Data on the temporary disk may be > lost during a maintenance event event or when you redeploy a VM. On Azure Linux VMs, the temporary disk is /dev/sdb by 
> default and on Windows VMs the temporary disk is D: by default. During a successful standard reboot of the VM, the data on 
> the temporary disk will persist.
>
> [Azure Disk Storage overview for Linux VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/managed-disks-overview?toc=%2Fazure%2Fvirtual-machines%2Flinux%2Ftoc.json#temporary-disk)

# Installation
 1. Downlad, unzip, and build the `.deb` file: `dpkg-deb --build makeswap-on-azure-vm-temp-drive`
 2. Install the package: `dpkg -i makeswap-on-azure-vm-temp-drive.deb`

# FYI
 1. Value is hardcoded at 3.3 GB as I happen to use b size VMs, with 4 GB temp drives.
 2. You will have to clone the souce and [change this value to suite your needs on this line](https://github.com/ppdac/makeswap-on-azure-vm-temp-drive/blob/fc21ca425556fc01f5fb93401c2c9f572cd0c466/usr/local/bin/makeswap.sh#L5).
 
 # TODO 
 1. Automate the chosen size before building the package. Feel free, please!
