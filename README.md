# Description

This is a PowerShell module that will help in the creation (single and batch) entperise, registered applications and service principals to be used with Microsoft Exchange application development with use with Basic Authentication deprecation. All Azure applications can be used with all applications needed authentication against Office 365 and Azure tenants. For applications that require CBA you can also create an exchange application that will also add the necessary roles and upload the certificate directly to the application in the Azure tenant.

One of the biggest highlights of this module is the ability to prepare your tenant application for Certificate Based Authentication for Exchange PowerShell and automation access. 

With regards to the Exchange workload you can run the following command in PowerShell to set your application up for unattended exchange administration using certificate based authentication. One the module is installed from the PowerShell Gallery and imported to your PowerShell session you can do the following:

New-ServicePrincipalObject -DisplayName ‘YourApp’ -RegisteredApp -Cba -CreateSingleObjectCreate 

1.	This will start the process and create a registered Azure application in your tenant.
2.	Create a self-signed certificate. You just supply a DNS name and password for the certificate.
3.	Export the certificate (.pfx and .cer) files to your drive.
4.	Import the certificate to your local user store. 

NOTE: You will need to move the cert to the localMachine store for unattended automation. 

5.	Import the certificate information (most importantly the certificate thumbprint) to your newly created registered Azure tenant application.
6.	Apply the necessary rights (Exchange.ManageAsApp) permissions to your application.

All you need to do is manually log in to your Azure portal and do the following:

7.	‘Grant Consent’ to allow for the permissions to be applied. 
8.	Add your application to the Azure based roll that you want your application to have rights for. (Based on your security model).


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
