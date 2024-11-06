<#
.SYNOPSIS
    Configures Citrix Provisioning Services (PVS) environment.

.DESCRIPTION
    This script automates the configuration of Citrix Provisioning Services (PVS) by reading configuration variables from a JSON file, 
    setting up the SQL database, configuring PVS, and performing necessary system modifications.

.EXAMPLE
    .\ConfigurePVS.ps1
    This example runs the script to configure Citrix Provisioning Services using the settings defined in the ConfigurationVariables.json file.

.NOTES
    The script requires the Citrix Provisioning Services Console to be installed and the necessary 
    Citrix.PVS.SnapIn.dll module to be available.
    The script restarts the computer after completing the installations.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/PVS/ConfigurePVS.ps1
#>
$Vendor = "Citrix"
$Product = "PVS Configuration"

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$PVSAdminGroup = $ConVarJson.PVS.PVSAdminGroup
$PVSDBName = $ConVarJson.PVS.PVSDBName
$PVSSiteName = $ConVarJson.PVS.PVSSiteName
$PVSFarmName = $ConVarJson.PVS.PVSFarmName
$PVSCollectionName = $ConVarJson.PVS.PVSCollectionName
$DBScriptFilePath = $ConVarJson.PVS.DBScriptFilePath
$DBScriptFile = $ConVarJson.PVS.DBScriptFile
$SQLServerName = $ConVarJson.PVS.SQLServerName
$SQLDBScriptRemotePath = $ConVarJson.PVS.SQLDBScriptRemotePath
$PVSConfigWizardCopyFile = $ConVarJson.PVS.PVSConfigWizardPrimaryFile
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

Write-Verbose "Configuring SQL database files and creating new database" -Verbose

Write-Verbose "Creating and exporting SQL DB creation script" -Verbose

Write-Verbose "Installing RSAT" -Verbose
Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
Import-Module -Name ActiveDirectory
$PVSCanonicalName = Get-AdGroup -Identity "$PVSAdminGroup" -Properties canonicalname | Select-Object -ExpandProperty CanonicalName

Write-Verbose "Creating PVS Database $PVSDBName" -Verbose
. "C:\Program Files\Citrix\Provisioning Services\DBscript.exe" -new $PVSDBName $PVSFarmName $PVSSiteName $PVSCollectionName "$PVSCanonicalName"true "$DBScriptFilePath\$DBScriptFile" true

Write-Verbose "Removing RSAT" -Verbose
Remove-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeManagementTools

Copy-Item -Path "$DBScriptFilePath\$DBScriptFile" -Destination "$SQLDBScriptRemotePath"
Invoke-Command -ComputerName "$SQLServerName" -ScriptBlock { sqlcmd -S SQL -i 'C:\DBScript.sql' } -Verbose

Write-Verbose "Disable Windows Firewall on all Profiles"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

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