# Google Fiber Business Static IP Blocks With UniFi
A PowerShell 5.1–compatible script designed to enable Google Fiber static IP blocks on UniFi equipment that connects to a UniFi controller over SSH (via Posh-SSH), checks for a specific crontab entry, and—if missing—can insert it and reboot the device.

You may also follow the step-by-step guide below to manually apply the necessary changes to your equipment, instead of using the script provided in this repository.

https://github.com/xkodyhuskyx/gfiberwithunifi/wiki/Manual-Setup-(Without-Using-Script)

## !! WARNING !!
Read the [Disclaimer](https://github.com/xkodyhuskyx/gfiberwithunifi/blob/main/DISCLAIMER.md) before performing any actions or using this script!! Back up your controller configurations!!!

## Supported Devices
This script has only been tested on the following devices:

| Machine Name | Code Name | Firmware |
| :--- | :---: | :---: |
| [Unifi Dream Machine Pro Special Edition](https://store.ui.com/products/udm-se?ref_id=github) | UDM-SE | 4.3.6 |
| [UniFi Dream Machine Pro](https://store.ui.com/products/udm-pro) | UDM-PRO | 4.3.6 |
| [UniFi Dream Machine](https://store.ui.com/products/udm) | UDM | 4.3.6 |
| [UniFi Dream Router 7](https://store.ui.com/products/udr7) | UDR7 | 4.3.9 |
| [UniFi Dream Router](https://store.ui.com/products/udr) | UDR | 4.3.9 |


Note: While it has been verified to function with these devices, it is not guaranteed to work on all devices or configurations. Please proceed with caution and at your own risk.

## Prerequisites
For this script to function correctly, you must have the following configured on your unifi equipment prior to running the script:

- Internet must be configured on your UniFi controller with the following:
  - Port: `Choose The WAN Port For Your Connection`
  - IPv4 Connection: `Static IP`
  - IPv4 Address: `Primary Address Provided By Google Fiber`
  - Subnet Mask: `Provided By Google Fiber`
  - Gateway IP: `Provided By Google Fiber`
  - Additional IP Addresses: `Block Of Addresses Provided By Google Fiber (XXX.XXX.XXX.XXX/XX)`
  - Enable IPv6 (optional):
    - IPv6 Connection: `SLAAC`
    - IPv6 Type: `Prefix Delegation`
    - Prefix Delegation Size: `56` (This May Or May Not Work For Your Connection)
- SSH must be configured and enabled on your UniFi equipment. (Default username is root)

If you are unsure how to configure any of the settings mentioned above, please refer to Step 1 and Step 2 in the [manual setup guide](https://github.com/xkodyhuskyx/gfiberwithunifi/wiki/Manual-Setup-(Without-Using-Script)) for detailed instructions.

## Script Usage

Download and extract this repository to a location on your computer. Once extracted, launch the script using PowerShell 5.1, which is the default version included with Windows 10 and Windows 11.

If you encounter an Execution Policy error when attempting to run the script, you can bypass it by launching the script with the following command:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "Unifi_Script.ps1"
```

## Notes

If you choose to follow this guide or use the provided script, I recommend disabling automatic firmware updates on your UniFi equipment. Updating or resetting your UniFi controller will remove the changes made by this script. If you update your equipment you must re-run this script to restore the changes.
