Function Remove-EnterpriseAppAndSPNPair
{
	<#
        .SYNOPSIS
            Deletes an azure active directory application and service principal pair.

        .DESCRIPTION
            This function will delete an enterprise application and service principal pair from the Azure Active Directory.

        .PARAMETER DisplayName
            This parameter is the DisplayName of the objects you are deleting.

        .PARAMETER ApplicationID
            This parameter is the ApplicationID of the object you are deleting.

        .PARAMETER ObjectID
            This parameter is the ObjectID of the objects you are deleting.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -DisplayName CompanySPN

            This will remove the Azure active directory application and service principal object using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will remove the Azure active directory application and service principal object using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will remove the Azure active directory application and service principal object using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID,

        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName
    )

    try
    {
        if($DisplayName)
        {
            if(Remove-AzADServicePrincipal -DisplayName $DisplayName -ErrorAction Stop -ErrorVariable ProcessError)
            {
                Write-PSFMessage -Level Host "SPN {0} deleted!" -StringValues $DisplayName
                $wasDeleted = $True
            }
        }

        if($ApplicationID)
        {
            if(Remove-AzADServicePrincipal -ApplicationID $ApplicationID -ErrorAction Stop -ErrorVariable ProcessError)
            {
                Write-PSFMessage -Level Host "SPN {0} deleted!" -StringValues $ApplicationID
                $wasDeleted = $True
            }
        }

        if($ObjectID)
        {
            if(Remove-AzADServicePrincipal -ObjectID $ObjectID -ErrorAction Stop -ErrorVariable ProcessError)
            {
                Write-PSFMessage -Level Host "SPN {0} deleted!" -StringValues $ObjectID
                $wasDeleted = $True
            }
        }

        if($wasDeleted){$script:appDeletedCounter ++}
    }
    catch
    {
        if ($ProcessError)
        {
            Write-PSFMessage -Level Warning "WARNING: {0}" -StringValues $ProcessError.Exception.Message
            Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
            return
        }
    }

    try
    {
        $userChoice = Get-PSFUserChoice -Options "1) Yes", "2) No" -Caption "Delete matching Azure enterprise application" -Message "Would you like to delete the matching Azure enterprise application?"

        switch ($userChoice)
        {
            0
            {
                if($DisplayName)
                {
                   if(Remove-AzADApplication -DisplayName $DisplayName -ErrorAction Stop)
                   {
                        Write-PSFMessage -Level Host "Azure enterprise application {0} deleted!" -StringValues $DisplayName
                        $wasDeleted = $True
                   }
                }

                if($ApplicationID)
                {
                    if(Remove-AzADApplication -ApplicationID $ApplicationID -ErrorAction Stop)
                    {
                        Write-PSFMessage -Level Host "Azure enterprise application {0} deleted!" -StringValues $ApplicationID
                        $wasDeleted = $True
                    }
                }

                if($ObjectID)
                {
                    if(Remove-AzADApplication -ObjectID $ObjectID -ErrorAction Stop)
                    {
                        Write-PSFMessage -Level Host "Azure enterprise application {0} deleted!" -StringValues $ObjectID
                        $wasDeleted = $True
                    }
                }

                if($wasDeleted){$script:appDeletedCounter ++}
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
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
    }
}