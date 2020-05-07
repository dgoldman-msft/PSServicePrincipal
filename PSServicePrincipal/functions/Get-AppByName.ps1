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

    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )

    try
    {
        $appOutput = Get-AzADApplication -DisplayName $DisplayName

        [pscustomobject]@{
            ObjectType = "Application"
            DisplayName = $appOutput.DisplayName
            AppID = $appOutput.ApplicationID
            ObjectID = $appOutput.ObjectID
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
