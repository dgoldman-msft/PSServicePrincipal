Function New-ServicePrincipal
{
    <#
        .SYNOPSIS
            Cmdlet for creating a single object service principal objects

        .DESCRIPTION
            Create a single object Service Principal object based on application id.

        .PARAMETER ApplicationID
            Application id of the Azure application you are working on.

        .PARAMETER CertValue
            Certificate thumbprint being uploaded to the Azure registerd application.

        .PARAMETER CreateSPNWithPassword
            Used when a user supplied password is passed in.

        .PARAMETER DisplayName
            Display name of the object we are working on.

        .PARAMETER StartDate
            Certificate NotBefore time stamp.

        .PARAMETER EndDate
            Certificate NotAfter time stamp.

        .PARAMETER Cba
            Switch used to create a registered application, self-signed certificate, upload to the application, applies the correct application roll assignments.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER RegisteredApp
            Used to create an Azure registered application.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -DisplayName 'CompanySPN'

            Create a new service principal with the display name of 'CompanySPN'.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -RegisteredApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Create a new service principal with the application id '34a23ad2-dac4-4a41-bc3b-d12ddf90230e' from the newly created Azure registered application.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Create a new service principal with the application id '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [switch]
        $RegisteredApp,

        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [ValidateNotNullOrEmpty()]
        [string]
        $CertValue,

        [switch]
        $CreateSPNWithPassword,

        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [DateTime]
        $StartDate,

        [ValidateNotNullOrEmpty()]
        [DateTime]
        $EndDate,

        [switch]
        $Cba,

        [switch]
        $EnableException
    )

    try
    {
        # We can not create applications or service principals with special characters and spaces via Powershell but can in the azure portal
        $DisplayName -replace '[\W]', ''

        if($RegisteredApp -and $ApplicationID)
        {
            # Registered Application needs ApplicationID
            Write-PSFMessage -Level Host -Message "Creating SPN with ApplicationID {0}" -StringValues $newSpn.ApplicationID
            $password = [guid]::NewGuid()
            $currentDate = Get-Date # Date here has to be different that cert date passed in
            $endCurrentDate = ($currentDate.AddYears(1))
            $securePassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = $currentDate; EndDate = $endCurrentDate; Password = $password}
            $newSpn = New-AzADServicePrincipal -ApplicationID $ApplicationID -PasswordCredential $securePassword -ErrorAction Stop
            $script:roleListToProcess.Add($newSpn)
            $script:spnCounter ++
            return
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        if($DisplayName -and $CreateSPNWithPassword)
        {
            $password = Read-Host "Enter Password" -AsSecureString
            $securePassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = $StartDate; EndDate = $EndDate; Password = $password}
            Write-PSFMessage -Level Host -Message "Creating SPN {0} - Secure Password {1}" -StringValues $newSPN.DisplayName, $newSPN.securePassword
            $newSPN = New-AzADServicePrincipal -DisplayName $DisplayName -PasswordCredential $securePassword -ErrorAction Stop
            $script:roleListToProcess.Add($newSpn)
            $script:spnCounter ++
            return
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        if(($DisplayName) -and (-NOT $RegisteredApp))
        {
            # Enterprise Application (Service Principal) needs display name because it creates the pair
            Write-PSFMessage -Level Host -Message "Creating SPN DisplayName {0} and secret {1}" -StringValues $DisplayName, $UnsecureSecret
            $newSpn = New-AzADServicePrincipal -DisplayName $DisplayName -ErrorAction Stop
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newSpn.Secret)
            $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            Write-PSFMessage -Level Host -Message "WARNING: Backup this key!!! If you lose it you will need to reset the credentials for this SPN"
            $script:roleListToProcess.Add($newSpn)
            $script:spnCounter ++
            return
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        if($DisplayName -and $RegisteredApp -and $Cba)
        {
            Write-PSFMessage -Level Host -Message "Creating registered application and SPN {0}. Certificate uploaded to Azure application" -StringValues $DisplayName
            $newSPN = New-AzADServicePrincipal -DisplayName $DisplayName -CertValue $CertValue -StartDate $StartDate -EndDate $EndDate -ErrorAction Stop
            $script:roleListToProcess.Add($newSpn)
            $script:appCounter ++
            return
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }
}