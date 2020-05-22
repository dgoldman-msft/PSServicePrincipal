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
        [parameter(HelpMessage = "Display name used to return enterprise application objects")]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "Application id used to return enterprise application objects")]
        [guid]
        $ApplicationID,

        [parameter(HelpMessage = "Object id used to return enterprise application objects")]
        [String]
        $ObjectID,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include DisplayName, ApplicationID, ObjectID

    if(-NOT $script:AzsessionFound)
    {
        Connect-ToAzureInteractively
    }

    try
    {
        Write-PSFMessage -Level Verbose -Message "Retrieving values for {0}" -StringValues ($PSBoundParameters.Values | Where-Object {$_ -is [string]})
        Get-AzADApplication @parameter -ErrorAction Stop
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}
