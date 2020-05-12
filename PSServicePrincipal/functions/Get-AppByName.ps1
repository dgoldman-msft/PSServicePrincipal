Function Get-AppByName
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory enterprise application

        .DESCRIPTION
            This function will retrieve an Enterprise Application (Service Principal) from the Azure active Directory.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-AppByName -DisplayName CompanySPN

            This will retrieve the Azure active directory Enterprise Application and Service Principal object.
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
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
