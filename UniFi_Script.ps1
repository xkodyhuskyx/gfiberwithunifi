# -------------------------------------------------------------
# UniFi modification script for Google Fiber static blocks
# Script version: 1.0       Script created by: xkodyhuskyx
# -------------------------------------------------------------
# 
# This script is designed to configure UniFi equipment to send
# DHCP requests to Google Fiber while having your equipment
# configured for a static IP address block.
#
# Note: This script requires Powershell version 5.1
#
# -------------------------------------------------------------
#
# This script is provided "AS IS" without warranty of any kind,
# express or implied. The author (xkodyhuskyx) shall not be
# held liable for any damages, loss of data, system outages, or
# any other consequences resulting from the use, misuse, or
# inability to use this script. Use at your own risk.
#
# https://github.com/xkodyhuskyx/gfiberwithunifi/
#
# -------------------------------------------------------------



# ------------------ Check Powershell Version -----------------
if ($PSVersionTable.PSVersion.Major -ne 5 -or $PSVersionTable.PSVersion.Minor -ne 1) {
    Write-Host "Error: This script requires PowerShell version 5.1." -ForegroundColor Red
    exit 1
}



# ----------------- Powershell Setup ----------------
$Host.UI.RawUI.WindowTitle = "UniFi Modification Script v1.0"
Clear-Host
function Write-MultiColor {
    param([Parameter(Mandatory)][string[]]$Text,[Parameter(Mandatory)][ConsoleColor[]]$Color)
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Color[$i % $Color.Length]
        Write-Host $Text[$i] -ForegroundColor $c -NoNewline
    }
    Write-Host ""
}
function Check-IPv4([string]$Prompt) {
    if ($Prompt -match '^(?:\d{1,3}\.){3}\d{1,3}$') { return $true }
    return $false
}
function Read-Host-Required([string]$Prompt, [bool]$Secured = $false) {
    while ($true) {
        if ($secured) {
            $in = Read-Host $Prompt -AsSecureString
            if (-not ($in.Length -eq 0)) { return $in }
        } else {
            $in = Read-Host $Prompt
            if (-not [string]::IsNullOrWhiteSpace($in)) { return $in }
        }
        Write-Warning "This field is required. Please enter a value."
    }
}



# ---------------------- Define Script Variables ----------------------
$scriptdisclaimer = @"
This script is provided "AS IS" without warranty of any kind,
express or implied. The author shall not be held liable for
any damages, loss of data, system outages, or any other
consequences resulting from the use, misuse, or inability to
use this script. Use at your own risk.

Only use this script if you fully understand the changes that
will be made to your equipment, have fully read the README and
DISCLAIMER available at
https://github.com/xkodyhuskyx/gfiberwithunifi, and have made
a complete backup of your UniFi configuration!!
"@
$unifidisclaimer = @"
By logging in to, accessing, or using any Ubiquiti product, you
are signifying that you have read our Terms of Service (ToS)
and End User License Agreement (EULA), understand their terms,
and agree to be fully bound to them. The use of CLI (Command
Line Interface) can potentially harm Ubiquiti devices and
result in lost access to them and their data. By proceeding,
you acknowledge that the use of CLI to modify device(s) outside
of their normal operational scope, or in any manner
inconsistent with the ToS or EULA, will permanently and
irrevocably void any applicable warranty.
"@
$banner = @"
__  ___  _____  ______   ___   _ _   _ ____  _  ____   ____  __
\ \/ / |/ / _ \|  _ \ \ / / | | | | | / ___|| |/ /\ \ / /\ \/ /
 \  /| ' / | | | | | \ V /| |_| | | | \___ \| ' /  \ V /  \  / 
 /  \| . \ |_| | |_| || | |  _  | |_| |___) | . \   | |   /  \ 
/_/\_\_|\_\___/|____/ |_| |_| |_|\___/|____/|_|\_\  |_|  /_/\_\
"@
$bannersubtitle = @"
  UniFi Modification Script For Google Fiber Static IP Blocks
       https://github.com/xkodyhuskyx/gfiberwithunifi/
"@
$divider = "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"



