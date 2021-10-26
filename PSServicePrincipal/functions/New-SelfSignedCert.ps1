Function New-SelfSignedCert {
    <#
        .SYNOPSIS
            Cmdlet for creating a self-signed certificate.

        .DESCRIPTION
            This function will create a single self-signed certificate and place it in the local user and computer store locations. It will
            also export the .pfx and .cer files to a location of your choice.

        .PARAMETER CertificateName
            Name of the self-signed certificate.

        .PARAMETER CertStore
            Name of the certificate store being used.

        .PARAMETER DnsName
            DNS name on the self-signed certificate.

        .PARAMETER CertFolder
            File path certificates are exported.

        .PARAMETER Password
            Secure password for the self-signed certificate.

        .PARAMETER Years
            Number of years for certificate expiry

        .PARAMETER RegisteredApp
            Switch used to create an Azure registered application.

        .PARAMETER UploadCertToApp
            Switch used to upload a certificate to an Azure registered application.

        .PARAMETER SubjectAlternativeName
            SubjectAlternativeName on the self-signed certificate.

        .PARAMETER FriendlyName
            FriendlyName on the self-signed certificate.

        .PARAMETER Cba
            Switch used to create a registered application, self-signed certificate, upload to the application, applies the correct application roll assignments.

        .PARAMETER UploadCertToApp
            Switch used to create a registered application, self-signed certificate, upload to the application, applies the correct application roll assignments.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -CertFolder c:\temp\

            This will create a new self-signed certificate using a DNS and SubjectAlterntiveName, certificate name and export the certs to the c:\temp location

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -Password (ConvertTo-SecureString 'YourPassword' -AsPlainText -force)

            This will create a new self-signed certificate with a passed in secure password

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -CertStore LocalMachine -Password (ConvertTo-SecureString 'YourPassword' -AsPlainText -force)

            This will create a new self-signed certificate with a passed in secure password in the LocalMachine certificate store

        .NOTES
            You must run PowerShell as an administrator to run this function in order to create the certificate in the LocalMachine certificate store and to export to disk.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName = "SelfSignedCertSet")]
    param(
        [parameter(Position = 0, HelpMessage = "File path used to export the self-signed certificates")]
        [PSFValidateScript( { Resolve-PSFPath $_ -Provider FileSystem -SingleItem }, ErrorMessage = "{0} - is not a legit folder" )]
        [string]
        $CertFolder = (Get-PSFConfigValue -FullName "PSServicePrincipal.Cert.CertFolder"),

        [parameter(Mandatory = $True, ParameterSetName = "SelfSignedCertSet", HelpMessage = "Certificate name for the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateName,

        [parameter(ParameterSetName = "SelfSignedCertSet", HelpMessage = "Certificate store name [CurrentUser or LocalMachine]")]
        [ValidateSet("CurrentUser", "LocalMachine")]
        [string]
        $CertStore = "CurrentUser",

        [parameter(Mandatory = $True, Position = 1, ParameterSetName = "SelfSignedCertSet", HelpMessage = "DNS name for the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DnsName,

        [parameter(Mandatory = $True, Position = 2, ParameterSetName = 'SelfSignedCertSet', HelpMessage = "SubjectAlternativeName for the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SubjectAlternativeName,

        [parameter(Mandatory = $True, Position = 2, ParameterSetName = 'SelfSignedCertSet', HelpMessage = "FriendlyName for the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FriendlyName,

        [SecureString]
        $Password = (Read-Host "Enter your self-signed certificate secure password" -AsSecureString),
        
        [ValidateRange(1,5)]
        [Int]
        $Years = "2",

        [parameter(HelpMessage = "Passed in from New-ServicePrincipalObject for registered application and cba cert upload bind")]
        [switch]
        $RegisteredApp,

        [parameter(HelpMessage = "Switch for uploading a certificate to a registered application")]
        [switch]
        $UploadCertToApp,

        [parameter(HelpMessage = "Passed in from New-ServicePrincipalObject for auto cba cert upload to Azure application")]
        [switch]
        $Cba,

        [switch]
        $EnableException
    )

    process {
        try {
            if ($CertStore -eq "CurrentUser") {
                Write-PSFMessage -Level Host -Message "Defaulted to CurrentUser certificate store"
                $store = 'cert:\CurrentUser\my\'
            }
            If ($CertStore -eq "LocalMachine") {
                Write-PSFMessage -Level Host -Message "User selected LocalMachine certificate store. Checking for elevated permissions."
                if (-NOT (Test-PSFPowerShell -Elevated)) {
                    Write-PSFMessage -Level Host -Message "In order to save a certificate to the LocalMachine certificate store PowerShell needs to run as an administrator. Exiting" -StringValues $module
                    return
                }
                else { $store = 'cert:\LocalMachine\My\' }
            }
            
            $currentDate = Get-Date; $EndDate = $currentDate.AddYears($Years)
            Write-PSFMessage -Level Host -Message "Creating new self-signed certficate with DnsName {0} in the following certificate store {1}" -StringValues $DnsName, $store
            $newSelfSignedCert = New-SelfSignedCertificate -certstorelocation $store -Subject $SubjectAlternativeName -FriendlyName $FriendlyName -Dnsname $DnsName -NotBefore $currentDate -NotAfter $EndDate -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeySpec KeyExchange -KeyExportPolicy Exportable -KeyUsage KeyEncipherment -KeyProtection None
            $script:certCounter ++
        }
        catch {
            Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
            return
        }

        try {
            if (-NOT (Test-Path -Path $CertFolder)) {
                Write-PSFMessage -Level Host -Message "File path {0} does not exist." -StringValues $CertFolder
                $userChoice = Get-PSFUserChoice -Options "1) Create a new directory", "2) Exit" -Caption "User option menu" -Message "What operation do you want to perform?"

                switch ($UserChoice) {
                    0 { if (New-Item -Path $CertFolder -ItemType Directory) { Write-PSFMessage -Level Host -Message "Directory {0} created!" -StringValues $CertFolder } }
                    1 { return }
                }
            }
        }
        catch {
            Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
            return
        }

        try {
            # Export the pfx and cer files
            $PFXCert = Join-Path $CertFolder "$CertificateName.pfx"
            $CERCert = Join-Path $CertFolder "$CertificateName.cer"
            $path = $store + $newSelfSignedCert.thumbprint
            $null = Export-PfxCertificate -cert $path -FilePath $PFXCert -Password $Password
            [System.IO.File]::WriteAllBytes((Resolve-PSFPath $CERCert -Provider FileSystem -SingleItem -NewChild ), $newSelfSignedCert.GetRawCertData())
            Write-PSFMessage -Level Host -Message "Certificated created sucessfully! Exporting self-signed certificates {0} and {1} complete!" -StringValues $PFXCert, $CERCert
            $script:certExportedCounter = 2

            if ($Cba -and $RegisteredApp) {
                $keyValue = [System.Convert]::ToBase64String($newSelfSignedCert.GetRawCertData())
                New-ServicePrincipal -DisplayName $DisplayName -CertValue $keyValue -StartDate $newSelfSignedCert.NotBefore -EndDate $newSelfSignedCert.NotAfter -Cba -RegisteredApp
            }

            if ($UploadCertToApp -and $RegisteredApp) {
                $keyValue = [System.Convert]::ToBase64String($newSelfSignedCert.GetRawCertData())
                New-ServicePrincipal -DisplayName $DisplayName -CertValue $keyValue -StartDate $newSelfSignedCert.NotBefore -EndDate $newSelfSignedCert.NotAfter -UploadCertToApp -RegisteredApp
            }
        }
        catch {
            Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        }
    }
}