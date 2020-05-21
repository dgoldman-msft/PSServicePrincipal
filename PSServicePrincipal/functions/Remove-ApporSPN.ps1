Function Remove-AppOrSPN
{
	<#
        .SYNOPSIS
            Deletes an single azure active directory application or service principal.

        .DESCRIPTION
            This function will delete an Application or Service Principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            This parameter is the ApplicationID of the object you are deleting.

        .PARAMETER DeleteEnterpriseApp
            This parameter is switch used to delete an Azure enterprise application.

        .PARAMETER DeleteRegisteredApp
            This parameter is switch used to delete an Azure registered application.

        .PARAMETER DeleteSpn
            This parameter is switch used to delete a Service Principal.

        .PARAMETER DisplayName
            This parameter is the DisplayName of the object you are deleting.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER ObjectID
            This parameter is the ObjectID of the objects you are deleting.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteRegisteredApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will delete a registerd application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -DisplayBane CompanyAPP

            This will delete an enterprise application using the DisplayBane 'CompanyAPP'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a enterprise application using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will delete the enterprise application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -DisplayName CompanySPN

            This will delete a Service Principal using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete the Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a Service Principal using the ObjectID.
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
        Invoke-PSFProtectedCommand -Action "Deleting enterprise application" -Target $parameter.Values -ScriptBlock {
            Remove-AzADApplication @parameter -ErrorAction Stop
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }

    if($DeleteRegisteredApp)
    {
        Invoke-PSFProtectedCommand -Action "Deleting registered application" -Target $parameter.Values -ScriptBlock {
            Remove-AzureADApplication @parameter -ErrorAction Stop
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }

    if($DeleteSpn)
    {
        Invoke-PSFProtectedCommand -Action "Deleting Service Principal" -Target $parameter.Values -ScriptBlock {
            Remove-AzADServicePrincipal @parameter -ErrorAction Stop
            $script:appDeletedCounter ++
        } -EnableException $EnableException -PSCmdlet $PSCmdlet
    }
}