<#
.SYNOPSIS
InstallDDC01.ps1 - Script for installing Citrix XenDesktop.

.DESCRIPTION
This script installs Citrix XenDesktop by reading the JSON configuration file and setting the necessary arguments. 
It starts the installation, installs Group Policy Management, stops logging, and restarts the computer.

.PARAMETER None

.INPUTS
None

.OUTPUTS
None

.EXAMPLE
.\InstallDDC01.ps1

.NOTES
    - This script requires a JSON configuration file named "ConfigurationVariables.json" to be present in the parent directory.
    - The script logs the installation process to a log file located in the system's temporary directory.
    - The script restarts the computer after installation. 

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/XenDesktop/InstallDDC01.ps1
#>
$Vendor = "Citrix"
$Product = "XenDesktop"

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$PackageName = $ConVarJson.AppInstallers.packagenameXenDesktop
$UnattendedArgs = $ConVarJson.UnattendedArguments.unattendedargsConStudio
$InstallShare = $ConVarJson.Common.InstallShare

# ----- DO NOT EDIT BELOW THIS LINE -----

Write-Verbose "Setting Arguments" -Verbose

$env:SEE_MASK_NOZONECHECKS = 1

$StartDTM = (Get-Date)

$InstallerType = "EXE"

$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product PS Wrapper.log"

Start-Transcript $LogPS

Write-Verbose "Starting Installation of $Vendor $Product" -Verbose

change user /install

(Start-Process "$InstallShare\XenDesktop\x64\XenDesktop Setup\$PackageName.$InstallerType" $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Installing Group Policy Management"
Install-WindowsFeature -Name "GPMC" -Verbose

change user /execute

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Restart-Computer -Force

Stop-Transcript