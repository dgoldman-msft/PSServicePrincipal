Function Get-LogFolders 
{
    <#
		.SYNOPSIS
            Cmdlet for creating opening log folder paths.
            
		.DESCRIPTION
            This function will open your general output logging directory or your debug logging directory
            
        .PARAMETER OutputLoggingFolder
            This parameters will tab complete allowing you to open the module logging folder
        
        .PARAMETER DebugLoggingFolder
            This parameters will tab complete allowing you to open the module debug logging folder which contains indepth debug logs for the logging provider

        .EXAMPLE
            PS c:\> Get-LogFolders -OutputLoggingFolder

            This will open the output log folder for this module
        
        .EXAMPLE
            PS c:\> Get-LogFiles -DebugLoggingFolder

            This will open the debug output log folder for this module
           
        .Notes
            None
            
            #>
    [CmdletBinding()]
    Param (
        [switch]
        $OutputLoggingFolder,
        [switch]
        $DebugLoggingFolder
    )
    
    if($OutputLoggingFolder)
    {
        $OutputLoggingFolder = $script:loggingFolder = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "\PowerShell Script Logging" | Invoke-Item
    }
    if($DebugLoggingFolder)
    {
        $DebugLoggingFolder = Get-PSFConfigValue -FullName "PSFramework.Logging.FileSystem.LogPath" | Invoke-Item
    }
}