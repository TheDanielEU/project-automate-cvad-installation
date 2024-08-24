<#
.SYNOPSIS
Configures XenDesktop Site using the provided JSON configuration file.

.DESCRIPTION
This script configures a XenDesktop Site by reading the JSON configuration file and setting the necessary variables. 
It creates Citrix databases, creates a new Citrix Site, configures the Site, and performs other configuration tasks.

.PARAMETER None

.INPUTS
None

.OUTPUTS
None

.EXAMPLE
.\XenDesktop_Configure.ps1

.NOTES
    - This script requires a JSON configuration file named "ConfigurationVariables.json" to be present in the parent directory.
    - The script logs the configuration process to a log file located in the system's temporary directory.
    - The script uses the Citrix PowerShell cmdlets to configure a XenDesktop Site.
    - The script must be executed from a Delivery Controller.
    - Sets trust requests sent to the XML service port to true.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/XenDesktop/XenDesktop_Configure.ps1
#>

$LogPS = "C:\Windows\Temp\Configure_XenDesktop_Site.log"

Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

Write-Verbose "Setting Arguments" -Verbose

$env:SEE_MASK_NOZONECHECKS = 1

$StartDTM = (Get-Date)

Start-Transcript $LogPS

Write-Verbose "Setting Variables" -Verbose

$DatabaseServer = $ConVarJson.XenDesktop.DatabaseServer
$DatabaseName_Site = $ConVarJson.XenDesktop.DatabaseName_Site
$DatabaseName_Logging = $ConVarJson.XenDesktop.DatabaseName_Logging
$DatabaseName_Monitor = $ConVarJson.XenDesktop.DatabaseName_Monitor
$DatabaseUser = $ConVarJson.XenDesktop.DatabaseUser
$DatabasePassword = $ConVarJson.XenDesktop.DatabasePassword
$XDSite = $ConVarJson.XenDesktop.XDSite
$LicenseServer = $ConVarJson.XenDesktop.LicenseServer
$LicenseServer_LicensingModel = $ConVarJson.XenDesktop.LicenseServer_LicensingModel
$LicenseServer_ProductCode = $ConVarJson.XenDesktop.LicenseServer_ProductCode
$LicenseServer_ProductEdition = $ConVarJson.XenDesktop.LicenseServer_ProductEdition
$LicenseServer_Port = $ConVarJson.XenDesktop.LicenseServer_Port
$LicenseServer_ProductVersion = $ConVarJson.XenDesktop.LicenseServer_ProductVersion
$LicenseServer_AddressType = $ConVarJson.XenDesktop.LicenseServer_AddressType

Write-Verbose "Setting DB user and pw" -Verbose

$DatabasePassword = $DatabasePassword | ConvertTo-SecureString -asPlainText -Force
$Database_CredObject = New-Object System.Management.Automation.PSCredential($DatabaseUser,$DatabasePassword)

Write-Verbose "Add Citrix Snapin" -Verbose

Add-PSSnapin Citrix*

Write-Verbose "Creating Citrix databases on $DatabaseServer" -Verbose
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XDSite -DataStore Site -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Site -DatabaseCredentials $Database_CredObject -Verbose
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XDSite -DataStore Logging -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Logging -DatabaseCredentials $Database_CredObject -Verbose
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XDSite -DataStore Monitor -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Monitor -DatabaseCredentials $Database_CredObject -Verbose

Write-Verbose "Creating new Citrix $XDSite Site" -Verbose
New-XDSite -AdminAddress $env:COMPUTERNAME -SiteName $XDSite -DatabaseServer $DatabaseServer -LoggingDatabaseName $DatabaseName_Logging -MonitorDatabaseName $DatabaseName_Monitor -SiteDatabaseName $DatabaseName_Site

Write-Verbose "Configuring $XDSite Site" -Verbose
Set-ConfigSite -AdminAddress $env:COMPUTERNAME -LicenseServerName $LicenseServer -LicenseServerPort $LicenseServer_Port -LicensingModel $LicenseServer_LicensingModel -ProductCode $LicenseServer_ProductCode -ProductEdition $LicenseServer_ProductEdition -ProductVersion $LicenseServer_ProductVersion

$LicenseServer_AdminAddress = Get-LicLocation -AddressType $LicenseServer_AddressType -LicenseServerAddress $LicenseServer -LicenseServerPort $LicenseServer_Port
$LicenseServer_CertificateHash = $(Get-LicCertificate  -AdminAddress $LicenseServer_AdminAddress).CertHash
Write-Verbose "Configuring certificate" -Verbose
Set-ConfigSiteMetadata -AdminAddress $env:COMPUTERNAME -Name "CertificateHash" -Value $LicenseServer_CertificateHash
Write-Verbose "XML Port Trust TRUE" -Verbose
Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $true

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose

Remove-Item env:\SEE_MASK_NOZONECHECKS

Stop-Transcript
