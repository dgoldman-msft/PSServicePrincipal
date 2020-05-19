# Changelog
## 1.0.11 (2020-05-19)
 - Upd: in PSServicePrincipal.provider.ps1 - Added PSConfig variable for setting certstore location in configuration as a fall back
 - Upd: in New-ServicePrincipal.ps1 - Corrected -Format to -StringValues for PSFWriteMessage variable output
 - New: New code and functions for creating EXO application object (SP) and cert upload to the azure application
 - New: Added code for stamping Exchange permissions for CBA Authentication for EXOv2 cmdlets
 - Upd: in New-ServicePrincipalObject.ps1 - Added new Exo switch, parameter and example as well as code to call in to create self-signed cert as new EXO application object. Aslo remove unneeded extra line spaces
 - Upd: to New-SelfSignedCert.ps1 - Added new Exo switch and EnableExceptions switch, updated code for exchange cert exports and code to create Exo object
 - Upd: documentation in Get-EnterpriseApp.ps1, Get-RegisteredApp.ps1, New-ServicePrincipalObject.ps1,
 - Upd: in configuration.ps1- Added configuration code for Self-Signed Certificate save location
 - Upd: in Get-EnterpriseApp, Get-RegisteredApp, Get-SpnByname, Get-SpnsByName, Get-SpnByAppID, Get-AppAndSPNPair - Added PSF-WriteLog to indicate an item was obtained for log purposes
 - Fix in Connect-ToCloudTenant.ps1 - Added code for manual Reconnect
 - Fix in Get-LogFolder.ps1 - Removed $scriptlogging folder and get value from PSFConfig. We pull from PSFConfig local repository now

## 1.0.10 (2020-05-12)
 - New: Added MIT license
 - Upd: Updated manifest file - increment build number
 - Upd: Updated manifest file - Changed RequireLicenseAcceptance = $false - Breaking PowerShellGet - reverted change
 - Upd: Updated manifest file - Removed 'Get-AppByName' and added 'Get-EnterpriseApp' and 'Get-RegisteredApp'
 - Upd: Updated manifest file - Added tags to manifest file: 'Application', 'Automation' 'Module' 'O365'
 - Upd: Updated documentation - Added links for Azure RBAC documentation
 - Upd: Updated changelog.md
 - Upd: Documnetation in New-ServicePrincipalObject.ps1
 - Upd: Removed internal function Get-AppByName.ps1
 - Upd: Added external function Get-EnterpriseAppByName.ps1
 - Upd: Added external function  Get-RegisteredAppByName.ps1
 - Upd: Added counter for self-signed cert creation output
 - Upd: Counter display in end of script run in New-ServicePrincipalObject.ps1
 - Upd: Added new parameters GetEnterpriseApp and GetRegisteredApp in New-ServicePrincipalObject.ps1
 - Upd: Changed function names from GetAppByName to GetEnterpriseApp
 - Upd: Added new function for GetRegisteredApp
 - Fix: Added KeyExchange for certificates. Needed for Azure CBA authentication to work
 - Fix logging in New-SelfSignedCert to surpress IO.Directory output and now usign custom output from Write-PSFMessage

## 1.0.9 (2020-05-12)
 - New: Ability to create Enterprise and or tenant owned applications with service principals
 - New: New-SelfSignedCert.ps1 - Ability to create self-signed certificates to be used for (CBA) Certificate Based Authentication
 - Upd: Documentation, incremented module version. Added checks for PowerShell core as AzureAD will not work on PowerShell core.
 - Upd: Changed New-SelfSigndCert cert store from LocalMachine to CurrentUser
 - Upd: Updated parameters with regards to CBA login with AzureAD and AzureAZ
 - Upd: Added switches for CBA login
 - Fix: File save for New-SelfSignedCert