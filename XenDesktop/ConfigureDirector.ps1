<#
.SYNOPSIS
Configures Citrix Director by reading a JSON configuration file and modifying the web.config file.

.DESCRIPTION
This script reads a JSON configuration file and retrieves the list of Storefront servers. 
It then uses the DirectorConfig.exe tool to configure Citrix Director with the specified Storefront servers.
After that, it modifies the web.config file to disable SSL check for the Director UI.

.PARAMETER None

.INPUTS
None

.OUTPUTS
None

.EXAMPLE
.\ConfigureDirector.ps1

.NOTES
    - This script requires a JSON configuration file named "ConfigurationVariables.json" to be present in the parent directory.
    - The script configures Citrix Director with the specified Storefront servers and disables SSL check for the Director UI.

.LINK
    https://github.com/TheDanielEU/project-automate-cvad-installation/Installscripts/XenDesktop/ConfigureDirector.ps1
#>
Write-Verbose "Reading JSON Configuration file"
$ConVarJson = Get-Content -Raw .\ConfigurationVariables.json | ConvertFrom-Json

$Servers = $ConVarJson.Storefront.Servers

C:\inetpub\wwwroot\Director\tools\DirectorConfig.exe /ddc "$Servers"

$xml = [xml](Get-Content "C:\inetpub\wwwroot\Director\web.config")
$node = $xml.configuration.appSettings.add | Where-Object {$_.Key -eq 'UI.EnableSslCheck'}
$node.value = "false"   # Change an existing value
$xml.Save("C:\inetpub\wwwroot\Director\web.config")