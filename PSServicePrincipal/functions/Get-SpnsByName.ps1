Function Get-SpnsByName
{
    <#
        .SYNOPSIS
            Filters active directory service principals (batches via wildcard search).

        .DESCRIPTION
            This function will retrieve a batch of Service Principal objects from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-SpnsByName $DisplayName

            This will retrieve a batch of service principals objects by display name using a wildcard search.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )

    try
    {
        if($DisplayName)
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
                    AppicationID = $item.ApplicationID
                    ObjectID = $item.ObjectID
                }
            }
        }
        else
        {
            Write-PSFMessage -Level Verbose "ERROR: You did not provide a display name. Search failed."
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}