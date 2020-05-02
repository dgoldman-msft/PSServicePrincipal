Function Get-AppAndSPN
{
	<#
        .SYNOPSIS
            Cmdlet for retrieving Azure Active Directory Applications and Service Principals.

        .DESCRIPTION
            This function will retrieve Azure Active Directory Applications and Service Principals.
            
        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving

        .EXAMPLE
            PS c:\> Get-AppAndSPN -DisplayName App1234

            This will retrieve the application and service principal information
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $DisplayName
    )
    
    Invoke-PSFProtectedCommand -Action "Retrieving information for Application and SPN - $($DisplayName)" -Target $DisplayName -ScriptBlock {
        Write-PSFMessage -Level Host "Retrieving Service Principal {0}" -StringValues $DisplayName -FunctionName Internal -ModuleName PSServicePrincipal
	    $spn = Get-AzADServicePrincipal -DisplayName $DisplayName
        Write-PSFMessage -Level Host "`nSPN Information`nSPN Name: {0}`nSPN ApplicationId: {1}`nObject Type: {2}`nObject Id: {3}" -StringValues $spn.ServicePrincipalNames[0], $spn.ApplicationId, $spn.ObjectType, $spn.Id -FunctionName Internal -ModuleName PSServicePrincipal
    
        Write-PSFMessage -Level Host "Retrieving Application - {0}" -StringValues $DisplayName -FunctionName Internal -ModuleName PSServicePrincipal
        $app = Get-AzADApplication -ApplicationId $spn.ApplicationId
        Write-PSFMessage -Level Host "`nApplication Information`nSPN Name: {0}`nIdentifierUris: {1}`nHomePage: {2}`nApplicationId: {3}`nAvailableToOtherTenants: {4}`nObjectType: {5}" -StringValues $app.DisplayName, $app.IdentifierUris[0], $app.HomePage, $app.ApplicationId, $app.nAvailableToOtherTenants, $app.ObjectType -FunctionName Internal -ModuleName PSServicePrincipal
    } -PSCmdlet $PSCmdlet -Continue
}