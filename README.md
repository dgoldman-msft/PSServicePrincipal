﻿# Description

This is a PowerShell module that will help in the creation (single and batch) enterprise, registered applications / service principals to be used with Microsoft application development. Application that connect to Office 365 will no longer be able to use Basic Authentication because it is being deprecated. This means that PowerShell will need a secure way to connect (interactively and automated) to Azure applications. For application workloads that require CBA (Certificate Based Authentication) (I.E Microsoft Exchange PowerShell) you can use this module to automate the onboarding of the necessary requirements that will allow you to connect using certificates. This method cuts down the 10-15 minutes of manual creation to just under a minute for single application creation.

> NOTE: Due to incompatibility issues with the AzureAD module and PowerShell core at this time this module will only run on Windows PowerShell 5.X. If you try to run this on Module on PowerShell core it will partial run but you will not be able to create service principals and applications and will receive the following error: At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6 to create Registered Applications. Once the AzureAD module is PowerShell compatible this module will be updated accordingly.

### Getting Started with PSServicePrincipal

1. First open a new PowerShell console as 'Administrator' and run the following command:

```powershell
Install-Module -Name PSServicePrincipal
```

> This will install the PSServicePrincipal module into your local PowerShell module path.

2. Run the following command:

```powershell
Import-Module PSServicePrincipal
```

> This will import the PSServicePrincipal module into your local PowerShell session. If you have any problems you can download the nupkg file directly from the PowerShell Gallery: https://www.powershellgallery.com/packages/PSServicePrincipal/1.0.11

At this point you have installed and loaded the PSServicePrincipal module and you are ready to create new service principals.

### Example

```powershell
1. Open PowerShell as an administrator
2. New-ServicePrincipalObject -DisplayName 'ExchangeCBAApp' -RegisteredApp -Cba -CreateSingleObject
```

In the above example we will create a new service principal object in the Azure tenant with a display name of 'ExchangeCBAApp', and we are passing in three argument switches. These three switches instruct the PSServicePrincipal module to do the following:

1. -RegisteredApp will create a registered Azure application (different from an Azure enterprise application).
2. -Cba will perform the following steps:
  a. Create a Self-Signed certificate (which will be stored locally as uploaded to the newly created Azure application. You just supply a DNS name and password for the certificate.
  b. Export the certificate (.pfx and .cer) files to your drive.
  c. Import the certificate to your local user certificate store.
  d. Import the certificate thumbprint to your newly created registered Azure tenant application.
  e. Apply the necessary api rights (Exchange.ManageAsApp) permissions to your application. (This is needed for unattended automation)
3. -CreateSingleObjectCreate will make sure we create a single service principal object (different from batch creation).

> This will allow for a local interactive PowerShell session to connect to Exchange Online via CBA. If your intent is to use unattended automation you will need to copy the certificate from the local user certificate store to the computer's localMachine certificate store.

The last step you need to do is manually verify the settings and grant consent to the application to allow access.

1. Select the 'Azure Active Directory' option
2. Select 'App Registrations'
3. Select your application from the application list
4. Select Certificates & secrets and verify the certificate thumbprint has been added successfully.
5. Select 'API Permissions' to verify that 'Exchange.ManageAsApp' has been added successfully.
6. Select 'Grant Admin Consent for 'YourDomain' (Default Directory).

> This will apply the permissions to the application in the tenant. Please allow up to 2 hours for Azure AD replication to take effect.

7. Add your application to an Azure security RBAC role that you want your application to have rights for. (This is based on your security model).
