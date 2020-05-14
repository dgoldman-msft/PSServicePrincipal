# Description

This PowerShell module that will help aid in the creation and deletion of (single and batch) service principal and applications (enterprise and registered) when used with Microsoft Exchange application development with use with Basic Authentication deprecation. These can also be used with the use of regular 3rd party applications needing service principals and applications in Azure.

Version 1.0.10 - Stable release build
Version 1.0.9 - Stable release build
Version 1.0.1 - 1.0.8 (Pre-Release)

New functionality in version 1.0.10
Added MIT license for Fincinal insitution use

New functionality in version 1.0.9
The ability to create single self-signed certificates for applications to be used with Certificate Based Authenticaion (CBA). Certificated are stored in the users personal cert store.
The ability to create enterprise and registered Azure applications and service principals
The ability to remove applications and service principals in pairs

NOTE: When running New-ServicePrincipalObject -CreateSelfSignedCert you must be running PowerShell as an administrator to save certs to the local user cert store.

# Project Setup Instructions
## Working with the layout

 - Don't touch the psm1 file
 - Place functions you export in `functions/` (can have subfolders)
 - Place private/internal functions invisible to the user in `internal/functions` (can have subfolders)
 - Don't add code directly to the `postimport.ps1` or `preimport.ps1`.
   Those files are designed to import other files only.
 - When adding files you load during `preimport.ps1`, be sure to add corresponding entries to `filesBefore.txt`.
   The text files are used as reference when compiling the module during the build script.
 - When adding files you load during `postimport.ps1`, be sure to add corresponding entries to `filesAfter.txt`.
   The text files are used as reference when compiling the module during the build script.

## Setting up CI/CD

> To create a PR validation pipeline, set up tasks like this:

 - Install Prerequisites (PowerShell Task; VSTS-Prerequisites.ps1)
 - Validate (PowerShell Task; VSTS-Validate.ps1)
 - Publish Test Results (Publish Test Results; NUnit format; Run no matter what)

> To create a build/publish pipeline, set up tasks like this:

 - Install Prerequisites (PowerShell Task; VSTS-Prerequisites.ps1)
 - Validate (PowerShell Task; VSTS-Validate.ps1)
 - Build (PowerShell Task; VSTS-Build.ps1)
 - Publish Test Results (Publish Test Results; NUnit format; Run no matter what).