function Write-Header() {
    Write-MultiColor -Text "$divider`n","$banner`n`n","$bannersubtitle`n" -Color DarkMagenta,Blue,Green
    Write-MultiColor -Text "Script Version: ","1.0","                    Designed by: ","xkodyhuskyx" -Color White,Yellow,White,Yellow
    Write-Host "$divider" -ForegroundColor DarkMagenta
}
function Disconnect-Exit() {
    Clear-Host
    Write-Header
    Write-MultiColor -Text "Connection Status: ","DISCONNECTED                 ","Session ID: ","N/A" -Color White,Red,White,Red
    Write-Host "$divider`n" -ForegroundColor Magenta
    Write-Host "Disconnecting from UniFi Controller...`n" -ForegroundColor White
    if ($null -ne $session -and $session.SessionId) {
        try { Remove-SSHSession -SessionId $session.SessionId | Out-Null } catch { }
    }
    Write-Host "Exiting..." -ForegroundColor White
    exit 0
}



# ------------------------- Script Disclaimer ------------------------
Write-Header
Write-Host "`nSCRIPT DISCLAIMER:`n`n$scriptdisclaimer`n" -ForegroundColor Yellow
Write-MultiColor -Text "Type ","I AGREE"," to accept or anything else to decline.`n" -Color White,Cyan,White
$consent = Read-Host "Response"
if ($consent -ne "I AGREE") {
    Write-Host "`nYou did not accept the disclaimer. Exiting...`n" -ForegroundColor Red
    exit 1
}
Clear-Host



# ------------------------- UniFi Disclaimer ------------------------
Write-Header
Write-Host "`nUNIFI DISCLAIMER:`n`n$unifidisclaimer`n" -ForegroundColor Yellow
Write-MultiColor -Text "Type ","I AGREE"," to accept or anything else to decline.`n" -Color White,Cyan,White
$consent = Read-Host "Response"
if ($consent -ne "I AGREE") {
    Write-Host "`nYou did not accept the disclaimer. Exiting...`n" -ForegroundColor Red
    exit 1
}
Clear-Host



# ------------------------- Load Required Modules ------------------------
Write-Header
Write-Host "`nPlease accept all module prompts.`n" -ForegroundColor Yellow
Write-Host "Loading required powershell modules...`n" -ForegroundColor White
Write-Host "Installing Posh-SSH Module..." -ForegroundColor White
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    try {
        Install-Module Posh-SSH -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "Posh-SSH Module sucessfully installed.`n" -ForegroundColor Green
    } catch {
        Write-Error "Couldn't install Posh-SSH for current user:`n$($_.Exception.Message)"
        Write-Host "`nExiting..." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Posh-SSH Module already installed.`n" -ForegroundColor Green
}
Write-Host "Importing Posh-SSH Module..." -ForegroundColor White
try {
    Import-Module Posh-SSH -ErrorAction Stop
    Write-Host "Posh-SSH Module sucessfully imported.`n" -ForegroundColor Green
} catch {
    Write-Error "Couldn't import Posh-SSH module.`n$($_.Exception.Message)"
    Write-Host "`nExiting..." -ForegroundColor Red
}
Write-Host "Continuing to credential prompts...`n" -ForegroundColor Yellow
Start-Sleep -Seconds 2



