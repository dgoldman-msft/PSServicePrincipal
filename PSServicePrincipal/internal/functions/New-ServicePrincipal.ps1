Function New-ServicePrincipal
{
    <#
        .SYNOPSIS
            Cmdlet for creating a single object service principal objects

        .DESCRIPTION
            This function will create a single object Service Principal object based on application id.

        .PARAMETER ApplicationID
            This parameter is the application id of the Azure application you are working on.

        .PARAMETER CertValue
            This parameter is a the certificate thumbprint being uploaded to the Azure registerd application.

        .PARAMETER CreateSPNWithPassword
            This parameter is a switch used when a user supplied password is passed in.

        .PARAMETER DisplayName
            This parameter is the display name of the object we are working on.

        .PARAMETER StartDate
            This parameter is the certificate NotBefore time stamp.

        .PARAMETER EndDate
            This parameter is the certificate NotAfter time stamp.

        .PARAMETER Cba
            This example creates a registered application and a self-signed certificate which is uploaded to the application and applies the correct application roll assignments.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER RegisteredApp
            This parameter is a switch used to create an Azure registered application.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -DisplayName 'CompanySPN'

            This will create a new service principal with the display name of 'CompanySPN'.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -RegisteredApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will create a new service principal with the application id '34a23ad2-dac4-4a41-bc3b-d12ddf90230e' from the newly created Azure registered application.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will create a new service principal with the application id '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> New-ServicePrincipal -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e -EnabledExceptions

            This will create a new service principal with the application id '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.

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
            $password = [guid]::NewGuid()
            $securePassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = Get-Date; EndDate = Get-Date -Year 2024; Password = $password}
            $newSpn = New-AzADServicePrincipal -ApplicationID $ApplicationID -PasswordCredential $securePassword -ErrorAction Stop
            Write-PSFMessage -Level Host -Message "SPN created with DisplayName: {0}" -StringValues $newSpn.DisplayName -FunctionName "New-SPNByAppID"
            Write-PSFMessage -Level Host -Message "SPN created with DisplayName: {0}" -StringValues $newSpn.DisplayName -FunctionName "New-SPNByAppID"
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
        if($CreateSPNWithPassword -and $DisplayName)
        {
            $password = Read-Host "Enter Password" -AsSecureString
            $securePassword = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate = Get-Date; EndDate = Get-Date -Year 2024; Password = $password}
            if($newSPN = New-AzADServicePrincipal -DisplayName $DisplayName -PasswordCredential $securePassword -ErrorAction Stop)
            {
                Write-PSFMessage -Level Host -Message "SPN created: DisplayName: {0} - Secure Password present {1}" -StringValues $newSPN.DisplayName, $newSPN.securePassword -FunctionName "New-SPNByAppID"
                $script:roleListToProcess.Add($newSpn)
                $script:spnCounter ++
                return
            }
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
            if($newSpn = New-AzADServicePrincipal -DisplayName $DisplayName -ErrorAction Stop)
            {
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newSpn.Secret)
                $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                Write-PSFMessage -Level Host -Message "SPN created with DisplayName: {0} and secret {1}" -StringValues $DisplayName, $UnsecureSecret -FunctionName "New-SPNByAppID"
                Write-PSFMessage -Level Host -Message "WARNING: Backup this key!!! If you lose it you will need to reset the credentials for this SPN" -FunctionName "New-SPNByAppID"
                $script:roleListToProcess.Add($newSpn)
                $script:spnCounter ++
                return
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        if($Cba)
        {
            $newSPN = New-AzADServicePrincipal -DisplayName $DisplayName -CertValue $CertValue -StartDate $StartDate -EndDate $EndDate -ErrorAction Stop
            Write-PSFMessage -Level Host -Message "Registered application and SPN created with DisplayName: {0}. Cert uploaded to Azure application" -StringValues $DisplayName -FunctionName "New-SPNByAppID"
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
}