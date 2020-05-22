Function Remove-ServicePrincipalObject
{
	<#
        .SYNOPSIS
            Deletes an single azure active directory application or service principal.

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
            Display name of the objects you are retrieving.

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

            Delete a Azure service principal by the DisplayName.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteSpn -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete the Azure service principal by the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-ServicePrincipalObject -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete the Azure service principal by the ObjectID.
     #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [parameter(HelpMessage = "Application id used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [parameter(HelpMessage = "Switch used to delete an enterprise object")]
        [switch]
        $DeleteEnterpriseApp,

        [parameter(HelpMessage = "Switch used to delete an registered object")]
        [switch]
        $DeleteRegisteredApp,

        [parameter(HelpMessage = "Switch used to delete a service principal object")]
        [switch]
        $DeleteSpn,

        [parameter(HelpMessage = "Display name used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "Display name used to delete an application object")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -include DisplayName, ApplicationID, ObjectID, DeleteEnterpriseApp, DeleteRegisteredApp, DeleteSpn

    if($DeleteEnterpriseApp)
    {
        Invoke-PSFProtectedCommand -Action "Enterprise application delete!" -Target $parameter.Values -ScriptBlock {
            Remove-AzADApplication @parameter -ErrorAction Stop
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }

    if($DeleteRegisteredApp)
    {
        Invoke-PSFProtectedCommand -Action "Registered application deleted!" -Target $parameter.Values -ScriptBlock {
            Remove-AzureADApplication @parameter -ErrorAction Stop
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }

    if($DeleteSpn)
    {
        Invoke-PSFProtectedCommand -Action "Service principal deleted!" -Target $parameter.Values -ScriptBlock {
            Remove-AzADServicePrincipal @parameter -ErrorAction Stop
            $script:spnDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }
}