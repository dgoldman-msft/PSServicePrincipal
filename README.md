# Description

This is a PowerShell module that will help in the creation (single and batch) enterpise, registered applications / service principals to be used with Microsoft application development. Application that connect to Office 365 will no longer be able to use Basic Authentication because it is being deprecated. This means that PowerShell will need a secure way to connect (interactively and automated) to Azure applications. For application workloads that require CBA (Certifiate Based Authentication) (I.E Microsoft Exchange PowerShell) you can use this module to automation the onboarding of the necessary requirements that will allow you to connect with using certificates. This method cuts down the 10-15 minutes of manual creation to just under a minute for single application creation.

### Getting Started with PSServicePrincipal
1. First open a new PowerShell console as 'Administrator' and run the following command:
```powershell
Install-Module PSServicePrincipal
```
> This will install the PSServicePrincipal module into your local PowerShell module path.

2. Run the following command:

```powershell
Import-Module PSServicePrincipal
```

> This will import the PSServicePrincipal module in to your local PowerShell session.

At this point you have installed and loaded up the module and you are ready to create your service principals.

##
With regards to the Exchange workload you can run the following command in PowerShell to set your application up for unattended exchange administration using certificate based authentication. 

### Example
```powershell
New-ServicePrincipalObject -DisplayName 'ExchangeCBAApp' -RegisteredApp -Cba -CreateSingleObject
```

In the above example we will create a new service principal object in the Azure tenant with a display name of 'ExchangeCBAApp', and we are passing in three argeument switches. These three switches instuct the PSServicePrincipal module to do the following:

1. -RegisteredApp will create a registered Azure application (different from an Azure enterprise application).
2. -Cba will:
  a. Create a Self-Signed certificate (which will be stored locally as uploaded to the newly created Azure application. You just supply a DNS name and password for the certificate. 
  b. Export the certificate (.pfx and .cer) files to your drive.
  c. Import the certificate to your local user store. 
  d. Import the certificate information (most importantly the certificate thumbprint) to your newly created registered Azure tenant application.
  e. Apply the necessary rights (Exchange.ManageAsApp) permissions to your application.
3. -CreateSingleObjectCreate will make sure we create a single service princiapl object (different from batch creation).
	
> This will allow for a local interact PowerShell session to conect to Exchange Online via CBA. If you intent is to use unattended automation wou will need to copy the certificate to computer's localMachine certificate store. 

The last step you need to do is manually log in to your Azure portal and do the following for verification:

1. Select the 'Azure Active Directory' option
2. Select 'App Registrations' 
3. Select your application from the application list
4. Select Certificates & secrets and verify the certificate thumbprint has been added successfully.
5. Select 'API Permissions' to verify that 'Exchange.ManageAsApp' has been added successfully.
6. Select 'Grant Admin Consent for 'YourDomain' (Default Directory). 

> This will apply the permissions to the application in the tenant.

7.	Add your application to an Azure security role that you want your application to have rights for. (This is based on your security model).
