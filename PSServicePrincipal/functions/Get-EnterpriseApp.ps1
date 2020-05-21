Function Get-EnterpriseApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory enterprise application.

        .DESCRIPTION
            Retrieve an enterprise application (Service Principal) from the Azure active directory.

        .PARAMETER DisplayName
            Display name of the objects you are retrieving.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN

            This will retrieve an Azure active directory enterprise application object.
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName="DisplayNameSet")]
    Param (
        [parameter(ParameterSetName = 'DisplayNameSet', HelpMessage = "Display name used to retrieve an application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName = '*',

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include $DisplayName
    if($DisplayName -ne '*') { $parameter.SearchString = $DisplayName }

    try
    {
        Write-PSFMessage -Level Verbose -Message "Retrieving values for {0}" -StringValues ($PSBoundParameters.Values | Where-Object {$_ -is [string]})

        if($DisplayName -eq '*')
        {
            Get-AzADApplication -ErrorAction Stop
        }
        else
        {
            Get-AzADApplication -DisplayName $DisplayName -ErrorAction Stop
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}
