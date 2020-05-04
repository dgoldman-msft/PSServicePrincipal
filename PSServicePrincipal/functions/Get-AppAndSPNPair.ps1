Function Get-AppAndSPNPair
{
	<#
        .SYNOPSIS
            Cmdlet for retrieving Azure Active Directory Applications and Service Principals.

        .DESCRIPTION
            This function will retrieve an Azure Active Directory Application and Service Principals pair.
            
        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving

        .EXAMPLE
            PS c:\> Get-AppAndSPNPair -DisplayName App1234

            This will retrieve the Azure active directory application and Service Principal object
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )
    
    try
    {
        Write-PSFMessage -Level Verbose "Retrieving SPN's by Display Name" -FunctionName Internal -ModuleName PSServicePrincipal
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
