Function Connect-ToCloudTenant
{
    <#
		.SYNOPSIS
            Cmdlet for making connections to an Azure tenant and subscription.
            
		.DESCRIPTION
            This function will connect to an Azure tenant and subscription.
        
        .PARAMETER Reconnect
            This parameter is used to force a new connection to an Azure tenant.
        
        .PARAMETER TenantId
            This parameter is the Azure tenant you are connecting to.
        
        .PARAMETER SubscriptionId
            This parameter is that Azure subscription you are connecting to.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Connect-ToCloudTenant -Tenant $tenant -SubscriptionId $SubscriptionId -Reconnect

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant
    #>
    
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [switch]
        $Reconnect,

        [string]
        $TenantId,

        [string]
        $SubscriptionId,

        [switch]
        $EnableException
    )

    $parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include TenantId, SubscriptionId

    try
    {
        Write-PSFMessage -Level Host -Message "Checking for an existing connection to Azure"
        $context = Get-AzContext

        if($Reconnect) {Write-PSFMessage -Level Host -Message "Forcing a reconnection to Azure"}
        elseif(-NOT ($context -or ($context.Subscription.Id -ne $SubscriptionId))) {
            Write-PSFMessage -Level Host -Message "No existing prior Azure connection. You must first connect to the Azure tenant you want to create the service principals in. Calling function: Connect-AzAccount"
        }
        else
        {
            Write-PSFMessage -Level Host -Message "Azure session found! Connected to {0} as {1} in tenant {2} wiht Environment as {3}" -StringValues $context.Subscription.Name, $context.Account.Id, $context.Tenant.Id, $context.Environment.Name
            return
        }

        if($Tenant -and $SubscriptionId)
        {
            Connect-ToAzureInteractively @parameters
        }
        else
        {
            Connect-ToAzureDefaultConnection
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }
}