Function Get-LogFolder
{
    <#
        .SYNOPSIS
            Logs module information to output and debug logging folders.

        .DESCRIPTION
            Open the logging or debug logging directory.

        .PARAMETER LogFolder
            Tab complete allowing you to open the module debug logging folder which contains indepth debug logs for the logging provider.

        .EXAMPLE
            PS c:\> Get-LogFolder -LogFolder OutputLoggingFolder

            Open the output log folder.

        .EXAMPLE
            PS c:\> Get-LogFolder -LogFolder DebugLoggingFolder

            Open the debug output log folder.
    #>

    [CmdletBinding()]
    Param (
        [string]
        $LogFolder
    )

    switch ($LogFolder)
    {
        "OutputLoggingFolder"
        {
            $loggingFolder = Get-PSFConfigValue -FullName "PSServicePrincipal.Logging.PSServicePrincipal.LoggingFolderPath"
            Write-PSFMessage -Level Verbose -Message "Opening default module logging folder: {0}" -StringValues $loggingFolder
            $loggingFolder | Invoke-Item
        }

        "DebugLoggingFolder" {
            $debugFolder = Get-PSFConfigValue -FullName "PSFramework.Logging.FileSystem.LogPath"
            Write-PSFMessage -Level Verbose -Message "Opening debug logging folder: {0}" -StringValues $debugFolder
            $debugFolder | Invoke-Item
        }
    }
}