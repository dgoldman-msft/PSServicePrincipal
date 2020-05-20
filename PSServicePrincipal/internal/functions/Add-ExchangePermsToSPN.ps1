Function Add-ExchangePermsToSPN.ps1
{
     <#
        .SYNOPSIS
            Applies the Manage.Exchange permissions to a registered application.

        .DESCRIPTION
            This function will apply the necessary application permissions needed for Exchange V2 CBA.

        .PARAMETER DisplayName
             This parameter is the display name of the object we are stamping.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Add-ExchangePermsToSPN -DisplayName 'CompanySPN'

            This will stamp the permissions on a registerd application by application id from the Azure active directory.

        .EXAMPLE
            PS c:\> Add-ExchangePermsToSPN -Reconnect -EnableException

            This will stamp the permissions on a registerd application by application id from the Azure active directory.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Position = '0', HelpMessage = "ApplicationID used to retrieve an application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [switch]
        $EnableException
    )

    try
    {
        $O365SvcPrincipal = Get-AzureADServicePrincipal -All $true | Where-object { $_.DisplayName -eq "Office 365 Exchange Online"}
        $reqExoAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
        $reqExoAccess.ResourceAppId = $O365SvcPrincipal.AppId
        $delegatedPermissions = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "dc50a0fb-09a3-484d-be87-e023b12c6440", "Role" # Manage Exchange As Application

        $reqExoAccess.ResourceAccess = $delegatedPermissions
        $ADApplication = get-AzureADApplication -SearchString $DisplayName
        Set-AzureADApplication -ObjectId $ADApplication.ObjectId -RequiredResourceAccess $reqExoAccess
        Write-PSFMessage -Level Host -Message "Exchange.Manage permissions has been applied to application {0}. To complete setup access your application in the portal and Grant admin consent." -StringValues $DisplayName -FunctionName "Add-ExchangePermsToSPN"
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }
}