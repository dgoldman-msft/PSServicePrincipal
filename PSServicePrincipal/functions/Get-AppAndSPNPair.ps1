Function Get-AppAndSPNPair
{
	<#
        .SYNOPSIS
            Cmdlet for retrieving Azure Active Directory Applications and Service Principal pair.

        .DESCRIPTION
            This function will retrieve an Application and Service Principal pair from the Azure Active Directory.
            
        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .EXAMPLE
            PS c:\> Get-AppAndSPNPair -DisplayName App1234

            This will retrieve the Azure active directory application and Service Principal object.
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
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
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}
