Function Get-EnterpriseApp
{
	<#
        .SYNOPSIS
            Function for retrieving azure active directory enterprise application.

        .DESCRIPTION
            This function will retrieve an enterprise application (Service Principal) from the Azure active directory.

        .PARAMETER DisplayName
            This parameter is the display name of the objects you are retrieving.

        .PARAMETER EnableException
            This parameter disables user-friendly warnings and enables the throwing of exceptions.
            This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN

            This will retrieve an Azure active directory enterprise application object.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN -EnableException

            This example gets a enterprise application in AAD, after prompting for user preferences.
            If this execution fails for whatever reason (connection, bad input, ...) it will throw a terminating exception, rather than writing the default warnings.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = 'True', Position = '0', HelpMessage = "Display name used to retrieve an application")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [switch]
        $EnableException
    )

    try
    {
       if($DisplayName -eq '*')
       {
            Get-AzADApplication
            Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-EnterpriseApp"
       }
       elseif($DisplayName -ne '*')
       {
           Get-AzADApplication -DisplayName $DisplayName
           Write-PSFMessage -Level Host -Message "Values retrieved for: {0}" -StringValues $DisplayName -FunctionName "Get-EnterpriseApp"
       }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}
