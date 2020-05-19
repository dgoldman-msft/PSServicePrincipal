Function Remove-AppOrSPN
{
	<#
        .SYNOPSIS
            Deletes an single azure active directory application or service principal.

        .DESCRIPTION
            This function will delete an Application or Service Principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            This parameter is the ApplicationID of the object you are deleting.

        .PARAMETER DeleteEnterpriseApp
            This parameter is switch used to delete an Azure enterprise application.

        .PARAMETER DeleteRegisteredApp
            This parameter is switch used to delete an Azure registered application.

        .PARAMETER DeleteSpn
            This parameter is switch used to delete a Service Principal.

        .PARAMETER DisplayName
            This parameter is the DisplayName of the object you are deleting.

        .PARAMETER ObjectID
            This parameter is the ObjectID of the objects you are deleting.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteRegisteredApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will delete a registerd application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -DisplayBane CompanyAPP

            This will delete an enterprise application using the DisplayBane 'CompanyAPP'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a enterprise application using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteEnterpriseApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            This will delete the enterprise application using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3'.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -DisplayName CompanySPN

            This will delete a Service Principal using the DisplayName.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteApp -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete the Azure application using the ApplicationID.

        .EXAMPLE
            PS c:\> Remove-AppOrSPN -DeleteSpn -ObjectID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            This will delete a Service Principal using the ObjectID.
     #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationID,

        [switch]
        $DeleteEnterpriseApp,

        [switch]
        $DeleteRegisteredApp,

        [switch]
        $DeleteSpn,

        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID
    )

    try
    {
        if($DeleteEnterpriseApp)
        {
            if($DisplayName)
            {
                if(Remove-AzADApplication -DisplayName $DisplayName -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Enterprise Application {0} deleted!" -StringValues $DisplayName
                    $wasDeleted = $True
                }
            }

            if($ApplicationID)
            {
                if(Remove-AzADApplication -ApplicationID $ApplicationID -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Enterprise Application {0} deleted!" -StringValues $ApplicationID
                    $wasDeleted = $True
                }
            }

            if($ObjectID)
            {
                if(Remove-AzADApplication -ObjectID $ObjectID -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Enterprise Application {0} deleted!" -StringValues $ObjectID
                    $wasDeleted = $True
                }
            }

            if($wasDeleted) {$script:appDeletedCounter ++}
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
        return
    }

    try
    {
        if($DeleteRegisteredApp)
        {
            if($ObjectID)
            {
                if(Remove-AzureADApplication -ObjectID $ObjectID -ErrorAction Stop)
                {
                     Write-PSFMessage -Level Host "Application {0} deleted!" -StringValues $ObjectID
                     $script:appDeletedCounter ++
                }
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $true
        return
    }

    try
    {
        if($DeleteSpn)
        {
            if($DisplayName)
            {
                if(Remove-AzADServicePrincipal -DisplayName $DisplayName -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Service Principal {0} deleted!" -StringValues $DisplayName
                }
            }

            if($ApplicationID)
            {
                if(Remove-AzADServicePrincipal -ApplicationID $ApplicationID -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Service Principal {0} deleted!" -StringValues $ApplicationID
                }
            }

            if($ObjectID)
            {
                if(Remove-AzADServicePrincipal -ObjectID $ObjectID -ErrorAction Stop)
                {
                    Write-PSFMessage -Level Host "Service Principal {0} deleted!" -StringValues $ObjectID
                }
            }

            if($wasDeleted) {$script:appDeletedCounter ++}
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException
        return
    }
}