Function Get-SpnByAppID
{
    <#
        .SYNOPSIS
            Filters active directory service principals and applications.

        .DESCRIPTION
            This function will retrieve a Service Principal from the Azure Active Directory by application id.

        .PARAMETER ApplicationID
            This parameter is the application id of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-SpnByAppID $ApplicationID

            This will retrieve a Service Principal by application id from the Azure active directory.
    #>

    [CmdletBinding()]
    Param (
        [string]
        $ApplicationID
    )

    try
    {
        if($ApplicationId)
        {
            Write-PSFMessage -Level Verbose "Retrieving SPN by Application ID"
            $spnOutput = Get-AzADServicePrincipal -ApplicationID $ApplicationID

            [pscustomobject]@{
                DisplayName = $spnOutput.DisplayName
                AppID = $spnOutput.ApplicationID
                ObjectID = $spnOutput.ObjectID
            }
        }
        else
        {
            Write-PSFMessage -Level Verbose "ERROR: You did not provide a application id. Search failed."
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}