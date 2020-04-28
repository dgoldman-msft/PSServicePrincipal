Function New-ServicePrincipalObject
{
        <#
		.SYNOPSIS
            Cmdlet for creating a new azure active directory service principal. 
            
		.DESCRIPTION
            This function will create a new azure active directory service principal.
            All messages are logged by defaul to the following folder [[Environment]::GetFolderPath("MyDocuments") "\PowerShell Script Logs"]. 
            For more information please visit: https://psframework.org/
            PSFramework Logging: https://psframework.org/documentation/quickstart/psframework/logging.html
            PSFramework Configuration: https://psframework.org/documentation/quickstart/psframework/configuration.html
            PSGallery - PSFramework module - https://www.powershellgallery.com/packages/PSFramework/1.0.19

        .PARAMETER EnableException
            This parameters disables user-friendly warnings and enables the throwing of exceptions. 
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> New-ServicePrincipalObject

            This will create a SPN with an automatically generaten Display Name and Application ID

        .EXAMPLE
            PS c:\> New-ServicePrincipalObject -ServicePrincipalName NameOfSPNToBeCreated

            This will take a single SPN with the name you passed in with the -SPN parameter
        
        .EXAMPLE
            PS c:\> New-ServicePrincipalObject -NameFile -BatchJob

            This will allow you to pass in a file of spn names to batch create. You must use the -BatchJob parameter
        
        .EXAMPLE
            PS c:\> New-ServicePrincipalObject -EnableException

            Creates a new service principal in AAD, after prompting for user preferences.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
           
        .Notes
            When passing in the application ID it is the Azure ApplicationID from your registered application
            
            WARNING: If you do not connect to an Azure tenant when you run Import-Module Az.Resources you will be logged in interactively to your default Azure subscription.
            After signing in, you'll see information indicating which of your Azure subscriptions is active. 
            If you have multiple Azure subscriptions in your account and want to select a different one, 
            get your available subscriptions with Get-AzSubscription and use the Set-AzContext cmdlet with your subscription ID.
            
            INFORMATION: The default parameter set uses default values for parameters if the user does not provide one for them. 
            For more information on the default values used, please see the description for the given parameters below. 
            This cmdlet has the ability to assign a role to the service principal with the Role and Scope parameters; 
            if neither of these parameters are provided, no role will be assigned to the service principal. 
            
            The default values for the Role and Scope parameters are "Contributor" and the current subscription, 
            respectively (note: the defaults are only used when the user provides a value for one of the two parameters, but not the other). 
            The cmdlet also implicitly creates an application and sets its properties (if the ApplicationId is not provided). 
            In order to update the application specific parameters please use Set-AzADApplication cmdlet. 

            Microsoft TechNet Documentation: https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azadserviceprincipal?view=azps-3.8.0
    #>

    [CmdletBinding()]
    param(
        [switch]
        $EnableException,
        [switch]
        $BatchJob,
        [string]
        $NameFile,
        [string]
        $ServicePrincipalName
    )

    Process
    {
        Clear-Host
        $spnCounter = 0
        Write-PSFMessage -Level Host -Message "Starting Script Run"
        Write-PSFMessage -Level Host -Message "You must first connect to the Azure tenant you want to create the service principals in. Calling function: Connect-AzAccount" 
        
        try 
        {
            #Connect-AzAccount -ErrorAction Stop
        }
        catch 
        {
            Stop-PSFFunction -Message $_.Exception.InnerException.Message -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
            return    
        }

        # Try to obtain the list of names so we can batch create the SPNS
        if(($NameFile) -and ($BatchJob))
        {
            Write-PSFMessage -Level Host -Message "Testing access to {0}" -StringValues $NameFile
            
            if(-NOT (Test-Path -Path $NameFile))
            {
                Stop-PSFFunction -Message "Error: File problem. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                return 
            }
            else
            {
                Write-PSFMessage -Level Host -Message "{0} accessable. Reading in content" -StringValues $NameFile
                $listofSPNStoCreate = Get-Content $NameFile

                # Validate that we have data and if we dont we exit out
                if(0 -eq $listofSPNStoCreate.Length)
                {
                    Stop-PSFFunction -Message "Error with imported content. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return 
                }
            }
        }
        else
        {
            #Stop-PSFFunction -Message "You must pass in a file name and use the -BatchJob parameter. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
            #return 
        }
            
        Write-Host @"
What type of Service Principal do you want to generate?

1. Default Service Principal - Auto-generated name and ApplicationID
2. Service Principal using GUID generated password (Single object and Batch Objects)
3. Service Principal with ApplicationID already bound to an registerd Azure application
4. Service Principal using plan certificate base key credential

Default with select option (1):
"@

        $spType = Get-PSFUserChoice -Options 'Default SPN', 'Passowrd SPN', 'AppID SPN', 'Cert SPN ', 'E&xit' -Caption 'Please select an option'  

        switch($spType)
        {
            0
            {
                try 
                {
                        $newSPN = New-AzADServicePrincipal -ErrorAction Stop
                        Write-PSFMessage -Level Host -Message "Creating a simple SPN - Name {0}" -StringValues $newSPN.DisplayName
                        Add-RoleToSPN -spnToProcess $newSPN
                        $spnCounter ++
                }
                catch 
                {
                    Stop-PSFFunction -Message "ERROR: Creating a simple SPN failed" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return    
                }
            }

            1
            {
                try 
                {
                    # Check to make sure we have the list of objects to process
                    if($listofSPNStoCreate)
                    {
                        Write-PSFMessage -Level Host -Message "Object list DETECTED. Staring batch creation of SPN's"
                        $roleListToProcess = New-Object -TypeName "System.Collections.ArrayList"
                        foreach($spn in $listofSPNStoCreate)
                        {
                            $password = [guid]::NewGuid().Guid
                            $securityPassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = Get-Date; EndDate = Get-Date -Year 2024; Password = $password}
                            $newSPN = New-AzADServicePrincipal -DisplayName $spn -PasswordCredential $securityPassword -ErrorAction SilentlyContinue -ErrorVariable ProcessError
                            
                            if($newSPN)
                            {
                                Write-PSFMessage -Level Host -Message "New SPN created - Name: {0} with Password: {1}" -StringValues $spn, $password
                                $roleListToProcess += $newSPN
                                $spnCounter ++
                            }
                            elseif($ProcessError)
                            {
                                Write-PSFMessage -Level Warning "$($ProcessError[0].Exception.Message) for SPN {0}" -StringValues $spn   
                            }
                        }

                        if($roleListToProcess.Count -gt 0)
                        {   
                            Add-RoleToSPN -spnToProcess $roleListToProcess
                        }
                    }
                    else
                    {
                        if(-NOT $ServicePrincipalName)
                        {
                            Write-PSFMessage -Level Warning -Message "ERROR: No Service Principal name specified. Exiting"
                            return
                        }
                        else
                        {
                            $password = [guid]::NewGuid().Guid
                            $securityPassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = Get-Date; EndDate = Get-Date -Year 2024; Password = $password}
                            Write-PSFMessage -Level Host -Message "Created new SPN - Name: {0}" -Format $ServicePrincipalName
                            $newSPN = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -PasswordCredential $securityPassword -ErrorAction Stop
                            Add-RoleToSPN -spnToProcess $newSPN
                            $spnCounter ++
                        } 
                    }
                }
                catch 
                {
                    Stop-PSFFunction -Message "ERROR: Generating PSADPasswordCredential Object with GUID. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return
                }
            }
            
            2
            {
                try 
                {
                    $ApplicationID = Read-Host "Please input your registered Azure ApplicationID:"
                
                    if(-NOT $ApplicationID)
                    {
                        Stop-PSFFunction -Message "ERROR: No ApplicationID specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet
                        return
                    }
                    else
                    {
                        $newSPN = New-AzADServicePrincipal -ApplicationId $ApplicationID -ErrorAction Stop
                        Write-PSFMessage -Level Host -Message "New SPN created with ApplicationID: {0}" -Format $ApplicationID
                        Add-RoleToSPN -spnToProcess $newSPN
                        $spnCounter ++
                    }
                }
                catch 
                {
                    Stop-PSFFunction -Message "ERROR: No ApplicationID specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return
                }
            }
            
            3
            {
                try 
                {
                    # Configure the secure password for the service principal
                    $servicePrincipalName = Read-Host "Please enter your Service Principal name"
                    $cert = Read-Host "Please input your <public certificate as base64-encoded string>"

                    if((-NOT $cert) -or (-NOT $ServicePrincipalName))
                    {
                        Stop-PSFFunction -Message "ERROR: No certificate or Service Principal Name specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet
                        return
                    }
                    else
                    {
                        $newSPN = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -CertValue $cert -EndDate "2024-12-31" -ErrorAction Stop
                        Write-PSFMessage -Level Host -Message "New SPN created with DisplayName and cert key credential - Name: {0}" -StringValues $newSPN.DisplayName
                        Add-RoleToSPN -spnToProcess $newSPN
                        $spnCounter ++
                    } 
                }
                catch 
                {
                    Stop-PSFFunction -Message "ERROR: No certificate as base64-encoded string specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
                    return
                }
            }

            Default
            {
                Write-PSFMessage -Level Warning -Message "No choice selected. Exiting"
                return
            }
        }
    }

    end
    {
        if(1 -le $spnCounter)
        {
            Write-PSFMessage -Level Host -Message "{0} SPN object created sucessfully!" -StringValues $spnCounter
        }
        else
        {
            Write-PSFMessage -Level Host -Message "{0} SPN objects created sucessfully!" -StringValues $spnCounter
        }  

        Write-PSFMessage -Level Host -Message "Script run complete!"
        Write-PSFMessage -Level Host -Message 'Log saved to: {0}' -StringValues $script:loggingFolder #-Once 'LoggingDestination'
    }
}