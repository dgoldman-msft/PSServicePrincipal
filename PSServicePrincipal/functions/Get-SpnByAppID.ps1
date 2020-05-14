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
            PS c:\> Get-SpnByAppID -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will retrieve a Service Principal by application id from the Azure active directory.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = 'True', Position = '0', HelpMessage = "ApplicationID used to retrieve an application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID
    )

    try
    {
        if($ApplicationId)
        {
            Write-PSFMessage -Level Verbose "Retrieving SPN by Application ID"
            $spnOutput = Get-AzADServicePrincipal -ApplicationID $ApplicationID | Select-PSFObject DisplayName, ApplicationID, "ID as ObjectID", ObjectType, Type

            [pscustomobject]@{
                DisplayName = $spnOutput.DisplayName
                AppID = $spnOutput.ApplicationID
                ObjectID = $spnOutput.ObjectID
                ObjectType = $spnOutput.ObjectType
                Type = $spnOutput.Type
            } | Format-Table
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