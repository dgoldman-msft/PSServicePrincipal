Function Connect-ToTenantInAzure
{
    <#
		.SYNOPSIS
            Cmdlet for making connections to an Azure tenant and subscription
            
		.DESCRIPTION
            This function will connect to an Azure tenant and subscription
        
        .PARAMETER Reconnect
            This parameter is used to force a new connection to an Azure tenant
        
        .PARAMETER Tenant
            This parameter is the Azure tenant you are connecting to.
        
        .PARAMETER SubscriptionId
            This parameter is that Azure subscription you are connecting to.

        .EXAMPLE
            PS c:\> Connect-ToTenant -Reconnect $Reconnect -Tenant $tenant -SubscriptionId $SubscriptionId

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant
    #>
    
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [switch]
        $Reconnect,

        [string]
        $Tenant,

        [string]
        $SubscriptionId
    )
    
    try
    {
        Write-PSFMessage -Level Host -Message "Checking for an existing connection to Azure"
        $context = Get-AzContext

        if($Reconnect)
        {
            Write-PSFMessage -Level Host -Message "Forcing a reconnection to Azure"
            
            if(($Tenant) -and ($SubscriptionId))
            {
                Connect-ToAzureInteractively -Tenant $Tenant -SubscriptionId $SubscriptionId
            }
            else
            {
                Connect-ToAzureDefaultConnection
            }
            
            return
        }
        elseif(-NOT ($context -or ($context.Subscription.Id -ne $SubscriptionId)))
        {
            Write-PSFMessage -Level Host -Message "No existing prior Azure connection. You must first connect to the Azure tenant you want to create the service principals in. Calling function: Connect-AzAccount"
            
            if(($Tenant) -and ($SubscriptionId))
            {
                Connect-ToAzureInteractively -Tenant $Tenant -SubscriptionId $SubscriptionId
            }
            else
            {
                Connect-ToAzureDefaultConnection
            }
        }
        else
        {
            Write-PSFMessage -Level Host -Message "Azure session found! Connected to {0} as {1} in tenant {2} wiht Environment as {3}" -StringValues $context.Subscription.Name, $context.Account.Id, $context.Tenant.Id, $context.Environment.Name
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_.Exception.InnerException.Message -Cmdlet $PSCmdlet -ErrorRecord $_
        return
    }
}

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
        Stop-PSFFunction -Message $_.Exception.InnerException.Message -Cmdlet $PSCmdlet -ErrorRecord $_
        return
    }
}

Function Connect-ToAzureDefaultConnection
{
    <#
		.SYNOPSIS
            Cmdlet for making an default connections to an Azure tenant and subscription
            
		.DESCRIPTION
            This function will make a default connections to an Azure tenant and subscription
        
            This parameter is that Azure subscription you are connecting to.

        .EXAMPLE
            PS c:\> Connect-ToAzureDefaultConnection

            We will attempt to make a connection to an Azure tenant or reconnect.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param()

    try
    {
        Write-PSFMessage -Level Host -Message "Connecting to Azure with Microsoft account or organizational ID credentials"
        Connect-AzAccount -ErrorAction Stop
    }
    catch
    {
        Stop-PSFFunction -Message $_.Exception.InnerException.Message -Cmdlet $PSCmdlet -ErrorRecord $_
        return
    }
}