Function Get-ServicePrincipalObject
{
    <#
        .SYNOPSIS
            Filters active directory service principals by display name.

        .DESCRIPTION
            Retrieve a service principal from the Azure Active Directory by display name.

        .PARAMETER ApplicationID
            ApplicationId of the object(s) being returned.

        .PARAMETER DisplayName
            DisplayName of the object(s) being returned.

        .PARAMETER ObjectID
            ObjectId of the object(s) being returned.

        .PARAMETER SearchString
            SearchString filter used on object(s) being returned.

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS c:\> Get-ServicePrincipalObject -DisplayName CompanySPN

            Get an Azure active directory enterprise application by DisplayName.

        .EXAMPLE
            PS c:\> Get-ServicePrincipalObject -SearchString "Company"

            Get an Azure active directory enterprise application by using a filter.

        .EXAMPLE
            PS c:\> Get-ServicePrincipalObject -ApplicationID 34a23ad2-dac4-4a41-bc3b-d12ddf90230e

             Return an Azure active directory enterprise application by ApplicationID.

        .EXAMPLE
            PS c:\> Get-ServicePrincipalObject -ObjectID 94b26zd1-fah2-1a25-bsc5-7h3d6j3s5g3h

            Get an Azure active directory enterprise application by ObjectID.
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(HelpMessage = "DisplayName used to return enterprise application objects")]
        [string]
        $DisplayName,

        [parameter(HelpMessage = "ApplicationId used to return enterprise application objects")]
        [guid]
        $ApplicationId,

        [parameter(HelpMessage = "ObjectId used to return enterprise application objects")]
        [String]
        $ObjectId,

        [parameter(HelpMessage = "SearchString used to return enterprise application objects")]
        [String]
        $SearchString,

        [switch]
        $EnableException
    )

    $parameter = $PSBoundParameters | ConvertTo-PSFHashtable -Include DisplayName, ObjectId, ApplicationId, SearchString
    if((-NOT $script:AzSessionFound) -or (-NOT $script:AdSessionFound)){Connect-ToAzureInteractively}
    Write-PSFMessage -Level Host "Retrieving SPN by Object(s)"

    try
    {
        $spnOutput = Get-AzADServicePrincipal @parameter | Select-PSFObject DisplayName, "ServicePrincipalNames as SPN", ApplicationId, "ID as ObjectID", ObjectType, Type
    }
    catch
    {
        Stop-PSFFunction -Message $_ -Cmdlet $PSCmdlet -ErrorRecord $_ -EnableException $EnableException
    }

    $count = 0
    foreach($item in $spnOutput)
    {
        $count++
        [pscustomobject]@{
            PSTypeName = 'PSServicePrincipal.Principal'
            ItemNumber = $count
            DisplayName = $item.DisplayName
            ApplicationID = $item.ApplicationID
            ObjectID = $item.ObjectID
            ObjectType = $item.ObjectType
            Type = $item.Type
        }
    }
}