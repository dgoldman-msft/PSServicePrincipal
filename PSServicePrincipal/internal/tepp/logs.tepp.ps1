# Registers the Tab Complete Script Block with options to be passed in when you hit the TAB key
Register-PSFTeppScriptblock -Name "PSServicePrincipal.Logs" -ScriptBlock { 'OutputLoggingFolder', 'DebugLoggingFolder' }
