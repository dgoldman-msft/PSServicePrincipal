Function Remove-ServicePrincipalObject {
    <#
        .SYNOPSIS
            Deletes an single Azure active directory application or service principal.

        .DESCRIPTION
            Delete an Application or Service Principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            ApplicationID of the object you are deleting.

        .PARAMETER Confirm
            Stops processing before any changes are made  to an object.

        .PARAMETER DeleteEnterpriseApp
            Used to delete an Azure enterprise application.

        .PARAMETER DeleteRegisteredApp
            Used to delete an Azure registered application.

        .PARAMETER DeleteSpn
            Used to delete a Service Principal.

        .PARAMETER DisplayName
            DisplayName of the objects you are deleting.

        .PARAMETER ServicePrincipalName
            ServicePrincipalName of the objects you are deleting.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER ObjectID
            ObjectID of the objects you are deleting.

        .PARAMETER WhatIf
            Only displays the objects that would be affected and what changes would be made to those objects (without the worry of modifying those objects)

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteRegisteredApp -DisplayName CompanySPN

            Delete a registered Azure application using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteRegisteredApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete a registered Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteRegisteredApp -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

             Delete a registered Azure application using the ObjectID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteEnterpriseApp -DisplayName CompanySPN

            Delete an enterprise Azure application using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteEnterpriseApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete an enterprise Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteEnterpriseApp -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

             Delete an enterprise Azure application using the ObjectID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteSpn -DisplayName CompanySPN

            Delete a service principal by the DisplayName.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -ServicePrincipalName http://CompanySPN

            Delete a service principal by the ServicePrincipalName.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteSpn -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete the service principal by the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete the service principal by the ObjectID.
     #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [parameter(HelpMessage = "DisplayName used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "ApplicationID used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationId,

        [parameter(HelpMessage = "ObjectID used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectId,

        [parameter(HelpMessage = "ServicePrincipalName used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServicePrincipalName,

        [parameter(HelpMessage = "Switch used to delete an enterprise object")]
        [switch]
        $DeleteEnterpriseApp,

        [parameter(HelpMessage = "Switch used to delete an registered object")]
        [switch]
        $DeleteRegisteredApp,

        [parameter(HelpMessage = "Switch used to delete a service principal object")]
        [switch]
        $DeleteSpn,

        [switch]
        $EnableException
    )

    process {
        if (-NOT ($DeleteEnterpriseApp -or $DeleteRegisteredApp -or $DeleteSpn)) {
            Write-PSFMessage -Level Host -Message "You must past in one of the following switches -DeleteEnterpriseApp -DeleteRegisteredApp -or -DeleteSpn"
            return
        }

        $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -include DisplayName, ApplicationId, ObjectId, ServicePrincipalName
        if ((-NOT $script:AzSessionFound) -or (-NOT $script:AdSessionFound)) { Connect-ToAzureInteractively }

        if ($DeleteEnterpriseApp) {
            Invoke-PSFProtectedCommand -Action "Enterprise application delete!" -Target $parameter.Values -ScriptBlock {
                Remove-AzADApplication @parameter -ErrorAction Stop
            } -EnableException $EnableException -PSCmdlet $PSCmdlet
        }

        if ($DeleteRegisteredApp) {
            Invoke-PSFProtectedCommand -Action "Registered application deleted!" -Target $parameter.Values -ScriptBlock {
                Remove-AzureADApplication @parameter -ErrorAction Stop

            } -EnableException $EnableException -PSCmdlet $PSCmdlet
        }

        if ($DeleteSpn) {
            if ($parameter.ContainsValue($ServicePrincipalName) -and (-NOT $ServicePrincipalName.Contains('http://'))) {
                $parameter.ServicePrincipalName = "http://$ServicePrincipalName"
            }

            Invoke-PSFProtectedCommand -Action "Service principal deleted!" -Target $parameter.Values -ScriptBlock {
                Remove-AzADServicePrincipal @parameter -ErrorAction Stop
            } -EnableException $EnableException -PSCmdlet $PSCmdlet

            $userChoice = Get-PSFUserChoice -Options "1) No", "2) Yes" -Caption "Delete matching Azure enterprise application" -Message "Would you like to delete the matching Azure enterprise application?"

            switch ($userChoice) {
                0 {
                    Write-PSFMessage -Level Host "No application deleted!"
                    return
                }

                1 {
                    # Remove-AzADApplication doesn't accept ServicePrincipal name so convert the parameter binding and set it to DisplayName
                    if ($parameter.ContainsValue($ServicePrincipalName) -and ($ServicePrincipalName.Contains('http://'))) {
                        $parameter.DisplayName = $ServicePrincipalName.substring(7)
                        $parameter.Remove('ServicePrincipalName')
                    }
                    elseif ($parameter.ContainsValue($ServicePrincipalName) -and (-NOT $ServicePrincipalName.Contains('http://'))) {
                        $parameter.DisplayName = $ServicePrincipalName
                        $parameter.Remove('ServicePrincipalName')
                    }

                    Invoke-PSFProtectedCommand -Action "Removing application!" -Target $parameter.Values -ScriptBlock {
                        Remove-AzADApplication @parameter -ErrorAction Stop
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet
                }
            }
        }
    }
}