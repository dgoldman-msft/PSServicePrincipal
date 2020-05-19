Function New-SelfSignedCert
{
    <#
        .SYNOPSIS
            Cmdlet for creating a self-signed certificate.

        .DESCRIPTION
            This function will create a single self-signed certificate and place it in the local user and computer store locations. It will
            also export the .pfx and .cer files to a location of your choice.

        .PARAMETER CertificateName
            This parameter is a name of the self-signed certificate.

        .PARAMETER DnsName
            This parameter is the DNS stamped on the self-signed certificate.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER Exo
            This parameter switch will force the creation of an Exchange Online registered application with necessary rights and self-signed certificate.

        .PARAMETER FilePath
            This parameter is a path where the certificates are exported locally.

        .PARAMETER Password
            This parameter is a the secure password for the self-signed certificate.

        .PARAMETER SubjectAlternativeName
            This parameter is the subject alternative name stamped on the self-signed certificate.

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -FilePath c:\temp\

            This will create a new self-signed certificate using a DNS and SubjectAlterntiveName, certificate name and export the certs to the c:\temp location.

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -FilePath c:\temp\ -EnabledExceptions

            This will create a new self-signed certificate using a DNS and SubjectAlterntiveName, certificate name and export the certs to the c:\temp location and enable
            detailed expcetion logging.

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -FilePath c:\temp\ -Exo

            This will create a new self-signed certificate using a DNS and SubjectAlterntiveName, certificate name and export the certs to the c:\temp location and uploaded
            certificate to the Exo registered application.

        .NOTES
            You must run PowerShell as an administrator to run this function in order to create the certificate in the LocalMachine certificate store.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [parameter(Position = 0, HelpMessage = "File path used to create the self-signed certificate")]
        [PSFValidateScript({Resolve-PSFPath $_ -Provider FileSystem -SingleItem}, ErrorMessage = "{0} - is not a legit folder" )]
        [string]
        $FilePath = (Get-PSFConfigValue -FullName "PSServicePrincipal.Cert.CertFolder"),

        [parameter(Mandatory = $true, Position = 1, HelpMessage = "Certificate name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateName,

        [parameter(Mandatory = $true, Position = 2, HelpMessage = "DNS name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DnsName,

        [SecureString]
        $Password = (Read-Host "Enter your self-signed certificate secure password" -AsSecureString),

        [parameter(Mandatory = $true, Position = 3, HelpMessage = "DNS name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SubjectAlternativeName,

        [switch]
        $Exo,

        [switch]
        $EnableException
    )

    try
    {
        $certStore = 'cert:\CurrentUser\my\'
        $currentDate = Get-Date
        $endDate  = $currentDate.AddYears(1)
        $newSelfSignedCert = New-SelfSignedCertificate -certstorelocation $certStore -Subject $SubjectAlternativeName -Dnsname $DnsName -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeySpec KeyExchange -KeyExportPolicy Exportable -KeyUsage KeyEncipherment -KeyProtection None -NotBefore $currentDate -NotAfter $endDate
        Write-PSFMessage -Level Host -Message "New self-signed certficate with DnsName: {0} created in the following certificate store: {1}" -StringValues $DnsName, $certStore -FunctionName "New-SelfSignedCert"
        $script:certCounter ++
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        # Test the path to see if it exists
        if(-NOT (Test-Path -Path $FilePath))
        {
            Write-PSFMessage -Level Host -Message "File path {0} does not exist." -StringValues $FilePath -FunctionName "New-SelfSignedCert"

            $userChoice = Get-PSFUserChoice -Options "1) Create a new directory", "2) Exit" -Caption "User option menu" -Message "What operation do you want to perform?"

            switch($UserChoice)
            {
                0
                {
                    if(New-Item -Path $FilePath -ItemType Directory)
                    {
                        Write-PSFMessage -Level Host -Message "Directory {0} created!" -StringValues $FilePath -FunctionName "New-SelfSignedCert"
                    }
                }

                1 {return}
            }
        }

        # Export the pfx and cer files
        $PFXCert = Join-Path $FilePath "$CertificateName.pfx"
        $CERCert = Join-Path $FilePath "$CertificateName.cer"
        $path = $certStore + $newSelfSignedCert.thumbprint
        $null = Export-PfxCertificate -cert $path -FilePath $PFXCert -Password $Password
        [System.IO.File]::WriteAllBytes((Resolve-PSFPath $CERCert -Provider FileSystem -SingleItem -NewChild ), $newSelfSignedCert.GetRawCertData())
        Write-PSFMessage -Level Host -Message "Exporting self-signed certificates {0} and {1} complete!" -StringValues $PFXCert, $CERCert -FunctionName "New-SelfSignedCert"
        $script:certExportedCounter = 2

        if($Exo)
        {
            $keyValue = [System.Convert]::ToBase64String($newSelfSignedCert.GetRawCertData())
            New-ServicePrincipal -DisplayName $DisplayName -CertValue $keyValue -StartDate $newSelfSignedCert.NotBefore -EndDate $newSelfSignedCert.NotAfter -Exo
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}