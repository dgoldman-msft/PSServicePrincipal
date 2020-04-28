Function Add-RoleToSPN
{
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
        [object]$spnToProcess
    )
    
    try 
    {
        $newRole = New-AzRoleAssignment -ApplicationId $newSPN.ApplicationId -RoleDefinitionName "Contributor" -ErrorAction Stop | Out-Null
        Write-PSFMessage -Level Host -Message "Appling Role Assignment: {0}" -StringValues $newRole   
    }
    catch 
    {
        Stop-PSFFunction -Message "ERROR: No certificate as base64-encoded string specified. Exiting" -EnableException $EnableException -Cmdlet $PSCmdlet -ErrorRecord $_
        return
    }
}