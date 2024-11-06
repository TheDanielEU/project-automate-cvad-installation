<#
.SYNOPSIS
    Installs Citrix Provisioning Services prerequisites.

.DESCRIPTION
    This script installs various prerequisites for Citrix Provisioning Services,
    including Microsoft Visual C++ Redistributables, Microsoft OLE DB Driver, Citrix Diagnostics Family, Microsoft Edge WebView2 Runtime, 
    Citrix PVS Posh SDK, and Citrix Telemetry Service.

.PARAMETER Vendor
    The vendor name, which is "Citrix".

.PARAMETER Product
    The product name, which is "Provisioning Services Prerequisites".

.NOTES
    The script reads configuration variables from a JSON file named 'ConfigurationVariables.json' located in the same directory as the script.
    The script logs its actions to a log file in the system's Temp directory.
    The script changes the user mode to install mode before starting the installations and reverts it back to execute mode after the installations are complete.
    The script restarts the computer after completing the installations.

.EXAMPLE
    .\InstallPrerequisites.ps1
    This command runs the script to install all the prerequisites for Citrix Provisioning Services.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/PVS/InstallPrerequisites.ps1

#>
$Vendor = "Citrix"
$Product = "Provisioning Services Prerequisites"

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$PackageNameRedist_x64 = $ConVarJson.AppInstallers.packagenameRedist_x64
$PackageNameRedist_x86 = $ConVarJson.AppInstallers.packagenameRedist_x86
$PackageNamemsOLEdbDriver = $ConVarJson.AppInstallers.packagenamemsOLEdbDriver
$PackageNamemsEDGEwebvwr2 = $ConVarJson.AppInstallers.packagenamemsEDGEwebvwr2
$PackageNameCDF_x64 = $ConVarJson.AppInstallers.packagenameCDF_x64
$PackageNameTelemetry = $ConVarJson.AppInstallers.packagenameTelemetry
$PackageNameCitrixPoshSDK = $ConVarJson.AppInstallers.packagenameCitrixPoshSDK

$UnattendedArgsEXE = $ConVarJson.UnattendedArguments.unattendedargsEXE
$UnattendedArgsmsOLEdbDriver = $ConVarJson.UnattendedArguments.unattendedargsmsOLEdbDriver
$UnattendedArgsmsEDGEwebvwr2 = $ConVarJson.UnattendedArguments.unattendedargsmsEDGEwebvwr2
$UnattendedArgsCDF_x64 = $ConVarJson.UnattendedArguments.unattendedargsCDF_x64
$UnattendedArgsTelemetry = $ConVarJson.UnattendedArguments.unattendedargsTelemetry
$UnattendedArgsCitrixPoshSDK = $ConVarJson.UnattendedArguments.unattendedargsCitrixPoshSDK

$InstallShare = $ConVarJson.Common.InstallShare

# ----- DO NOT EDIT BELOW THIS LINE -----

Write-Verbose "Setting Arguments" -Verbose

$env:SEE_MASK_NOZONECHECKS = 1

$StartDTM = (Get-Date)

$InstallerTypeMSI = "MSI"
$InstallerTypeEXE = "EXE"

$LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product PS Wrapper.log"

Start-Transcript $LogPS

Write-Verbose "Starting Installation of $Vendor $Product" -Verbose

change user /install

Write-Verbose "Installing Microsoft Visual C++ 2015-2022 Redistributable (x64)" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{FC8D5946-B78E-4F52-9C56-383172202264}\$PackageNameRedist_x64.$InstallerTypeEXE" $UnattendedArgsEXE -Wait -Passthru).ExitCode

Write-Verbose "Installing Microsoft Visual C++ 2015-2022 Redistributable (x86)" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{FC8D5946-B78E-4F52-9C56-383172202286}\$PackageNameRedist_x86.$InstallerTypeEXE" $UnattendedArgsEXE -Wait -Passthru).ExitCode

Write-Verbose "Installing Microsoft OLE DB Driver" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{A975F81B-8B00-4002-8E57-312MSOLEDB19}\$PackageNamemsOLEdbDriver.$InstallerTypeMSI" $UnattendedArgsmsOLEdbDriver -Wait -Passthru).ExitCode

Write-Verbose "Installing Citrix Diagnostics Family" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{60F3781B-8B00-4002-8E57-3121324DEC7B}\$PackageNameCDF_x64.$InstallerTypeMSI" $UnattendedArgsCDF_x64 -Wait -Passthru).ExitCode

Write-Verbose "Installing Microsoft Edge WebView2 Runtime" -Verbose
(Start-Process "$InstallShare\Prerequisites\$PackageNamemsEDGEwebvwr2.$InstallerTypeEXE" $UnattendedArgsmsEDGEwebvwr2 -Wait -Passthru).ExitCode

Write-Verbose "Installing Citrix PVS Posh SDK" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{1F8AAA3D-DC21-4A1E-1234-6C24843A68E3}\$PackageNameCitrixPoshSDK.$InstallerTypeEXE" $UnattendedArgsCitrixPoshSDK -Wait -Passthru).ExitCode

Write-Verbose "Installing Citrix Telemetry Service" -Verbose
(Start-Process "$InstallShare\Provisioning_Services\Server\ISSetupPrerequisites\{60F3781B-8B00-4002-8E57-3121324DE1FA}\$PackageNameTelemetry.$InstallerTypeMSI" $UnattendedArgsTelemetry -Wait -Passthru).ExitCode

Write-Verbose "Customization" -Verbose

change user /execute

Write-Verbose "Stop logging" -Verbose

$EndDTM = (Get-Date)

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose

Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript

Restart-Computer -Force