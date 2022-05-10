[![Deploy: Ubuntu (latest)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy.yml/badge.svg)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy.yml)

# Index
1. [Overview](#makeswap-on-azureservice)
2. [Usage](#usage)
   - [Install](#install)
   - [Uninstall](#uninstall)
   - [Upgrade](#upgrade)
3. [Adjust amount of virtual memory](#adjust-amount-of-virtual-memory)


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
### Clone, build and install
```
mkdir ~/git && cd ~/git

git clone https://github.com/ppdac/makeswap-on-azure.service.git
dpkg-deb --build makeswap-on-azure.service
sudo dpkg --install makeswap-on-azure.service.deb
sudo systemctl enable makeswap-on-azure.service
sudo systemctl start makeswap-on-azure.service

rm -rf makeswap-on-azure.service
rm makeswap-on-azure.service.deb
```


## Uninstall
```
sudo systemctl disable makeswap-on-azure.service 
sudo dpkg --remove makeswap-on-azure.service
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