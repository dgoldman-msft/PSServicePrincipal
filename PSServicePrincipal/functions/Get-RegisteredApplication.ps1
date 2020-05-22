Function Get-RegisteredApplication
{
	<#
        .SYNOPSIS
            Function for retrieving Azure active directory registered application.

        .DESCRIPTION
            Retrieve an Azure active directory registered application.

        .PARAMETER DisplayName
            DisplayName of the object(s) being returned.

        .PARAMETER ObjectID
            ObjectId of the object being(s) returned.

        .PARAMETER SearchString
            SearchString filter of the object being(s) returned.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -DisplayName CompanySPN

            Return an Azure active directory registered application by DisplayName.

        .EXAMPLE
            PS c:\> Get-RegisteredApp -SearchString CompanyApp

            Return an Azure active directory registered application by SearchString.

        .EXAMPLE
            PS c:\> Get-EnterpriseApp -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Return an Azure active directory registered application by ObjectID.
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName="DisplayNameSet")]
    Param (
        [parameter(HelpMessage = "Display name  used to return registered application objects")]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "ObjectID  used to return registered application objects")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ObjectId,

        [parameter(HelpMessage = "Search filter used to return registered application objects")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SearchString,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include ObjectId, SearchString
    if((-NOT $script:AzSessionFound) -or (-NOT $script:AdSessionFound)){Connect-ToAzureInteractively}

    Invoke-PSFProtectedCommand -Action "Registered application retrieved!" -Target $parameter.Values -ScriptBlock {
        Get-AzureADApplication @parameter -ErrorAction Stop
    } -EnableException $EnableException -PSCmdlet $PSCmdlet
}