# ------------------------- Log On to UniFi Controller ------------------------
while ($true) {
    Clear-Host
    Write-Header
    Write-Host "`nUse the following prompts to enter host and login information`nfor your UniFi controller.`n" -ForegroundColor Yellow
    $UnifiControllerHost = Read-Host-Required "UniFi Controller Host"
    $UnifiControllerUser = Read-Host-Required "UniFi Controller Username"
    $UnifiControllerPass = Read-Host-Required "UniFi Controller Password" $true
    Write-Host "`nInitializing Connection to UniFi Controller...`n" -ForegroundColor Yellow
    Write-Host "Starting DNS Resolution..."
    if (-not (Check-IPv4 $UnifiControllerHost)) {
        try {
            $UnifiControllerIPv4 = [System.Net.Dns]::GetHostAddresses($UnifiControllerHost) | Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork }
            Write-Host "DNS resolution succeeded for $UnifiControllerHost ($UnifiControllerIPv4)`n" -ForegroundColor Green
        } catch {
            Write-Host "DNS resolution failed for $UnifiControllerHost. `n$($_.Exception.Message)`n" -ForegroundColor Red
            Write-Host "Please wait to re-enter information..." -ForegroundColor Yellow
            Start-Sleep -Seconds 7
            continue
        }
    } else {
        Write-Host "DNS resolution not required.`n" -ForegroundColor Green
        $UnifiControllerIPv4 = $UnifiControllerHost
    }
    Write-Host "Checking connection to TCP Port 22 on $UnifiControllerIPv4..."
    $ProgressPreference = 'SilentlyContinue'
    $tcpOk = Test-NetConnection -ComputerName $UnifiControllerIPv4 -Port 22 -InformationLevel Quiet
    if (-not $tcpOk) {
        Write-Host "TCP Port 22 not reachable on $UnifiControllerIPv4.`n" -ForegroundColor Red
        Write-Host "Please wait to re-enter information..." -ForegroundColor Yellow
        Start-Sleep -Seconds 7
        continue
    }
    Write-Host "TCP Port 22 is reachable on $UnifiControllerIPv4`n" -ForegroundColor Green
    Write-Host "Starting SSH Connection..."
    try {
        $UnifiCred = New-Object System.Management.Automation.PSCredential ($UnifiControllerUser, $UnifiControllerPass)
        $session = New-SSHSession -ComputerName $UnifiControllerIPv4 -Credential $UnifiCred -Port 22 -AcceptKey -ErrorAction Stop
        if ($session -is [System.Array]) { $session = $session[0] }
        if ($null -ne $session -and $session.Connected) {
            Write-Host "SSH connection successful to $UnifiControllerIPv4 (SessionId: $($session.SessionId))`n" -ForegroundColor Green
            Write-Host "Continuing to Network selection in 5 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            break
        } else {
            $state = if ($null -ne $session) { "Connected=$($session.Connected); Host=$($session.Host)" } else { "No session object returned" }
            Write-Host "SSH connection failed: session not connected.`n($state)`n" -ForegroundColor Red
            Write-Host "Please wait to re-enter information..." -ForegroundColor Yellow
            Start-Sleep -Seconds 7
            continue
        }
    } catch {
        Write-Host "SSH connection threw an error:`n$($_.Exception.Message)`n" -ForegroundColor Red
        Write-Host "Please wait to re-enter information..." -ForegroundColor Yellow
        Start-Sleep -Seconds 7
        continue
    }
}


# ------------------------- Get Device and IP Information ------------------------
Clear-Host
Write-Header
Write-MultiColor -Text "Connection Status: ","CONNECTED                      ","Session ID: ","$($session.SessionId)" -Color White,Green,White,Green
Write-Host "$divider`n" -ForegroundColor Magenta
Write-Host "Please select the interface containing your primary static IP`naddress from the list below:`n" -ForegroundColor Yellow
$linuxCmd = @'
ip -o -4 addr show | awk '{split($4,a,"/"); ip=a[1]; if (ip !~ /^127\./ && ip !~ /^10\./ && ip !~ /^172\.(1[6-9]|2[0-9]|3[0-1])\./ && ip !~ /^192\.168\./ && ip !~ /^169\.254\./) print $2, ip}'
'@
$resp = Invoke-SSHCommand -Index $session.SessionId -Command $linuxCmd
if ($resp.ExitStatus -ne 0) {
    Write-Host "Remote command failed (exit $($resp.ExitStatus)). STDERR:`n$($resp.Error)`n`nExiting..." -ForegroundColor Red
    Start-Sleep -Seconds 5
    Disconnect-Exit
}
$Adapters = @()
foreach ($line in $resp.Output) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split '\s+'
    if ($parts.Count -ge 2) {
        $Adapters += [pscustomobject]@{ Interface = $parts[0]; IPv4 = $parts[1] }
    }
}
if ($Adapters.Count -eq 0) {
    Write-Host "No eligible IPv4 interfaces found on the UniFi controller.`n`nExiting..." -ForegroundColor Red
    Start-Sleep -Seconds 5
    Disconnect-Exit
}
for ($i = 0; $i -lt $Adapters.Count; $i++) {
    Write-Host ("[{0}] {1,-12} {2}" -f ($i + 1), $Adapters[$i].Interface, $Adapters[$i].IPv4)
}
function Read-Selection([int]$min, [int]$max) {
    while ($true) {
        $raw = Read-Host ("`nEnter a number {0}-{1}" -f $min, $max)
        $n = 0
        if ([int]::TryParse($raw, [ref]$n)) {
            if ($n -ge $min -and $n -le $max) { return $n }
        }
        Write-Host "Invalid selection. Please try again." -ForegroundColor Yellow
    }
}
$choice = Read-Selection 1 $Adapters.Count
$Selected = $Adapters[$choice - 1]
$SelectedInterface = $Selected.Interface
$SelectedIPv4      = $Selected.IPv4
Write-Host ("Selected adapter {0} with address {1}.`n" -f $SelectedInterface, $SelectedIPv4) -ForegroundColor Green
Write-Host "Continuing in 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5



