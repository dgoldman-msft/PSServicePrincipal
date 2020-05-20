Function Get-SpnsByName
{
    <#
        .SYNOPSIS
            Filters active directory service principals (batches via wildcard search).

        .DESCRIPTION
            This function will retrieve a batch of Service Principal objects from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-SpnsByName -DisplayName CompanySPN

            This will retrieve a batch of service principals objects by display name using a wildcard search.

        .EXAMPLE
            PS c:\> Get-SpnsByName -DisplayName CompanySPN -EnableException

            This example gets a service principal in AAD, after prompting for user preferences.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = 'True', Position = '0', HelpMessage = "Display name used to retrieve service principals")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [switch]
        $EnableException
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

            Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-SpnsByName"
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