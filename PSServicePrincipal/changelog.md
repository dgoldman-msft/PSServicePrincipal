# Changelog
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