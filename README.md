[![Deploy: Ubuntu (latest)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy.yml/badge.svg)](https://github.com/soyfrien/makeswap-on-azure.service/actions/workflows/deploy.yml)

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
 1. Clone: `git clone https://github.com/ppdac/makeswap-on-azure.service.git`
 2. Build deb: `dpkg-deb --build makeswap-on-azure.service`
 3. Install the package: `sudo dpkg -i makeswap-on-azure.service.deb`
 4. Kick off the service with one of these:
 	* Enable and reboot: `sudo systemctl enable makeswap-on-azure.service`
	* Or start and don't reboot: `sudo systemctl start makeswap-on-azure.service`
 
# Removal or Disable
* `dpkg -r makeswap-on-azure.service`
* `sudo systemctl disable makeswap-on-azure.service`
 
# Usage
The swap size is dynamically determined, loosely based around the table on the [Ubuntu SwapSize FAQ](https://help.ubuntu.com/community/SwapFaq#How_much_swap_do_I_need.3F).

You can set your desired size by writing to this file `/var/local/makeswap-on-azure/swap_size`.

For example:
```
echo 1G > /var/local/makeswap-on-azure/swap_size
sudo systemctl restart makeswap-on-azure.service
```

The value can be something like:
   * 1024K
   * 2048M
   * 3.5G