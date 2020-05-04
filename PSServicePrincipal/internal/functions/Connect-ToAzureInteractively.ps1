Function Connect-ToAzureInteractively
{
    <#
        .SYNOPSIS
            Cmdlet for making an interactive connections to an Azure tenant and subscription

        .DESCRIPTION
            This function will make an interactive connections to an Azure tenant and subscription
        
        .PARAMETER Tenant
            This parameter is the Azure tenant you are connecting to.
        
        .PARAMETER SubscriptionId
            This parameter is that Azure subscription you are connecting to.

        .EXAMPLE
            PS c:\> Connect-ToAzureInteractively -Tenant $tenant -SubscriptionId $SubscriptionId

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant
    #>
    
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [string]
        $Tenant,

        [string]
        $SubscriptionId
    )

    try
    {
        Write-PSFMessage -Level Host -Message "Connecting to Azure with interactive logon as: {0} - {1}" -StringValues $TenantId, $SubscriptionId
        Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -ErrorAction Stop
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}