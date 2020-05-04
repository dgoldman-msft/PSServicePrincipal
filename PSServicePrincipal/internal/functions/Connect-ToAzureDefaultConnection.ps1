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
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}