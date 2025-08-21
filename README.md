# Google Fiber Business Static IP Blocks With UniFi
A PowerShell 5.1–compatible script designed to enable Google Fiber static IP blocks on UniFi equipment that connects to a UniFi controller over SSH (via Posh-SSH), checks for a specific crontab entry, and—if missing—can insert it and reboot the device.

# !! WARNING !!
Read the Disclaimer before performing any actions or using this script!! Back up your controller configurations!!!

This is still in development and the documentation has not been fully created yet. Use at your own risk!

## Supported Devices
This script has only been tested on the following devices:

- UniFi Dream Machine Pro Special Edition (FW 4.3.6)
- UniFi Dream Machine Pro (FW 4.3.6)

Note: While it has been verified to function with these devices, it is not guaranteed to work on all devices or configurations. Please proceed with caution and at your own risk.

## Prerequisites
For this script to function, you must have the following set on your unifi equipment before running the script:

- SSH must be enabled with a known password. (Default username for the UDM-SE is root)
- Internet must be configured on your UniFi controller with the following:
  - IPv4 Connection: Static IP
  - IPv4 Address: Provided by Google Fiber
  - Subnet Mask: Provided by Google Fiber
  - Gateway IP: Provided by Google Fiber
  - Additional IP Addresses: Block of Addresses Provided by Google Fiber
- Enabling IPv6 (optional):
  - IPv6 Connection: SLAAC
  - IPv6 Type: Prefix Delegation
  - Prefix Delegation Size: 56
 
## Notes

Updating or resetting your UniFi controller will remove the changes made by this script. If you update your equipment you must re-run this script to restore the changes.


## Manual Setup (Without Using Script)

 Please follow the guide at https://github.com/xkodyhuskyx/gfiberwithunifi/wiki/Manual-Setup-(Without-Using-Script)
