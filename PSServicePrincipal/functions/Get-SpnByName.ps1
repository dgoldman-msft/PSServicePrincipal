Function Get-SpnByName
{
    <#
        .SYNOPSIS
            Cmdlet for retrieving a Service Principal from the Azure active directory.

        .DESCRIPTION
            This function will retrieve a Service Principal from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-SpnByName $DisplayName

            This will retrieve a Service Principal by display name from the Azure active directory.
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )

    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN by Display Name"
        $spnOutput = Get-AzADServicePrincipal -DisplayName $DisplayName

        [pscustomobject]@{
            DisplayName = $spnOutput.DisplayName
            AppID = $spnOutput.ApplicationID
            ObjectID = $spnOutput.ObjectID
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}