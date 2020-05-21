Function Remove-EnterpriseAppAndSPNPair
{
	<#
        .SYNOPSIS
            Deletes an azure active directory application and service principal pair.

        .DESCRIPTION
            Delete an enterprise application and service principal pair from the Azure Active Directory.

        .PARAMETER ApplicationID
            ApplicationID of the object you are deleting.

        .PARAMETER DisplayName
            Display name of the objects you are retrieving.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER ObjectID
            ObjectID of the objects you are deleting.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -DisplayName CompanySPN

            Remove the Azure active directory application and service principal object using the DisplayName 'CompanySPN'.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

            Remove the Azure active directory application and service principal object using the ApplicationID '34a23ad2-dac4-4a41-bc3b-d12ddf90230e'.

        .EXAMPLE
            PS c:\> Remove-EnterpriseAppAndSPNPair -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Remove the Azure active directory application and service principal object using the ObjectID '94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h'.
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
        $DisplayName,

        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectID,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include ApplicationID, DisplayName, ObjectID

    try
    {
        Write-PSFMessage -Level Host -Message "Removing service principal pair {0}" -StringValues ($PSBoundParameters.Values | Where-Object {$_ -is [string]})
        Remove-AzADServicePrincipal @parameter -ErrorAction Stop
        $script:appDeletedCounter ++
    }
    catch
    {
        Stop-PSFFunction -Message "WARNING: $_" -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
        return
    }

    try
    {
        $userChoice = Get-PSFUserChoice -Options "1) Yes", "2) No" -Caption "Delete matching Azure enterprise application" -Message "Would you like to delete the matching Azure enterprise application?"

        switch ($userChoice)
        {
            0
            {
                Write-PSFMessage -Level Host -Message "Removing application {0}" -StringValues ($PSBoundParameters.Values | Where-Object {$_ -is [string]})
                Remove-AzADApplication @parameter -ErrorAction Stop
                $script:appDeletedCounter ++
            }

            1
            {
                Write-PSFMessage -Level Host "No application deleted!"
                return
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }
}