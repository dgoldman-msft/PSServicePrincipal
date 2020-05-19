Function Get-EnterpriseApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory enterprise application.

        .DESCRIPTION
            This function will retrieve an enterprise application (Service Principal) from the Azure active directory.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN

            This will retrieve an Azure active directory enterprise application object.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = 'True', Position = '0', HelpMessage = "Display name used to retrieve an application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName
    )

    try
    {
       Get-AzADApplication -DisplayName $DisplayName
       Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-EnterpriseApp"
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
