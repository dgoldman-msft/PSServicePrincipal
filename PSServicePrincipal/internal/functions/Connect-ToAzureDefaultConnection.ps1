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

            We will attempt to make a connection to an Azure tenant
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param()

    try
    {
        if(-NOT $script:ADSessionFound)
        {
            if($PSVersionTable.PSEdition -eq "Core")
            {
                Write-PSFMessage -Level Host -Message "At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6" -FunctionName "Connect-ToAzureDefaultConnection"
                $script:runningOnCore = $true
            }
            elseif($PSVersionTable.PSEdition -eq "Desktop")
            {
                Write-PSFMessage -Level Host -Message "Connecting to AzureAD with Microsoft account or organizational ID credentials" -FunctionName "Connect-ToAzureDefaultConnection"
                $Credentials = Get-Credential
                $script:adSessionInfo = Connect-AzureAD -Credential $Credentials -ErrorAction Stop
            }
        }

        if(-NOT $script:AzureSessionFound)
        {
            if($PSVersionTable.PSEdition -eq "Core")
            {
                Write-PSFMessage -Level Host -Message "At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6" -FunctionName "Connect-ToAzureDefaultConnection"
                $script:runningOnCore = $true
            }
            elseif($PSVersionTable.PSEdition -eq "Desktop")
            {
                Write-PSFMessage -Level Host -Message "Connecting to AzureAD with Microsoft account or organizational ID credentials" -FunctionName "Connect-ToAzureDefaultConnection"
                $Credentials = Get-Credential
                $script:azSessionInfo = Connect-AzureAD -Credential $Credentials -ErrorAction Stop
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}