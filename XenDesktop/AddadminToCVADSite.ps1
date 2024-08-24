<#
.SYNOPSIS
Adds an administrator to a Citrix Virtual Apps and Desktops (CVAD) site.

.DESCRIPTION
This script adds an administrator to a CVAD site by reading the configuration variables from a JSON file and using the Citrix PowerShell cmdlets. 
It creates a new administrator with the specified name and assigns the specified role and scope to the administrator.

.PARAMETER LogPS
Specifies the path where the log file will be created.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
.\AddadminToCVADSite.ps1

.NOTES
    - This script requires a JSON configuration file named "ConfigurationVariables.json" to be present in the parent directory.
    - The script logs the process to a log file located in the system's temporary directory.
    - The script uses the Citrix PowerShell cmdlets to add an administrator to a CVAD site.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/Installscripts/XenDesktop/AddadminToCVADSite.ps1
#>

$logPS = "C:\Windows\Temp\AddAdminToCVADSite.log"

$env:SEE_MASK_NOZONECHECKS = 1

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$siteadminDomainAdmins = $ConVarJson.XenDesktop.SiteAdmin_DomainAdmin
$siteroleFullAdmin = $ConVarJson.XenDesktop.SiteRoleFullAdmin
$siteScope = $ConVarJson.XenDesktop.SiteScope

Start-Transcript $LogPS


Add-PSSnapin Citrix.*

New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name "$siteadminDomainAdmins"
Add-AdminRight -Administrator "$siteadminDomainAdmins" -Role "$siteroleFullAdmin" -Scope "$siteScope"

Write-Verbose "Stop logging" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript