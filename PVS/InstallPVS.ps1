<#
.SYNOPSIS
    Installs Citrix Provisioning Services Console and Server.

.DESCRIPTION
    This script installs Citrix Provisioning Services Console and Server using the configuration specified in a JSON file.
    It sets necessary environment variables, logs the installation process, and restarts the computer upon completion.

.PARAMETER Vendor
    The vendor name, which is "Citrix".

.PARAMETER Product
    The product name, which is "Provisioning Services Console and Server".

.EXAMPLE
    .\InstallPVS.ps1
    This command runs the script to install Citrix Provisioning Services Console and Server.

.NOTES
    - Ensure that the ConfigurationVariables.json file is present in the same directory as the script.
    - The script requires administrative privileges to run.
    - The script will restart the computer upon completion.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/PVS/InstallPVS.ps1

#>
$Vendor = "Citrix"
$Product = "Provisioning Services Console and Server"

Write-Verbose "Reading JSON Configuration file" -Verbose
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$PackageNameConsole = $ConVarJson.AppInstallers.packagenamePVSConsole
$PackageNameServer = $ConVarJson.AppInstallers.packagenamePVSServer
$UnattendedArgsEXE = $ConVarJson.UnattendedArguments.unattendedargsEXE
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

Write-Verbose "Installing Citrix PVS Console and Server"

Write-Verbose "Installing Citrix PVS Console" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Console\$PackageNameConsole.$InstallerType" $UnattendedArgsEXE -Wait -Passthru).ExitCode

Write-Verbose "Installing Citrix PVS Server" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\$PackageNameServer.$InstallerType" $UnattendedArgsEXE -Wait -Passthru).ExitCode

Write-Verbose "Customization" -Verbose

change user /execute

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript

Restart-Computer -Force