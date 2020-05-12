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

        .PARAMETER CertificateName
            This parameter is a name of the certificate

        .PARAMETER FilePath
            This parameter is a path where the certificates are saved locally

        .EXAMPLE
            PS c:\> New-SelfSignedCert -DnsName yourtenant.onmicrosoft.com -FilePath c:\temp\ -CertificateName MyNewCertificate

            These objects will be used to make a connection to an Azure tenant or reconnect to another specified tenant.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [OutputType('System.Management.Automation.CommandInfo')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = 'True', Position = '0', ParameterSetName='SelfSignedCertSet', HelpMessage = "DNS name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DnsName,

        [parameter(Mandatory = 'True', Position = '1', ParameterSetName='SelfSignedCertSet', HelpMessage = "Certificate name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateName,

        [parameter(Mandatory = 'True', Position = '2', ParameterSetName='SelfSignedCertSet', HelpMessage = "File name used to create the self-signed certificate")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath
    )

    try
    {
        $securePassword = Read-Host "Enter your self-signed certificate secure password" -AsSecureString
        $userCertStore = 'cert:\CurrentUser\my\'
        $newUserCertificate = New-SelfSignedCertificate -certstorelocation $userCertStore -dnsname $DnsName
        Write-PSFMessage -Level Host -Message "New self-signed certficate with DnsName: {0} created in the following location: {1}" -StringValues $DnsName, $userCertStore -FunctionName "New-SelfSignedCert"
        $path = $userCertStore + $newUserCertificate.thumbprint
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
                        Write-PSFMessage -Level Host -Message "File path {0} created!" -StringValues $FilePath -FunctionName "New-SelfSignedCert"
                    }
                }

                1
                {exit}
            }
        }

        $saveCertAsPFX = Join-Path $FilePath "$CertificateName.pfx"
        $saveCertAsCER = Join-Path $FilePath "$CertificateName.cer"

        # This will export the pfx and cer files
        Write-PSFMessage -Level Host -Message "Exporting self-signed certificates {0} and {1}" -StringValues $saveCertAsPFX, $saveCertAsCER -FunctionName "New-SelfSignedCert"
        Export-PfxCertificate -cert $path -FilePath $saveCertAsPFX -Password $securePassword
        $newUserCertificate.GetRawCertData() | set-content $saveCertAsCER -Encoding Byte
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}