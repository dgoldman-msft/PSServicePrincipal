Function Connect-ToCloudTenant {
    <#
		.SYNOPSIS
            Makes connections to an Azure tenant and subscription.

		.DESCRIPTION
            Connect to an Azure tenant and subscription.

        .PARAMETER Reconnect
            Used to force a new connection to an Azure tenant.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Connect-ToCloudTenant -Reconnect

            Makes a connection to an Azure tenant or reconnect to another specified tenant.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [switch]
        $Reconnect,

        [switch]
        $EnableException
    )

    process {
        try {
            if ($Reconnect) {
                Write-PSFMessage -Level Host -Message "Forcing a reconnection to Azure" -Once "Forcing Connection"
                $Credentials = Get-Credential -Message "Please enter your credentials for Connect-AzureAD"
                $script:AdSessionInfo = Connect-AzureAD -Credential $Credentials -ErrorAction Stop
                $script:AdSessionFound = $true
                Write-PSFMessage -Level Host -Message "Connected to AzureAD successful as {0}" -StringValues $Credentials.UserName -Once "AzureAD Logon Successful"

                $Credentials = Get-Credential -Message "Please enter your credentials for Connect-AzAccount"
                $script:AzSessionInfo = Connect-AzAccount -Credential $Credentials -ErrorAction Stop
                $script:AzSessionFound = $true
                Write-PSFMessage -Level Host -Message "Connected to AzureAZ successful as {0}" -StringValues $Credentials.UserName -Once "AzureAZ Logon Successful"
                return
            }

            $script:AdSessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction Stop
            Write-PSFMessage -Level Host -Message "AzureAD session found! Connected as {0} - Tenant {1} with Environment as {2}" -StringValues $script:AdSessionInfo.Account.Id, $script:AdSessionInfo.Tenant.Id, $script:AdSessionInfo.Environment.Name -Once "AD Connection Found"
            $script:AdSessionFound = $true
        }
        catch {
            Write-PSFMessage -Level Verbose -Message "No existing prior AzureAD connection." -Once "No Prior Connection"
            $script:AdSessionFound = $false
            Connect-ToAzureInteractively
        }

        try {
            Write-PSFMessage -Level Host -Message "Checking for an existing AzureAZ connection" -Once "No ADConnection"
            $script:AzSessionInfo = Get-AzContext

            if (-NOT $script:AzSessionInfo) {
                Write-PSFMessage -Level Host -Message "No existing prior AzureAZ connection." -Once "No AZ Connection"
                $script:AzSessionFound = $false
                Connect-ToAzureInteractively
            }
            else {
                Write-PSFMessage -Level Host -Message "AzureAZ session found! Connected to {0} as {1} - Tenant {2} - Environment as {3}" -StringValues $script:AzSessionInfo.Name, $script:AzSessionInfo.Account, $script:AzSessionInfo.Tenant, $script:AzSessionInfo.Environment.Name -Once "AZ Connection found"
                $script:AzSessionFound = $true
            }
        }
        catch {
            Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        }
    }
}