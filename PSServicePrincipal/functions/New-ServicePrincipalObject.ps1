Function New-ServicePrincipalObject
{
    <#
    .SYNOPSIS
        PowerShell module for creating, retrieving and removing Azure registered / enterprise applications and service principals.

    .DESCRIPTION
        This module will create creating, retrieving and remove Azure registered / enterprise applications and service principals objects
        that can be used for automation tasks. Enterprise applications created will also have a mirror service principal objects created. Azure
        registered applications will be linked to a new service principal which can then be use as an authentication mechanism for connecting applications
        and PowerShell session to an Office 365 and Azure tenant.

        The PSServicePrincipal logging provider is based on PSFramework: All messages are logged by default 'Documents\PowerShell Script Logs' on
        Windows and 'Documents/PowerShell Script Logs' on MacOS. There are two logging streams (output and debug). Both streams have respective
        folders for analysis: You can run Get-LogFolder -LogFolder [OutputLoggingFolder] and [DebugLoggingFolder] to access either logging stream directory.

        For more information on PSFramework please visit: https://psframework.org/
        PSFramework Logging: https://psframework.org/documentation/quickstart/psframework/logging.html
        PSFramework Configuration: https://psframework.org/documentation/quickstart/psframework/configuration.html
        PSGallery - PSFramework module - https://www.powershellgallery.com/packages/PSFramework/1.0.19

    .PARAMETER CreateSelfSignedCertificate
        Used when creating a single self-signed certificate to be used with registered and enterprise applications for certificate based connections.

    .PARAMETER CreateSingleObject
        Used when creating a single default enterprise application (service principal).

    .PARAMETER CreateBatchObjects
        Used when creating a batch of service principals from a text file.

    .PARAMETER CreateSPNWithAppID
        Used when creating a service principal and a registered Azure ApplicationID.

    .PARAMETER CreateSPNWithPassword
        Used when creating a service principal and a registered Azure application with a user supplied password.

    .PARAMETER CreateSPNsWithNameAndCert
        Used when creating a service principal and a registered Azure application using a display name and certificate.

    .PARAMETER DeleteEnterpriseApp
        Used to delete an enterprise application application.

    .PARAMETER DeleteRegisteredApp
        Used to delete an Azure registered application.

    .PARAMETER DeleteSpn
        Used to delete a service principal.

    .PARAMETER Cba
        Switch used to create a registered application, self-signed certificate, upload to the application, applies the correct application roll assignments.

    .PARAMETER EnableException
        Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

    .PARAMETER GetEnterpriseApp
        Used to retrieve a enterprise application from the Azure active directory via display name.

    .PARAMETER GetRegisteredApp
        Used to retrieve a registered application from the Azure active directory via display name or object id.

    .PARAMETER GetSPNByName
        Used to retrieve a service principal object from the Azure active directory via display name.

    .PARAMETER GetSPNByAppID
        Used to retrieve a service principal object from the Azure active directory via ApplicationID.

    .PARAMETER GetSPNSByName
        Used to retrieve a batch of service principal objects via wildcard search from the Azure active directory.

    .PARAMETER GetAppAndSPNPair
        Used to retrieve an application and service principal pair from the Azure active directory.

    .PARAMETER OpenAzurePortal
        Used to when connecting to the online web Azure portal.

    .PARAMETER Reconnect
        Used when forcing a new connection to an Azure tenant subscription.

    .PARAMETER RemoveAppOrSpn
        Used to delete a single Azure application or service srincipal from the Azure active directory.

    .PARAMETER RemoveEnterpriseAppAndSPNPair
        Used to delete an enterprise application and service principal pair from the Azure active directory.

    .PARAMETER RegisteredApp
        Used when working on registered Azure applications (not enterprise applications).

    .PARAMETER ApplicationID
        Unique ApplicationID for a service principal in a tenant. Once created this property cannot be changed.

    .PARAMETER Certificate
        This parameter is the value of the "asymmetric" credential type. It represents the base 64 encoded certificate.

     .PARAMETER DisplayName
        Display name of the objects you are retrieving.

    .PARAMETER NameFile
        Name of the file that contains the list of service principals being passed in for creation.

    .PARAMETER ObjectID
        ObjectID for a service principal in a tenant. Once created this property cannot be changed.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -CreateSelfSignedCertificate

        Create a basic self-signed certificate to be used with registered and enterprise applications for certificate-based connections.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -CreateSingleObject

        Create a new service principal with a display name of 'CompanySPN' and password (an autogenerated GUID) and creates the service principal based on the application just created. The start date and end date are added to password credential.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -CreateSingleObject -CreateSPNWithPassword

        Create a new Enterprise Application and service principal with a display name of 'CompanySPN' and a (user supplied password) and creates the service principal based on the application just created. The start date and end date are added to password credential.

     .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanyApp -CreateSingleObject -RegisteredApp -Cba

        Create a registered application with a display name of 'CompanyApp', a self-signed certificate which is uploaded to the application and applies the correct appRoll assignments.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e -CreateSingleObject -CreateSPNWithAppID

        Create a new Enterprise Application and service principal with the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -NameFile c:\temp\YourFileContainingNames.txt -CreateBatchObjects

        Connect to an Azure tenant and creates a batch of enterprise applications and service principal objects from a file passed in.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -CreateSPNsWithNameAndCert -CreateSingleObject -Certificate <public certificate as base64-encoded string>

        Create a new Enterprise Application and service principal with a display name of 'CompanySPN' and certifcate and creates the service principal based on the application just created. The end date is added to key credential.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -Reconnect

        Force a reconnect to a specific Azure tenant.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -GetSpnByName

        Retrieve a service principal from the Azure active directory by display name 'CompanySPN'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e -GetSpnByAppID

        Retrieve a service principal from the Azure active directory by ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -GetSPNSByName

        Retrieve a batch of service principal objects from the Azure active directory by display name 'CompanySPN'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -GetEnterpriseApp

        Retrieve an enterprise application from the Azure active directory.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -GetRegisteredApp

        Retrieve a registered application from the Azure active directory.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -GetAppAndSPNPair

        Retrieve a service principal and Application pair from the Azure active directory.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e -RemoveAppAndSPNPairBy

        Delete a service principal and Application pair from the Azure active directory using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h -RemoveAppAndSPNPairBy

        Delete a service principal and Application pair from the Azure active directory using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -RemoveAppOrSpn -DeleteEnterpriseApp

        Delete a single service principal from the Azure active directory using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e -RemoveAppOrSpn -DeleteEnterpriseApp

        Delete a singple enterprise application using -ApplicaationID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h -RemoveAppOrSpn -DeleteEnterpriseApp

        Delete a singple enterprise application using -ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h -RemoveAppOrSpn -DeleteRegisteredApp

        Delete a singple registered application using -ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -OpenAzurePortal

        Open a web connection to the Microsoft Azure Portal.

    .EXAMPLE
        PS c:\> New-ServicePrincipalObject -DisplayName CompanySPN -EnableException

        Create a new service principal in AAD, after prompting for user preferences.
        If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.

    .NOTES
        When passing in the application ID it is the Azure ApplicationID from your registered application.

        WARNING: If you do not connect to an Azure tenant when you run Import-Module Az.Resources you will be logged in interactively to your default Azure subscription.
        After signing in, you will see information indicating which of your Azure subscriptions is active. If you have multiple Azure subscriptions in your account and
        want to select a different one, get your available subscriptions with Get-AzSubscription and use the Set-AzContext cmdlet with your subscription id.

        INFORMATION: The default parameter set uses default values for parameters if the user does not provide any.
        For more information on the default values used, please see the description for the given parameters below.
        This cmdlet can assign a role to the service principal with the Role 'Contributor'. Roles are applid at the end of the service principal creation.
        For more information on Azure RBAC roles please see: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

        Microsoft TechNet Documentation: https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azadserviceprincipal?view=azps-3.8.0
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType('System.Boolean')]
    [OutputType('System.String')]

    param(
        [switch]
        $Cba,

        [switch]
        $CreateSelfSignedCertificate,

        [parameter(ParameterSetName='DisplayNameSet')]
        [switch]
        $CreateSingleObject,

        [parameter(Mandatory = $True, ParameterSetName='NameFileSet', HelpMessage = "Switch used for creating batch SPN's")]
        [switch]
        $CreateBatchObjects,

        [parameter(ParameterSetName='AppIDSet', HelpMessage = "Switch used to create SPN with an ApplicationID")]
        [switch]
        $CreateSPNWithAppID,

        [parameter(ParameterSetName='CertSet', HelpMessage = "Switch used to create SPN with an name and certificate")]
        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $CreateSPNsWithNameAndCert,

        [parameter(ParameterSetName='CertSet', HelpMessage = "Switch used to create SPN with a user supplied password")]
        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $CreateSPNWithPassword,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="AppIDSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $DeleteEnterpriseApp,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $DeleteRegisteredApp,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $DeleteSpn,

        [switch]
        $EnableException,

        [parameter(ParameterSetName="AppIDSet")]
        [switch]
        $GetSPNByAppID,

        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $GetEnterpriseApp,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $GetRegisteredApp,

        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $GetSPNByName,

        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $GetSPNSByName,

        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $GetAppAndSPNPair,

        [parameter(Mandatory = $True, ParameterSetName='OpenAzurePortal', HelpMessage = "A switch used to connect to the Azure web portal")]
        [switch]
        $OpenAzurePortal,

        [parameter(Mandatory = $True, ParameterSetName='Reconnect', HelpMessage = "A switch used to connect force a new conncetion to an Azure tenant")]
        [switch]
        $Reconnect,

        [parameter(ParameterSetName="DisplayNameSet")]
        [switch]
        $RegisteredApp,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $RemoveAppOrSpn,

        [parameter(ParameterSetName="DisplayNameSet")]
        [parameter(ParameterSetName="ObjectIDSet")]
        [switch]
        $RemoveEnterpriseAppAndSPNPair,

        [parameter(Mandatory = $True, ParameterSetName='AppIDSet', HelpMessage = "ApplicationID used to create or delete an SPN or application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [parameter(Mandatory = $True, ParameterSetName='CertSet', HelpMessage = "Certificate parameter for a created spn")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Certificate,

        [parameter(Mandatory = $True, ParameterSetName='DisplayNameSet', HelpMessage = "Display name used to create or delete an SPN or application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [parameter(Mandatory = $True, ParameterSetName='NameFileSet', HelpMessage = "Name file used to create a batch of spn's")]
        [ValidateNotNullOrEmpty()]
        [string]
        $NameFile,

        [parameter(Mandatory = $True, ParameterSetName='ObjectIDSet', HelpMessage = "ObjectID used to create or delete an SPN or application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID
    )

    Process
    {
        $script:spnCounter = 0
        $script:appCounter = 0
        $script:appDeletedCounter = 0
        $script:certCounter = 0
        $script:certExportedCounter = 0
        $script:runningOnCore = $false
        $script:AzSessionFound = $false
        $script:AdSessionFound = $false
        $script:AzSessionInfo = $null
        $script:AdSessionInfo = $null
        $script:roleListToProcess = New-Object -Type System.Collections.ArrayList
        $requiredModules = @("AzureAD", "Az.Accounts", "Az.Resources")
        Foreach($module in $requiredModules){Import-Module $module; Write-PSFMessage -Level Verbose -Message "Importing required modules {0}" -StringValues $module}
        $parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Reconnect
        Write-PSFMessage -Level Host -Message "Starting script run: {0}" -StringValues (Get-Date)

        if(-NOT $CreateSelfSignedCertificate)
        {
            # Try to obtain the list of names so we can batch create the SPNS
            if($NameFile -and $CreateBatchObjects)
            {
                Write-PSFMessage -Level Host -Message "Testing access to {0}" -StringValues $NameFile

                if(-NOT (Test-Path -Path $NameFile))
                {
                    Stop-PSFFunction -Message "ERROR: File problem. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return
                }
                else
                {
                    Write-PSFMessage -Level Host -Message "{0} accessable. Reading in content" -StringValues $NameFile
                    $objectsToCreate = Get-Content $NameFile

                    # Validate that we have data and if we dont we exit out
                    if(0 -eq $objectsToCreate.Length)
                    {
                        Stop-PSFFunction -Message "Error with imported content. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                        return
                    }
                }
            }

            try
            {
                Connect-ToCloudTenant @parameters -EnableException
            }
            catch
            {
                Stop-PSFFunction -Message $_ -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }
        elseif($CreateSelfSignedCertificate)
        {
            try
            {
                New-SelfSignedCert -EnableException
                return
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR: Creating self-signed certificate" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($CreateSingleObject)
        {
            try
            {
                if($RegisteredApp)
                {
                    if(-NOT $script:runningOnCore)
                    {
                        if($Cba)
                        {
                            New-SelfSignedCert -CertificateName $DisplayName -SubjectAlternativeName $DisplayName -Cba -RegisteredApp -EnableException
                        }
                        else
                        {
                            $newApp = New-AzureADApplication -DisplayName $DisplayName -ErrorAction SilentlyContinue -ErrorVariable ProcessError
                        }

                        if($newApp)
                        {
                            Write-PSFMessage -Level Host -Message "Registered Application created: DisplayName: {0} - ApplicationID {1}" -StringValues $newApp.DisplayName, $newApp.AppId
                            $script:appCounter ++

                            # Since we only create an AzureADapplicaiaton we need to create the matching service principal
                            New-ServicePrincipal -ApplicationID $newApp.AppId -RegisteredApp
                        }
                        elseif($ProcessError)
                        {
                            Write-PSFMessage -Level Warning "WARNING: $($ProcessError[0].Exception.Message)"
                        }
                    }
                    else
                    {
                        Write-PSFMessage -Level Host -Message "At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6 to create Registered Applications."
                    }
                }
                elseif($DisplayName -and $CreateSPNWithPassword)
                {
                    New-ServicePrincipal -DisplayName $DisplayName -CreateSPNWithPassword
                }
                elseif(($DisplayName) -and (-NOT $RegisteredApp) -and (-NOT $Cba))
                {
                    New-ServicePrincipal -DisplayName $DisplayName
                }

                if($script:roleListToProcess.Count -gt 0)
                {
                    Add-RoleToSPN -spnToProcess $script:roleListToProcess

                    if($Cba)
                    {
                        Add-ExchangePermsToSPN.ps1 -DisplayName $DisplayName
                    }
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR: Creating a simple SPN failed" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($CreateBatchObjects)
        {
            try
            {
                # Check to make sure we have the list of objects to process
                if($objectsToCreate)
                {
                    Write-PSFMessage -Level Host -Message "Object list DETECTED! Staring batch creation of SPN's"

                    if($RegisteredApp)
                    {
                        if(-NOT $script:runningOnCore)
                        {
                            foreach($DisplayName in $objectsToCreate)
                            {
                                $newApp = New-AzureADApplication -DisplayName $DisplayName -ErrorAction SilentlyContinue -ErrorVariable ProcessError

                                if($newApp)
                                {
                                    Write-PSFMessage -Level Host -Message "Registered Application created: DisplayName: {0} - ApplicationID {1}" -StringValues $newApp.DisplayName, $newApp.AppId
                                    $script:roleListToProcess.Add($newApp)
                                    $script:appCounter ++

                                    # Since we only create an AzureADapplicaiaton we need to create the matching service principal
                                    New-ServicePrincipal -ApplicationID $newApp.AppID
                                }
                                elseif($ProcessError)
                                {
                                    Write-PSFMessage -Level Warning "WARNING: {0}" -StringValues $ProcessError.Exception.Message
                                }
                            }

                            if($script:roleListToProcess.Count -gt 0)
                            {
                                Add-RoleToSPN -spnToProcess $script:roleListToProcess
                            }
                        }
                        else
                        {
                            Write-PSFMessage -Level Host -Message "At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6 to create Registered Applications."
                        }
                    }
                    else
                    {
                        foreach($spn in $objectsToCreate)
                        {
                            New-ServicePrincipal -DisplayName $spn
                        }

                        if($roleListToProcess.Count -gt 0)
                        {
                            Add-RoleToSPN -spnToProcess $script:roleListToProcess
                        }
                    }
                }
                else
                {
                    Write-PSFMessage -Level Warning "ERROR: No list of objects found!"
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR creating batch spn's" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($CreateSPNWithAppID)
        {
            try
            {
                New-ServicePrincipal -ApplicationID $ApplicationID
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR creating an spn by application id" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($CreateSPNsWithNameAndCert)
        {
            try
            {
                if((-NOT $Certificate) -or (-NOT $DisplayName))
                {
                    Stop-PSFFunction -Message "ERROR: No certificate or Service Principal DisplayName specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet
                    return
                }
                else
                {
                    Write-PSFMessage -Level Host -Message "Creating new SPN DisplayName and certificate key - DisplayName: {0}" -StringValues $newSPN.DisplayName
                    $endDate = Get-Date
                    $endDate  = $currentDate.AddYears(1)
                    $newSPN = New-AzADServicePrincipal -DisplayName $DisplayName -CertValue $Certificate -EndDate $endDate
                    Add-RoleToSPN -spnToProcess $newSPN
                    $script:spnCounter ++
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR: No certificate as base64-encoded string specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetEnterpriseApp)
        {
            try
            {
                Get-EnterpriseApp -DisplayName $DisplayName
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR retrieving an application by name" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetRegisteredApp)
        {
            try
            {
                if($DisplayName)
                {
                    Get-RegisteredApp -DisplayName $DisplayName
                }
                if($ObjectID)
                {
                    Get-RegisteredApp -ObjectID $ObjectID
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a display name or objectid. Search failed."
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR retrieving an application by name" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetSPNByName)
        {
            try
            {
                if($DisplayName)
                {
                    Get-SpnByName -DisplayName $DisplayName
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a display name. Search failed."
                }
            }
            catch
            {
                Stop-PSFFunction -Message $_ -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetSPNByAppID)
        {
            try
            {
                if($ApplicationID)
                {
                    Get-SpnByAppID -ApplicationID $ApplicationID
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a application id. Search failed."
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR retrieving spn by application id" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetSPNSByName)
        {
            try
            {
                if($DisplayName)
                {
                    Get-SpnsByName -DisplayName $DisplayName
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a display name. Search failed."
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR retrieving spn by name" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($GetAppAndSPNPair)
        {
            try
            {
                if($DisplayName)
                {
                    Get-AppAndSPNPair -DisplayName $DisplayName
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a display name. Search failed."
                }
            }
            catch
            {
                Stop-PSFFunction -Message $_ -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($RemoveEnterpriseAppAndSPNPair)
        {
            try
            {
                if((-NOT $DisplayName) -or (-NOT $ApplicationID) -or (-NOT $ObjectID))
                {
                    Remove-EnterpriseAppAndSPNPair -DisplayName $DisplayName -ApplicationID $ApplicationID -ObjectID $ObjectID -EnableException
                    return
                }
                else
                {
                    Write-PSFMessage -Level Host "ERROR: You did not provide a DisplayName, ApplicationID -or ObjectID value."
                    return
                }
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR creating removing application and spn pair" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }

        }

        if($RemoveAppOrSpn)
        {
            $removeParameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include DisplayName, ApplicationID, ObjectID, DeleteRegisteredApp, DeleteEnterpriseApp, DeleteSpn

            try
            {
                Remove-AppOrSPN @removeParameters -EnableException
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR removing enterprise or registered application" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }

        if($OpenAzurePortal)
        {
            try
            {
                Start-Process "https://portal.azure.com"
            }
            catch
            {
                Stop-PSFFunction -Message "ERROR connecting to Azure web portal" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return
            }
        }
    }

    end
    {

        if($CreateSelfSignedCertificate)
        {
            Write-PSFMessage -Level Host -Message "{0} self-signed certificate created sucessfully!" -StringValues $script:certCounter
            Write-PSFMessage -Level Host -Message "{0} self-signed certificates exported sucessfully!" -StringValues $script:certExportedCounter
        }

        if($CreateSingleObject -or $CreateBatchObjects -or $CreateSPNWithAppID -or $CreateSPNsWithNameAndCert -or $CreateSPNWithPassword)
        {
            if(0 -eq $script:appCounter)
            {
                Write-PSFMessage -Level Host -Message "No application created!"
            }
            elseif(1 -eq $script:appCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} application created sucessfully!" -StringValues $script:appCounter
            }
            elseif(1 -gt $script:appCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} applications created sucessfully!" -StringValues $script:appCounter
            }
            if(0 -eq $script:spnCounter)
            {
                Write-PSFMessage -Level Host -Message "No service principal created!"
            }
            elseif(1 -eq $script:spnCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} service principals sucessfully!" -StringValues $script:spnCounter
            }
            elseif(1 -gt $script:spnCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} service principals created sucessfully!" -StringValues $script:spnCounter
            }
        }

        if($RemoveAppOrSpn -or $RemoveEnterpriseAppAndSPNPair)
        {
            if(0 -eq $script:appDeletedCounter)
            {
                Write-PSFMessage -Level Host -Message "No applications deleted!"
            }
            elseif(1 -eq $script:appDeletedCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} application deleted sucessfully!" -StringValues $script:appDeletedCounter
            }
            elseif(1 -gt $script:appDeletedCounter)
            {
                Write-PSFMessage -Level Host -Message "{0} applications deleted sucessfully!" -StringValues $script:appDeletedCounter
            }
        }

        Write-PSFMessage -Level Host -Message "End script run: {0}" -StringValues (Get-Date)
        Write-PSFMessage -Level Host -Message 'Log saved to: "{0}". Run Get-LogFolder to retrieve the output or debug logs.' -StringValues $script:loggingFolder
    }
}