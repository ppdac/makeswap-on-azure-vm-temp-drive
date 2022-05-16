[![Deployment/Removal on ubuntu-20.04](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy20-04.yml/badge.svg?branch=main)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy20-04.yml) [![.github/workflows/test-swapping20-04.yml](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/test-swapping20-04.yml/badge.svg?branch=main)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/test-swapping20-04.yml)

![Animation showing installation, verification of functionality and removing of the makeswap-on-azure service.](https://github.com/soyfrien/makeswap-on-azure.service/raw/main/.github/makeswap-on-azure.gif)

# Index
1. [Overview](#makeswap-on-azureservice)
2. [Usage](#usage)
   - [Install](#install)
   - [Uninstall](#uninstall)
   - [Upgrade](#upgrade)
   - [Adjust amount of virtual memory](#adjust-amount-of-virtual-memory)


# makeswap-on-azure.service
Ensures a swapfile exists or is created on the volatile temporary drive in an Azure VM.
> **Temporary disk**
>
> Every VM contains a temporary disk, which is not a managed disk. The temporary disk provides short-term storage for 
> applications and processes and is intended to only store data such as page or swap files. Data on the temporary disk 
> may be > lost during a maintenance event event or when you redeploy a VM. On Azure Linux VMs, the temporary disk is 
> /dev/sdb by default and on Windows VMs the temporary disk is D: by default. During a successful standard reboot of 
> the VM, the data on the temporary disk will persist.
>
> [Azure Disk Storage overview for Linux VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/managed-disks-overview?toc=%2Fazure%2Fvirtual-machines%2Flinux%2Ftoc.json#temporary-disk)


# Usage
## Install
### Option A: Pre-packaged
```
wget -q https://github.com/ppdac/makeswap-on-azure.service/releases/latest/download/makeswap-on-azure.service.deb
sudo dpkg --install makeswap-on-azure.service.deb
sudo systemctl enable makeswap-on-azure.service
sudo systemctl restart makeswap-on-azure.service
```


### Option B: From source
```
mkdir ~/git; cd ~/git

git clone https://github.com/ppdac/makeswap-on-azure.service.git
rm -rf ~/git/makeswap-on-azure.service/.git
rm -rf ~/git/makeswap-on-azure.service/.github

dpkg-deb --build ~/git/makeswap-on-azure.service
sudo dpkg --install ~/git/makeswap-on-azure.service.deb
sudo systemctl enable makeswap-on-azure.service
sudo systemctl restart makeswap-on-azure.service

rm -rf ~/git/makeswap-on-azure.service
rm ~/git/makeswap-on-azure.service.deb
```


## Uninstall
```
sudo dpkg --remove makeswap-on-azure
```


## Upgrade
 - Uninstall
 - Install


## Adjust amount of virtual memory
The amount of virtual memory is dynamically determined, loosely based around the table on the 
[Ubuntu SwapSize FAQ](https://help.ubuntu.com/community/SwapFaq#How_much_swap_do_I_need.3F).

You can set your desired size at any time, by writing to this file `/etc/makeswap-on-azure/swap_size`.

For example:
```
echo "1G" > /etc/makeswap-on-azure/swap_size
sudo systemctl restart makeswap-on-azure.service
```

The value can be something like:
  - 8192K
  - 2048M
  - 1.5G
