Function Add-RoleToSPN
{
    <#
		.SYNOPSIS
            Cmdlet for applying Role Assignments to service principal
            
		.DESCRIPTION
            This function just applies the Reader role to the newly created service principal object
        
        .PARAMETER SpnToProcess
            This is the Service Principal object being passed in to process

        .EXAMPLE
            PS c:\> Add-RoleToSPN -SpnToProcess $newSPN

            This is passing in an ArrayList of SPN objects to be processed. We will apply a new role assigment of Contriubtor to each object.
    #>
    
    [CmdletBinding()]
    param(
        [object]$SpnToProcess
    )

    foreach ($spn in $SpnToProcess) {
        Invoke-PSFProtectedCommand -Action "Applying role assignment: Adding Contributor role to newly SPN - $($spn)" -Target $spn -ScriptBlock {
            Write-PSFMessage -Level Host -Message "Checking current Role Assignment: on SPN {0}. Waiting on AD Replication" -StringValues $spn
            $checkRole = Get-AzRoleAssignment -ObjectId $spn.id
            
            if(-NOT $checkRole)
            {
                $newRole = New-AzRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName "Contributor" -ErrorAction Stop
                Write-PSFMessage -Level Host -Message "Appling Role Assignment: {0}" -StringValues $newRole.RoleDefinitionName
            }
            else
            {
                Write-PSFMessage -Level Host -Message "$($spn) already has this Role Assignment"
            }
        } -PSCmdlet $PSCmdlet -Continue -RetryCount 5 -RetryWait 5 -RetryErrorType Microsoft.Rest.Azure.CloudException
    }
}