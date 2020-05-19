Function Get-RegisteredApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory registered application.

        .DESCRIPTION
            This function will retrieve an registered application from the Azure active directory.

        .PARAMETER DisplayName
            This parameter is the display name of the object we are retrieving.

        .PARAMETER ObjectID
            This parameter is the object id of the object you are retrieving.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -SearchString CompanyApp

            This will retrieve the registered application called CompanyApp by DisplayName.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -Objectid 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will retrieve the registered by object id '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.
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
            Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-RegisteredApp"
        }
        if($ObjectID)
        {
            Get-AzureADApplication -ObjectId $ObjectID
            Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $ObjectID -FunctionName "Get-RegisteredApp"
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
