Function Remove-AppAndSPNPair
{
	<#
        .SYNOPSIS
            Cmdlet for deleting an Azure Active Directory Application and Service Principal pair.

        .DESCRIPTION
            This function will delete an Application and Service Principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            This parameter is the ApplicationID of the object(s) you are deleting.

        .PARAMETER ObjectID
            This parameter is the ObjectID of the objects(s) you are deleting.

        .EXAMPLE
            PS c:\> Remove-AppAndSPNPair -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will remove the Azure active directory application and Service Principal object using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppAndSPNPair -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will remove the Azure active directory application and Service Principal object using the ObjectID.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    Param (
        [string]
        $ApplicationID,

        [string]
        $ObjectID
    )

    $parameters = $PSBoundParameters

    try
    {
        if($parameters.ContainsKey('ApplicationID'))
        {
                Remove-AzADServicePrincipal -ApplicationID $ApplicationID -ErrorAction Stop
        }

        if($parameters.ContainsKey('ObjectID'))
        {
                Remove-AzADServicePrincipal -ObjectID $ObjectID -ErrorAction Stop
        }

        Write-PSFMessage -Level Host "SPN {0} deleted!" -StringValues @($parameters.Values[0])
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }

    try
    {
        $userChoice = Get-PSFUserChoice -Options "1) Yes", "2) No" -Caption "Delete matching Azure application" -Message "Would you like to delete the matching Azure application?"

        switch ($userChoice)
        {
            0
            {
                if($parameters.ContainsKey('ApplicationID'))
                {
                    Remove-AzADApplication -ApplicationID $ApplicationID -ErrorAction Stop
                }

                if($parameters.ContainsKey('ObjectID'))
                {
                    Remove-AzADApplication -ObjectID $ObjectID -ErrorAction Stop
                }

                Write-PSFMessage -Level Host "Azure application {0} deleted!" -StringValues @($parameters.Values[0])
            }

            1
            {
                Write-PSFMessage -Level Host "No Azure application deleted!"
                return
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_
    }
}