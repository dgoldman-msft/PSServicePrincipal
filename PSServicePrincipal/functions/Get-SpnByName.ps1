Function Get-SpnByName
{
    <#
        .SYNOPSIS
            Filters active directory service principals by display name.

        .DESCRIPTION
            This function will retrieve a Service Principal from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-SpnByName -DisplayName CompanySPN

            This will retrieve a service principal by display name from the Azure active directory.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = 'True', Position = '0', HelpMessage = "Display name used to retrieve a service principal")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName
    )

    try
    {
        if(![string]::IsNullOrEmpty($DisplayName))
        {
            Write-PSFMessage -Level Verbose "Retrieving SPN by Display Name"
            $spnOutput = Get-AzADServicePrincipal -DisplayName $DisplayName | Select-PSFObject DisplayName, ApplicationID, "ID as ObjectID", ObjectType, Type

            [pscustomobject]@{
                DisplayName = $spnOutput.DisplayName
                ApplicationID = $spnOutput.ApplicationID
                ObjectID = $spnOutput.ObjectID
                ObjectType = $spnOutput.ObjectType
                Type = $spnOutput.Type
            } | Format-Table

            Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-SpnByName"
        }
        else
        {
            Write-PSFMessage -Level Verbose "ERROR: You did not provide a display name. Search failed."
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}