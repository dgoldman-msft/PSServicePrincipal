Function Connect-ToAzureInteractively
{
    <#
        .SYNOPSIS
            Cmdlet for making an interactive connections to an Azure tenant and subscription.

        .DESCRIPTION
            This function will make an interactive connections to an Azure tenant and subscription. If interactive connection fails it will default to a manual connection.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Connect-ToAzureInteractively

            Make a connection to an Azure tenant.

        .EXAMPLE
            PS c:\>Connect-ToAzureInteractively -EnableException

            Make a connection to an Azure tenant.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [switch]
        $EnabledException
    )

    # Can be modified by end user for interactive login to AzureAD and AzureAZ
    #$TenantID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxx'
    #$ApplicationID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxx'
    $CertThumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -eq "CN=PSServicePrincipal" }).Thumbprint

    if(-NOT $script:AdSessionFound)
    {
        if($PSVersionTable.PSEdition -eq "Core")
        {
            Write-PSFMessage -Level Host -Message "At this time AzureAD PowerShell module does not work on PowerShell Core. Please use PowerShell version 5 or 6." -Once "PS Core Doesn't work with AzureAD" -FunctionName "Connect-ToAzureInteractively"
            $script:runningOnCore = $true
        }
        elseif($PSVersionTable.PSEdition -eq "Desktop")
        {
            try
            {
                $script:AdSessionInfo = Connect-AzureAD -TenantId $TenantID -ApplicationId $ApplicationID -CertificateThumbprint $CertThumbprint -ErrorAction Stop
                Write-PSFMessage -Level Host -Message "Connected to AzureAD with automatic logon"  -Once "Automatically connected to AzureAD" -FunctionName "Connect-ToAzureInteractively"
                $script:AdSessionFound = $true
            }
            catch
            {
                Write-PSFMessage -Level Host -Message "Automatic logon to AzureAD failed. Defaulting to interactive connection" -Once "Interactive Logon Failed" -FunctionName "Connect-ToAzureInteractively"
                $script:AdSessionFound = $false

                try
                {
                    $Credentials = Get-Credential -Message "Please enter your credentials for Connect-AzureAD"
                    $script:AdSessionInfo = Connect-AzureAD -Credential $Credentials -ErrorAction Stop
                    $script:AdSessionFound = $true
                    Write-PSFMessage -Level Host -Message "Connected to AzureAD successful" -Once "Interactive Logon Successful" -FunctionName "Connect-ToAzureInteractively"
                }
                catch
                {
                    Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnabledException
                }
            }
        }
    }

    if(-NOT $script:AzSessionFound)
    {
        try
        {
            $script:AzSessionInfo = Connect-AzAccount -ServicePrincipal -TenantId $TenantID -ApplicationId $ApplicationID -CertificateThumbprint $CertThumbprint -ErrorAction Stop
            Write-PSFMessage -Level Host -Message "Connected to AzureAZ with automatic logon" -Once "Automatically connected to AzureAZ" -FunctionName "Connect-ToAzureInteractively"
            $script:AzSessionFound = $true
        }
        catch
        {
            Write-PSFMessage -Level Host -Message "Automatic logon to AzureAZ failed. Defaulting to interactive connection" -Once "Interactive Logon Failed" -FunctionName "Connect-ToAzureInteractively"
            $script:AzSessionFound = $false

            try
            {
                $Credentials = Get-Credential -Message "Please enter your credentials for Connect-AzAccount"
                $script:AzSessionInfo = Connect-AzAccount -Credential $Credentials -ErrorAction Stop
                $script:AzSessionFound = $true
                Write-PSFMessage -Level Host -Message "Connected to AzureAZ successful" -Once "Interactive Logon Successful" -FunctionName "Connect-ToAzureInteractively"
            }
            catch
            {
                Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnabledException
            }
        }
    }
}

