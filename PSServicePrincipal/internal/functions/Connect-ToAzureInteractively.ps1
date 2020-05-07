Function Connect-ToAzureInteractively
{
    <#
        .SYNOPSIS
            Cmdlet for making an interactive connections to an Azure tenant and subscription

        .DESCRIPTION
            This function will make an interactive connections to an Azure tenant and subscription

        .EXAMPLE
            PS c:\> Connect-ToAzureInteractively

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param()

    # Can be modified by end user for interactive login to Azure
    # $TenantID = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    # $ApplicationID = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    # $CertificateThumbprint = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

    try
    {
        if(-NOT $script:adSessionFound)
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
                    Connect-AzureAD -TenantId $TenantID -ApplicationId $ApplicationID -CertificateThumbprint $CertificateThumbprint -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message "Connected to AzureAD with interactive logon"  -Once "Interactively Connected to AzureAD" -FunctionName "Connect-ToAzureInteractively"
                    return
                }
                catch
                {
                    Write-PSFMessage -Level Host -Message "Interactive logon to AzureAD failed. Defaulting to default connection state" -Once "Interactive Logon Failed" -FunctionName "Connect-ToAzureInteractively"
                    Connect-ToAzureDefaultConnection
                }
            }
        }

        if(-NOT $script:azSessionFound)
        {
            try
            {
                Connect-AzAccount -TenantId $TenantID -ApplicationId $ApplicationID -CertificateThumbprint $CertificateThumbprint -ErrorAction Stop
                Write-PSFMessage -Level Host -Message "Connected to AzureAZ with interactive logon" -Once "Interactively Connected to AzureAZ" -FunctionName "Connect-ToAzureInteractively"
            }
            catch
            {
                Write-PSFMessage -Level Host -Message "Interactive logon to AzureAZ failed. Defaulting to default connection state" -Once "Interactive Connection Failed" -FunctionName "Connect-ToAzureInteractively"
                Connect-ToAzureDefaultConnection
            }
        }

    }
    catch
    {
        Write-PSFMessage -Level Host -Message "Interactive connection failed. Defaulting to manual connection" -Once "Interactive Connection Failed. Start Manual Connection" -FunctionName "Connect-ToAzureInteractively"
        Connect-ToAzureDefaultConnection -AzSessionFound $azSessionFound
    }
}

