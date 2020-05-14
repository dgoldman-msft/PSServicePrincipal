# Description

This is a PowerShell module that will help in the creation (single and batch) entperise, registered applications and service principals to be used with Microsoft Exchange application development with use with Basic Authentication deprecation. All Azure applications can be used with all applications needed authentication against Office 365 and Azure tenants.

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
