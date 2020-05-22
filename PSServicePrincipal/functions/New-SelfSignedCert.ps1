Function New-SelfSignedCert
{
    <#
        .SYNOPSIS
            Cmdlet for creating a self-signed certificate.

        .DESCRIPTION
            This function will create a single self-signed certificate and place it in the local user and computer store locations. It will
            also export the .pfx and .cer files to a location of your choice.

        .PARAMETER CertificateName
            Name of the self-signed certificate.

        .PARAMETER DnsName
            DNS name on the self-signed certificate.

        .PARAMETER FilePath
            File path certificates are exported.

        .PARAMETER Password
            Secure password for the self-signed certificate.

        .PARAMETER RegisteredApp
            Switch used to create an Azure registered application.

        .PARAMETER SubjectAlternativeName
            SubjectAlternativeName on the self-signed certificate.

        .PARAMETER Cba
            Switch used to create a registered application, self-signed certificate, upload to the application, applies the correct application roll assignments.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -FilePath c:\temp\

            This will create a new self-signed certificate using a DNS and SubjectAlterntiveName, certificate name and export the certs to the c:\temp location

        .NOTES
            You must run PowerShell as an administrator to run this function in order to create the certificate in the LocalMachine certificate store.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName="SelfSignedCertSet")]
    param(
        [parameter(Position = 0, HelpMessage = "File path used to export the self-signed certificates")]
        [PSFValidateScript({Resolve-PSFPath $_ -Provider FileSystem -SingleItem}, ErrorMessage = "{0} - is not a legit folder" )]
        [string]
        $FilePath = (Get-PSFConfigValue -FullName "PSServicePrincipal.Cert.CertFolder"),

        [parameter(Mandatory = $True, ParameterSetName ="SelfSignedCertSet", HelpMessage = "Certificate name for self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateName,

        [parameter(Mandatory = $True, Position = 1, ParameterSetName ="SelfSignedCertSet", HelpMessage = "DNS name for self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DnsName,

        [parameter(Mandatory = $True, Position = 2, ParameterSetName='SelfSignedCertSet', HelpMessage = "SubjectAlternativeName for self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SubjectAlternativeName,

        [SecureString]
        $Password = (Read-Host "Enter your self-signed certificate secure password" -AsSecureString),

        [parameter(HelpMessage = "Passed in from New-ServicePrincipalObject for registered application and cba cert upload bind")]
        [switch]
        $RegisteredApp,

        [parameter(HelpMessage = "Passed in from New-ServicePrincipalObject for auto cba cert upload to Azure application")]
        [switch]
        $Cba,

        [switch]
        $EnableException
    )

    try
    {
        $CertStore = 'cert:\CurrentUser\my\'
        $CurrentDate = Get-Date; $EndDate = $currentDate.AddYears(1)
        Write-PSFMessage -Level Host -Message "Creating new self-signed certficate with DnsName {0} in the following certificate store {1}" -StringValues $DnsName, $certStore
        $newSelfSignedCert = New-SelfSignedCertificate -certstorelocation $CertStore -Subject $SubjectAlternativeName -Dnsname $DnsName -NotBefore $CurrentDate -NotAfter $EndDate -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeySpec KeyExchange -KeyExportPolicy Exportable -KeyUsage KeyEncipherment -KeyProtection None
        $script:certCounter ++
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        if(-NOT (Test-Path -Path $FilePath))
        {
            Write-PSFMessage -Level Host -Message "File path {0} does not exist." -StringValues $FilePath
            $userChoice = Get-PSFUserChoice -Options "1) Create a new directory", "2) Exit" -Caption "User option menu" -Message "What operation do you want to perform?"

            switch($UserChoice)
            {
                0 {if(New-Item -Path $FilePath -ItemType Directory){Write-PSFMessage -Level Host -Message "Directory {0} created!" -StringValues $FilePath}}
                1 {return}
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
        # Export the pfx and cer files
        $PFXCert = Join-Path $FilePath "$CertificateName.pfx"
        $CERCert = Join-Path $FilePath "$CertificateName.cer"
        Write-PSFMessage -Level Host -Message "Exporting self-signed certificates {0} and {1} complete!" -StringValues $PFXCert, $CERCert
        $path = $certStore + $newSelfSignedCert.thumbprint
        $null = Export-PfxCertificate -cert $path -FilePath $PFXCert -Password $Password
        [System.IO.File]::WriteAllBytes((Resolve-PSFPath $CERCert -Provider FileSystem -SingleItem -NewChild ), $newSelfSignedCert.GetRawCertData())
        $script:certExportedCounter = 2

        if($Cba -and $RegisteredApp)
        {
            $keyValue = [System.Convert]::ToBase64String($newSelfSignedCert.GetRawCertData())
            New-ServicePrincipal -DisplayName $DisplayName -CertValue $keyValue -StartDate $newSelfSignedCert.NotBefore -EndDate $newSelfSignedCert.NotAfter -Cba -RegisteredApp
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}