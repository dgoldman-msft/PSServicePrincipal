Function Connect-ToCloudTenant
{
    <#
		.SYNOPSIS
            Makes connections to an Azure tenant and subscription.

		.DESCRIPTION
            This cmdlet will connect to an Azure tenant and subscription.

        .PARAMETER Reconnect
            This parameter is used to force a new connection to an Azure tenant.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Connect-ToCloudTenant -Reconnect

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

        $script:AdSessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction Stop
        Write-PSFMessage -Level Host -Message "AzureAD session found! Connected as {0} - Tenant {1} with Environment as {2}" -StringValues $script:AdSessionInfo.Account.Id, $script:AdSessionInfo.Tenant.Id, $script:AdSessionInfo.Environment.Name -Once "AD Connection Found" -FunctionName "Connect-ToCloudTenant"
        $script:AdSessionFound = $true
    }
    catch
    {
        Write-PSFMessage -Level Verbose -Message "No existing prior AzureAD connection." -Once "No Prior Connection" -FunctionName "Connect-ToCloudTenant"
        $script:AdSessionFound = $false
        Connect-ToAzureInteractively
    }

    try
    {
        Write-PSFMessage -Level Host -Message "Checking for an existing AzureAZ connection" -Once "No ADConnection" -FunctionName "Connect-ToCloudTenant"
        $script:AzSessionInfo = Get-AzContext

        if(-NOT $script:AzSessionInfo)
        {
            Write-PSFMessage -Level Host -Message "No existing prior AzureAZ connection." -Once "No AZ Connection" -FunctionName "Connect-ToCloudTenant"
            $script:AzSessionFound = $false
            Connect-ToAzureInteractively
        }
        else
        {
            Write-PSFMessage -Level Host -Message "AzureAZ session found! Connected to {0} as {1} - Tenant {2} - Environment as {3}" -StringValues $script:AzSessionInfo.Name, $script:AzSessionInfo.Account, $script:AzSessionInfo.Tenant, $script:AzSessionInfo.Environment.Name -Once "AZ Connection found" -FunctionName "Connect-ToCloudTenant"
            $script:AzSessionFound = $true
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}