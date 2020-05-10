Function Remove-AppOrSPN
{
	<#
        .SYNOPSIS
            Deletes an single azure active directory application or service principal.

        .DESCRIPTION
            This function will delete an Application or Service Principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            This parameter is the ApplicationID of the object you are deleting.

        .PARAMETER ObjectID
            This parameter is the ObjectID of the objects you are deleting.

        .PARAMETER DeleteApp
            This parameter is switch specifiy you want to delete a Azure application.

        .PARAMETER DeleteSpn
            This parameter is switch specifiy you want to delete a Service Principal.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a Service Principal using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a Service Principal using the ObjectID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete the Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteApp -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete the Azure application using the ObjectID.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    Param (
        [string]
        $ApplicationID,

        [string]
        $ObjectID,

        [switch]
        $DeleteApp,

        [switch]
        $DeleteSpn
    )

    $parameters = $PSBoundParameters

    try
    {
        if($DeleteApp)
        {
            if($parameters.ContainsKey('ApplicationID'))
            {
                Remove-AzADApplication -ApplicationID $ApplicationID -ErrorAction Stop
            }

            if($parameters.ContainsKey('ObjectID'))
            {
                Remove-AzADApplication -ObjectID $ObjectID -ErrorAction Stop
            }

            Write-PSFMessage -Level Host "Application {0} deleted!" -StringValues @($parameters.Values[0])
            $script:appDeletedCounter ++
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }

    try
    {
        if($DeleteSpn)
        {
            if($parameters.ContainsKey('ApplicationID'))
            {
                Remove-AzADServicePrincipal -ApplicationID $ApplicationID -ErrorAction Stop
            }

            if($parameters.ContainsKey('ObjectID'))
            {
                Remove-AzADServicePrincipal -ObjectID $ObjectID -ErrorAction Stop
            }

            Write-PSFMessage -Level Host "Service Principal {0} deleted!" -StringValues @($parameters.Values[0])
            $script:appDeletedCounter ++
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}