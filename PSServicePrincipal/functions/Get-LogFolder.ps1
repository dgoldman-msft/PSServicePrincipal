Function Get-LogFolder {
    <#
        .SYNOPSIS
            Logs module information to output and debug logging folders.

        .DESCRIPTION
            Open the logging or debug logging directory.

        .PARAMETER LogFolder
            Tab complete allowing you to open the module debug logging folder which contains in-depth debug logs for the logging provider.

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

    process {
        switch ($LogFolder) {
            "OutputLoggingFolder" {
                $loggingFolder = Get-PSFConfigValue -FullName "PSServicePrincipal.Logging.PSServicePrincipal.LoggingFolderPath"
                Invoke-PSFProtectedCommand -Action "Invoking folder item" -Target $parameter.Values  -ScriptBlock {
                    Write-PSFMessage -Level Host -Message "Openning default logging foider {0}" -StringValues $loggingFolder
                    $loggingFolder | Invoke-Item
                } -EnableException $EnableException -PSCmdlet $PSCmdlet
            }

            "DebugLoggingFolder" {
                $debugFolder = Get-PSFConfigValue -FullName "PSFramework.Logging.FileSystem.LogPath"
                Invoke-PSFProtectedCommand -Action "Invoking folder item" -Target $parameter.Values -ScriptBlock {
                    Write-PSFMessage -Level Host -Message "Openning default logging foider {0}" -StringValues $debugFolder
                    $debugFolder | Invoke-Item
                } -EnableException $EnableException -PSCmdlet $PSCmdlet
            }
        }
    }
}