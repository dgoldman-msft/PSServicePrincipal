Function Get-AppAndSPNPair
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory applications and service principal pair.

        .DESCRIPTION
            This function will retrieve an application and service principal pair from the Azure active Directory.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-AppAndSPNPair -DisplayName CompanySPN

            This will retrieve the Azure active directory application and Service Principal object.

        .EXAMPLE
            PS c:\> Get-AppAndSPNPair -DisplayName CompanySPN -EnableException

            This example gets a new service principal / application pair in AAD, after prompting for user preferences.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName,

        [switch]
        $EnableException
    )

    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN's by Display Name"
        $spnOutput = Get-AzADServicePrincipal -DisplayName $DisplayName

        [pscustomobject]@{
            ObjectType = "Service Princpial"
            DisplayName = $spnOutput.DisplayName
            AppID = $spnOutput.ApplicationID
            ObjectID = $spnOutput.ID}

        $appOutput = Get-AzADApplication -DisplayName $DisplayName

        [pscustomobject]@{
            ObjectType = "Application"
            DisplayName = $appOutput.DisplayName
            AppID = $appOutput.ApplicationID
            ObjectID = $appOutput.ObjectID
        }

        Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-AppAndSPNPair"
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}
