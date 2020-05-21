Function Remove-AppOrSPN
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
            PS c:\> Remove-AppOrSPN -DeleteRegisteredApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Delete a registerd application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -DisplayBane CompanyAPP

            Delete an enterprise application using the DisplayBane 'CompanyAPP'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete a enterprise application using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Delete the enterprise application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -DisplayName CompanySPN

            Delete a Service Principal using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete the Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Delete a Service Principal using the ObjectID.
     #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [switch]
        $DeleteEnterpriseApp,

        [switch]
        $DeleteRegisteredApp,

        [switch]
        $DeleteSpn,

        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -include DisplayName, ApplicationID, ObjectID
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
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }
}