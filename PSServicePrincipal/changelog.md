# Changelog
## 1.0.10 (2020-05-12)
 - New: Added MIT license acceptance
 - Upd: Updated module manifest file and increment build number
 - Upd: Updated manifest RequireLicenseAcceptance = $false - Breaking PowerShellGet - reverted change
 - Upd: Added tags to manifest file: 'Application', 'Automation' 'Module' 'O365'
 - Upd: Updated documentation - Added links for Azure RBAC documentation
 - Upd: Updated changelog.md
 - Fix: Added KeyExchange for certificates

## 1.0.9 (2020-05-12)
 - New: Ability to create Enterprise and or tenant owned applications with service principals
 - New: New-SelfSignedCert.ps1 - Ability to create self-signed certificates to be used for (CBA) Certificate Based Authentication
 - Upd: Documentation, incremented module version. Added checks for PowerShell core as AzureAD will not work on PowerShell core.
 - Upd: Changed New-SelfSigndCert cert store from LocalMachine to CurrentUser
 - Upd: Updated parameters with regards to CBA login with AzureAD and AzureAZ
 - Upd: Added switches for CBA login
 - Fix: File save for New-SelfSignedCert