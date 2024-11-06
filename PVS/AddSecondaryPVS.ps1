<#
.SYNOPSIS
    Script to automate the addition of a secondary PVS server to a Citrix Provisioning Services (PVS) farm.

.DESCRIPTION
    This script reads configuration variables from a JSON file, imports the necessary Citrix PVS module, 
    disables the Windows Firewall, copies the PVS configuration wizard file, creates a new SMB share for vDisks, 
    and runs the PVS configuration wizard to connect to the newly created database. 
    It also logs the process and calculates the elapsed time for the operation.

.PARAMETER Vendor
    The vendor name, in this case, "Citrix".

.PARAMETER Product
    The product name, in this case, "PVS Configuration".

.NOTES
    The script requires the Citrix Provisioning Services Console to be installed and the necessary 
    Citrix.PVS.SnapIn.dll module to be available.
    The script restarts the computer after completing the installations.

.EXAMPLE
    .\AddSecondaryPVS.ps1
    This example runs the script to add a secondary PVS server to the farm using the configuration specified 
    in the ConfigurationVariables.json file.
.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/PVS/AddSecondaryPVS.ps1
#>

$Vendor = "Citrix"
$Product = "PVS Configuration"

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$PVSConfigWizardCopyFile = $ConVarJson.PVS.PVSConfigWizardSecondaryFile
$PVSConfigWizardPath = $ConVarJson.PVS.PVSConfigWizardPath
$PVSConfigWizardLog = $ConVarJson.PVS.PVSConfigWizardLog
$PVSPassphrase = $ConVarJson.PVS.PVSPassphrase
$vDisk = $ConVarJson.PVS.vDisk

Write-Verbose "Importing PVS module" -Verbose
Import-Module "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll"

Write-Verbose "Setting Arguments" -Verbose

$env:SEE_MASK_NOZONECHECKS = 1

$StartDTM = (Get-Date)

$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product PS Wrapper.log"

Start-Transcript $LogPS

Write-Verbose "$Vendor $Product" -Verbose

Write-Verbose "Disable Windows Firewall on all Profiles"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Write-Verbose "Adding secondary PVS server to farm" -Verbose

Copy-Item -Path "$PVSConfigWizardCopyFile" -Destination "$PVSConfigWizardPath\ConfigWizard.ans" -force
New-Item -Path $vDisk -ItemType Directory
New-SMBShare -Name "vDisks" -Path "$vDisk" -FullAccess Everyone

Write-Verbose "ConfigWizard to connect to newly created database" -Verbose
. "C:\Program Files\Citrix\Provisioning Services\ConfigWizard.exe" /a /P:$PVSPassphrase /O:$PVSConfigWizardLog -Verbose

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript

Restart-Computer -Force