# ------------------------- Configure Equipment ------------------------
Clear-Host
Write-Header
Write-MultiColor -Text "Connection Status: ","CONNECTED                      ","Session ID: ","$($session.SessionId)" -Color White,Green,White,Green
Write-Host "$divider`n" -ForegroundColor Magenta
Write-Host "Checking for existing CRON job..." -ForegroundColor White
$cronjob = "@reboot sleep 60 && /usr/bin/busybox-legacy/udhcpc --foreground --interface $SelectedInterface --script /usr/share/ubios-udapi-server/ubios-udhcpc-script -r $SelectedIPv4 >/var/log/udhcpc.log 2>&1 &"
$cmdSearch  = "crontab -l 2>/dev/null | grep '$cronjob'"
$resp = Invoke-SSHCommand -Index $session.SessionId -Command $cmdSearch -ErrorAction Stop
if ($resp.ExitStatus -eq 0) {
    Write-Host "The CRON entry has already been installed.`n" -ForegroundColor Green
    $ans = Read-Host "Would you like to reboot your UniFi controller now? (Y/N)"
    if (-not ($ans -match '^(?i:y|yes)$')) {
        Disconnect-Exit
    }
    Invoke-SSHCommand -Index $session.SessionId -Command 'reboot' -ErrorAction SilentlyContinue
    Write-MultiColor -Text "`nYour controller is now rebooting...`n`n","Please allow up to 5 minutes for your UniFi controller to`nreboot.`n" -Color White,Yellow
    Write-Host "Continuing in 10 seconds..." -ForegroundColor White
    Start-Sleep -Seconds 10
    Disconnect-Exit
} else {
    Write-Host "A cron job was not found on your controller.`n" -ForegroundColor Red
    Write-MultiColor -Text "Typing ","install"," will install the following cron job and reboot`nyour UniFi controller. Anything else will exit.`n" -Color Green,Yellow,Green,Yellow
    Write-Host "@reboot sleep 60 && /usr/bin/busybox-legacy/udhcpc --foreground`n--interface $SelectedInterface --script /usr/share/ubios-udapi-server/ubios-u`ndhcpc-script -r $SelectedIPv4 >/var/log/udhcpc.log 2>&1 &`n" -ForegroundColor Blue
    $consent = Read-Host "Response"
    if ($consent -ne "install") {
        Disconnect-Exit
    }
    Write-Host "`nInserting cron line…"
    $insertcron = "(crontab -l; echo '$cronjob') | crontab -"
    $rc = Invoke-SSHCommand -Index $session.SessionId -Command "$insertcron" -ErrorAction SilentlyContinue
    Write-Host "Cron added sucessfully.`n" -ForegroundColor Green
    Write-Host "Rebooting device…"
    Invoke-SSHCommand -Index $session.SessionId -Command 'reboot' -ErrorAction SilentlyContinue
    Write-Host "UniFi controller is rebooting.`n" -ForegroundColor Green
    Write-Host "Your connection should be restored after your UniFi controller`nreboots. If your UniFi controller didn't reboot, you may need`nto reboot it manually.`n" -ForegroundColor Yellow
    Remove-SSHSession -SessionId $session.SessionId | Out-Null
    Write-Host "Exiting in 10 seconds..."
    Start-Sleep -Seconds 10
}
Disconnect-Exit
