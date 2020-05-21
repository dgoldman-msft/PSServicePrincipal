Function Get-SpnByName
{
    <#
        .SYNOPSIS
            Filters active directory service principals by display name.

        .DESCRIPTION
            This function will retrieve a Service Principal from the Azure Active Directory by display name.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-SpnByName -DisplayName CompanySPN

            This will retrieve a service principal by display name from the Azure active directory.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, Position = 0, HelpMessage = "Display name used to retrieve a service principal")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [switch]
        $EnableException
     )

    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN by Display Name {0}" -StringValues $DisplayName
        $spnOutput = Get-AzADServicePrincipal -DisplayName $DisplayName | Select-PSFObject DisplayName, ApplicationID, "ID as ObjectID", ObjectType, Type

        [pscustomobject]@{
            DisplayName = $spnOutput.DisplayName
            ApplicationID = $spnOutput.ApplicationID
            ObjectID = $spnOutput.ObjectID
            ObjectType = $spnOutput.ObjectType
            Type = $spnOutput.Type
        } | Format-Table
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}