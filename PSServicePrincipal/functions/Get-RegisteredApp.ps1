Function Get-RegisteredApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory registered application

        .DESCRIPTION
            This function will retrieve an registered application from the Azure active directory.

        .PARAMETER DisplayName
            This parameter is the display name of the object we are retrieving.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER ObjectID
            This parameter is the object id of the object you are retrieving.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -SearchString CompanyApp

            This will retrieve the registered application called 'CompanyApp' by DisplayName.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -Objectid 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will retrieve the registered by object id '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName="DisplayNameSet")]
    Param (
        [parameter(ParameterSetName = 'DisplayNameSet', HelpMessage = "Display name used to create or delete an SPN or application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName = '*',

        [parameter(ParameterSetName='ObjectIDSet', HelpMessage = "ObjectID used to create or delete an SPN or application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include ObjectID
    if($DisplayName -ne '*') { $parameter.SearchString = $DisplayName }

    try
    {
        Write-PSFMessage -Level Verbose -Message "Retrieving values for {0}" -StringValues ($PSBoundParameters.Values | Where-Object {$_ -is [string]})
        Get-AzureADApplication @parameter -ErrorAction Stop
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}
