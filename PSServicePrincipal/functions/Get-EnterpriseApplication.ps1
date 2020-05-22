Function Get-EnterpriseApplication
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory enterprise application.

        .DESCRIPTION
            Retrieve a single or group of enterprise applications from the Azure active directory.

        .PARAMETER ApplicationID
            Application id of the object(s) being returned.

        .PARAMETER DisplayName
            Display name of the object(s) being returned.

        .PARAMETER ObjectID
            Object id of the object being(s) returned.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

             Return an Azure active directory enterprise application by ApplicationID.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN

            Return an Azure active directory enterprise application by DisplayName.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Return an Azure active directory enterprise application by ObjectID.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(HelpMessage = "DisplayName used to return enterprise application objects")]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "ApplicationId used to return enterprise application objects")]
        [guid]
        $ApplicationId,

        [parameter(HelpMessage = "ObjectId used to return enterprise application objects")]
        [String]
        $ObjectId,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include DisplayName, ObjectId, ApplicationId
    if((-NOT $script:AzSessionFound) -or (-NOT $script:AdSessionFound)){Connect-ToAzureInteractively}

    Invoke-PSFProtectedCommand -Action "Enterprise application retrieved!" -Target $parameter.Values -ScriptBlock {
        Get-AzADApplication @parameter -ErrorAction Stop
    } -EnableException $EnableException -PSCmdlet $PSCmdlet
}
