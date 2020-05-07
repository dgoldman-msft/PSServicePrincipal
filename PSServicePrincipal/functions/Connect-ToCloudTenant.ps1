Function Connect-ToCloudTenant
{
    <#
		.SYNOPSIS
            Makes connections to an Azure tenant and subscription.

		.DESCRIPTION
            This cmdlet will connect to an Azure tenant and subscription.

        .PARAMETER Reconnect
            This parameter is used to force a new connection to an Azure tenant.

        .PARAMETER TenantID
            This parameter is the Azure TenantID you are connecting to.

        .PARAMETER SubscriptionID
            This parameter is that Azure SubscriptionID you are connecting to.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Connect-ToCloudTenant -Tenant $tenant -SubscriptionId $SubscriptionId -Reconnect

            These parameters will be used to make a connection to an Azure tenant or reconnect to another specified tenant
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [switch]
        $Reconnect,

        [switch]
        $EnableException
    )

    try
    {
        if($Reconnect)
        {
            Write-PSFMessage -Level Host -Message "Forcing a reconnection to Azure" -Once "Forcing Connection" -FunctionName "Connect-ToCloudTenant"
            Connect-ToAzureDefaultConnection
            return
        }

        $script:AdSession = Get-AzureADCurrentSessionInfo -ErrorAction Stop
        Write-PSFMessage -Level Host -Message "AzureAD session found! Connected as {0} - Tenant {1} with Environment as {2}" -StringValues $script:AdSession.Account.Id, $script:AdSession.Tenant.Id, $script:AdSession.Environment.Name -Once "AD Connection Found" -FunctionName "Connect-ToCloudTenant"
        $script:adSessionFound = $true
    }
    catch
    {
        Write-PSFMessage -Level Verbose -Message "No existing prior AzureAD connection." -Once "No Prior Connection" -FunctionName "Connect-ToCloudTenant"
        $script:adSessionFound = $false
        Connect-ToAzureInteractively
    }

    try
    {
        Write-PSFMessage -Level Host -Message "Checking for an existing AzureAZ connection" -Once "No ADConnection" -FunctionName "Connect-ToCloudTenant"
        $script:AzSession = Get-AzContext

        if(-NOT $script:AzSession)
        {
            Write-PSFMessage -Level Host -Message "No existing prior AzureAZ connection." -Once "No AZ Connection" -FunctionName "Connect-ToCloudTenant"
            $script:azSessionFound = $false
            Connect-ToAzureInteractively
        }
        else
        {
            Write-PSFMessage -Level Host -Message "AzureAZ session found! Connected to {0} as {1} - Tenant {2} - Environment as {3}" -StringValues $script:AzSession.Name, $script:AzSession.Account, $script:AzSession.Tenant, $script:AzSession.Environment.Name -Once "AZ Connection found" -FunctionName "Connect-ToCloudTenant"
            $script:azSessionFound = $true
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }
}