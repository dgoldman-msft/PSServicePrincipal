Function New-SelfSignedCert
{
    <#
        .SYNOPSIS
            Cmdlet for creating a self-signed certificate

        .DESCRIPTION
            This function will create a single self-signed certificate and place it in the local user and computer store locations. It will
            also export the .pfx and .cer files to a location of your choice.

        .PARAMETER DnsName
            This parameter is the DNS stamped on the certificate

        .PARAMETER SubjectAlternativeName
            This parameter is the Subject Alternative Name stamped on the certificate

        .PARAMETER CertificateName
            This parameter is a name of the certificate

        .PARAMETER FilePath
            This parameter is a path where the certificates are saved locally

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -Subject "CN=PSServicePrincipal" -CertificateName MyNewCertificate -FilePath c:\temp\

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant.

        .NOTES
            You must run PowerShell as an administrator to run this function in order to create the certificate in the LocalMachine certificate store.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = 'True', Position = '0', ParameterSetName='SelfSignedCertSet', HelpMessage = "DNS name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DnsName,

        [parameter(Mandatory = 'True', Position = '1', ParameterSetName='SelfSignedCertSet', HelpMessage = "DNS name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SubjectAlternativeName,

        [parameter(Mandatory = 'True', Position = '2', ParameterSetName='SelfSignedCertSet', HelpMessage = "Certificate name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateName,

        [parameter(Mandatory = 'True', Position = '3', ParameterSetName='SelfSignedCertSet', HelpMessage = "File name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath
    )

    try
    {
        $securePassword = Read-Host "Enter your self-signed certificate secure password" -AsSecureString
        $certStore = 'cert:\CurrentUser\my\'
        $newUserCertificate = New-SelfSignedCertificate -certstorelocation $certStore -Subject "CN=$SubjectAlternativeName" -dnsname $DnsName -KeySpec KeyExchange
        Write-PSFMessage -Level Host -Message "New self-signed certficate with DnsName: {0} created in the following location: {1}" -StringValues $DnsName, $userCertStore -FunctionName "New-SelfSignedCert"
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
        return
    }

    try
    {
        # Test the path to see if it exists
        if(-NOT (Test-Path -Path $FilePath))
        {
            Write-PSFMessage -Level Host -Message "File path {0} does not exist." -StringValues $FilePath -FunctionName "New-SelfSignedCert"

            $userChoice = Get-PSFUserChoice -Options "1) Create a new directory", "2) Exit" -Caption "User option menu" -Message
            "What operation do you want to perform?"

            switch($UserChoice)
            {
                0
                {
                    if(New-Item -Path $FilePath -ItemType Directory)
                    {
                        Write-PSFMessage -Level Host -Message "Directory {0} created!" -StringValues $FilePath -FunctionName "New-SelfSignedCert"
                    }
                }

                1
                {exit}
            }
        }

        # This will export the pfx and cer files
        $saveCertAsPFX = Join-Path $FilePath "$CertificateName.pfx"
        $saveCertAsCER = Join-Path $FilePath "$CertificateName.cer"
        $path = $certStore + $newUserCertificate.thumbprint
        Export-PfxCertificate -cert $path -FilePath $saveCertAsPFX -Password $securePassword
        $newUserCertificate.GetRawCertData() | set-content $saveCertAsCER -Encoding Byte
        Write-PSFMessage -Level Host -Message "Exporting self-signed certificates {0} and {1} complete!" -StringValues $saveCertAsPFX, $saveCertAsCER -FunctionName "New-SelfSignedCert"
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}