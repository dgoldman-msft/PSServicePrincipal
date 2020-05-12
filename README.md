# Description

This is a PowerShell helper module that will aid in the creation and deletion of (single and batch) service principal and applications (enterprise and registered) when used with Microsoft Exchange application development with use with Basic Authentication deprecation. These can also be used with the use of regular 3rd party applications needing service principals and applications in Azure.

Version 1.0.1 - 1.0.4 (Beta test)

New functionality in version 1.0.5
The ability to create single self-signed certificates for applications to be used with Certificate Based Authenticaion (CBA). Certificated are stored in the users personal cert store.
The ability to create enterprise and registered Azure applications and service principals
The ability to remove applications and service principals in pairs

Functionlity for 1.0.6
The ability to upload self-signed certifcates to enterprise and registered applications in Azure
Ability to have certificates created in both certifcate stores (local machine needed to local machine automation)

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
