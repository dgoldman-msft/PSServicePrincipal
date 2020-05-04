Function Get-SpnsByDisplayName
{
    <#
        .SYNOPSIS
            Cmdlet for retrieving Azure Active Directory Applications and Service Principals.

        .DESCRIPTION
            This function will retrieve Azure Active Directory Applications and Service Principals.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving

        .EXAMPLE
            PS c:\> Get-SpnsByDisplayName $DisplayName

            This will retrieve all service principals by display name using a wildcard
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )

    Write-PSFMessage -Level Verbose "Retrieving SPN's by Display Name" -FunctionName Internal -ModuleName PSServicePrincipal
    $DisplayNameWC = $DisplayName, "*" -join ""
    Get-AzADServicePrincipal | Where-Object DisplayName -like $DisplayNameWC | Select-PSFObject DisplayName, ApplicationID, "ID as ObjectID"
}