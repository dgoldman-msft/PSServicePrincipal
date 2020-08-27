Function Add-RoleToSPN {
    <#
		.SYNOPSIS
            Cmdlet for applying Role Assignments to service principal.

		.DESCRIPTION
            Applies the contributor role to a service principal object.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .PARAMETER SpnToProcess
            Service principal being passed into process.

        .EXAMPLE
            PS c:\> Add-RoleToSPN -SpnToProcess $newSPN

            ArrayList of SPN objects to be processed.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [object]
        $SpnToProcess,

        [switch]
        $EnableException
    )

    process {
        foreach ($spn in $SpnToProcess) {
            Invoke-PSFProtectedCommand -Action "Applying role assignment: Adding Contributor role to SPN" -Target $spn -ScriptBlock {
                Write-PSFMessage -Level Host -Message "Checking current Role Assignment. Waiting for AD Replication"
                $checkRole = Get-AzRoleAssignment -ObjectId $spn.id

                if (-NOT $checkRole) {
                    $newRole = New-AzRoleAssignment -ApplicationId $spn.ApplicationId -RoleDefinitionName "Contributor" -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message "Appling Role Assignment: {0} to {1}" -StringValues $newRole.RoleDefinitionName, $newRole.DisplayName
                }
                else {
                    Write-PSFMessage -Level Host -Message "{0} already has this role assignment" -StringValues $spn.DisplayName
                }
            } -PSCmdlet $PSCmdlet -Continue -RetryCount 5 -RetryWait 5 -RetryErrorType Microsoft.Rest.Azure.CloudException -EnableException $EnableException
        }
    }
}