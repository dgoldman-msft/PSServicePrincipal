Function Get-LogFolder {
    <#
        .SYNOPSIS
            Cmdlet for creating opening log folder paths.

        .DESCRIPTION
            This function will open your general output logging directory or your debug logging directory
            
        .PARAMETER LogFolder
            This parameter will tab complete allowing you to open the module debug logging folder which contains indepth debug logs for the logging provider

        .EXAMPLE
            PS c:\> Get-LogFolder -LogFolder OutputLoggingFolder

            This will open the output log folder for this module
        
        .EXAMPLE
            PS c:\> Get-LogFolder -LogFolder DebugLoggingFolder

            This will open the debug output log folder for this module
           
    #>
    
    [CmdletBinding()]
    Param (
        [string]
        $LogFolder
    )
    
    switch ($LogFolder) {
        "OutputLoggingFolder" {
            $loggingFolder = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "\PowerShell Script Logging"
            Write-PSFMessage -Level Host -Message "Opening default module logging folder: {0}" -StringValues $loggingFolder
            $loggingFolder | Invoke-Item
        }

        "DebugLoggingFolder" {
            $debugFolder = Get-PSFConfigValue -FullName "PSFramework.Logging.FileSystem.LogPath"
            Write-PSFMessage -Level Host -Message "Opening debug logging folder: {0}" -StringValues $debugFolder
            $debugFolder | Invoke-Item
        }
    }
}