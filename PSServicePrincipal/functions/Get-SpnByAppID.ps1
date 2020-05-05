Function Get-SpnByAppID
{
    <#
        .SYNOPSIS
            Cmdlet for retrieving a Service Principal from the Azure active directory.

        .DESCRIPTION
            This function will retrieve a Service Principal from the Azure Active Directory by application id.

        .PARAMETER ApplicationId
            This parameter is the application id of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-SpnByAppID $ApplicationId

            This will retrieve a Service Principal by application id from the Azure active directory.
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $ApplicationId
    )

    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN by Application ID"
        $spnOutput = Get-AzADServicePrincipal -ApplicationId $ApplicationId

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