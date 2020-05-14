Function Get-RegisteredApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory registered application

        .DESCRIPTION
            This function will retrieve an registered application from the Azure active directory.

        .PARAMETER All
            This parameter is a switch that indicated to get all objects

        .PARAMETER Filter
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -SearchString CompanyApp

            This will retrieve an Azure active directory registered application by DisplayName filter.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -Objectid 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will retrieve an Azure active directory registered by object id '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID
    )

    try
    {
        if($DisplayName)
        {
            Get-AzureADApplication -SearchString $DisplayName
        }
        if($ObjectID)
        {
            Get-AzureADApplication -ObjectId $ObjectID
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
