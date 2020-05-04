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
        [object]
        $SpnToProcess
    )

    foreach ($spn in $SpnToProcess) {
        Invoke-PSFProtectedCommand -Action "Applying role assignment: Adding Contributor role to SPN" -Target $spn -ScriptBlock {
            Write-PSFMessage -Level Host -Message "Checking current Role Assignment. Waiting for AD Replication" -FunctionName Internal -ModuleName PSServicePrincipal
            $checkRole = Get-AzRoleAssignment -ObjectId $spn.id
            
            if(-NOT $checkRole)
            {
                $newRole = New-AzRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName "Contributor" -ErrorAction Stop
                Write-PSFMessage -Level Host -Message "Appling Role Assignment: {0} to {1}" -StringValues $newRole.RoleDefinitionName, $newRole.DisplayName -FunctionName Internal -ModuleName PSServicePrincipal
            }
            else
            {
                Write-PSFMessage -Level Host -Message "$($spn) already has this Role Assignment" -FunctionName Internal -ModuleName PSServicePrincipal
            }
        } -PSCmdlet $PSCmdlet -Continue -RetryCount 5 -RetryWait 5 -RetryErrorType Microsoft.Rest.Azure.CloudException
    }
}