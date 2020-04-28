Function Add-RoleToSPN {
    <#
		.SYNOPSIS
            Cmdlet for applying Role Assignments to service principal. 
            
		.DESCRIPTION
            This function just applies the Reader role to the newly created service principal object
        
        .PARAMETER spnToProcess
            This is the Service Principal object being passed in to process

        .EXAMPLE
            None

        .Notes
            None
    #>
    
    [CmdletBinding()]
    param(
        [object]$SpnToProcess
    )

    foreach ($spn in $SpnToProcess) {
        Invoke-PSFProtectedCommand -Action "Applying role assignment: Adding Contributor role to newly created SPN object - $($spn)" -Target $spn -ScriptBlock {
            $newRole = New-AzRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName "Contributor" -ErrorAction Stop
            Write-PSFMessage -Level Host -Message "Appling Role Assignment: {0}" -StringValues $newRole
        } -PSCmdlet $PSCmdlet -Continue -RetryCount 5 -RetryWait 10 #-RetryErrorType ActualExpcetionType
    } 
}