Function Get-SpnsByName
{
    <#
        .SYNOPSIS
            Filters active directory service principals (batches via wildcard search).

        .DESCRIPTION
            Retrieve a batch of Service Principal objects from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            Display name of the objects you are retrieving.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-SpnsByName -DisplayName CompanySPN

            Retrieve a batch of service principals objects by display name using a wildcard search.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, Position = 0, HelpMessage = "Display name used to retrieve service principals")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [switch]
        $EnableException
    )

    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN's by Display Name"
        $DisplayNameWC = $DisplayName, "*" -join ""
        $spnOutput = Get-AzADServicePrincipal | Where-Object DisplayName -like $DisplayNameWC | Select-PSFObject DisplayName, ApplicationID, "ID as ObjectID"

        $count = 0
        foreach($item in $spnOutput)
        {
            $count++
            [pscustomobject]@{
                Index = $count
                DisplayName = $item.DisplayName
                ApplicationID = $item.ApplicationID
                ObjectID = $item.ObjectID
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}