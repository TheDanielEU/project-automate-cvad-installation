<#
.SYNOPSIS
Join XenDesktop 2 to Site.

.DESCRIPTION
This script adds a secondary Delivery Controller to an existing XenDesktop Site.

.PARAMETER None

.INPUTS
None

.OUTPUTS
None

.EXAMPLE
.\joinXD2toSite.ps1

.NOTES
    - This script requires a JSON configuration file named "ConfigurationVariables.json" to be present in the parent directory.
    - The script logs the joining process to a log file located in the system's temporary directory.
    - The script must be executed from the secondary Delivery Controller.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/XenDesktop/joinDDC02toSite.ps1
#>

$logPS = "C:\Windows\Temp\Join_XenDesktop_Site.log"

$env:SEE_MASK_NOZONECHECKS = 1

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$siteControllerAddress = $ConVarJson.XenDesktop.SiteControllerAddress

Start-Transcript $LogPS
Add-PSSnapin Citrix*

Write-Verbose "Adding $env:COMPUTERNAME to the site" -Verbose
Add-XDController -AdminAddress $env:COMPUTERNAME -SiteControllerAddress "$siteControllerAddress" -Verbose

Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $true

Write-Verbose "Stop logging" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript