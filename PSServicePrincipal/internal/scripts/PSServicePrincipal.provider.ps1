# Action that is performed on registration of the provider using Register-PSFLoggingProvider
$registrationEvent = {

}

#region Logging Execution
# Action that is performed when starting the logging script (or the very first time if enabled after launching the logging script)
$begin_event = {
	function Get-PSServicePrincipalPath
	{
		[CmdletBinding()]
		param (

		)

		$path = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.FilePath'
		$logname = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.LogName'

		$scriptBlock = {
			param (
				[string]
				$Match
			)

			$hash = @{
				'%date%'  = (Get-Date -Format 'yyyy-MM-dd')
				'%dayofweek%' = (Get-Date).DayOfWeek
				'%day%' = (Get-Date).Day
				'%hour%'   = (Get-Date).Hour
				'%minute%' = (Get-Date).Minute
				'%username%' = $env:USERNAME
				'%userdomain%' = $env:USERDOMAIN
				'%computername%' = $env:COMPUTERNAME
				'%processid%' = $PID
				'%logname%' = $logname
			}

			$hash.$Match
		}

		[regex]::Replace($path, '%day%|%computername%|%hour%|%processid%|%date%|%username%|%dayofweek%|%minute%|%userdomain%|%logname%', $scriptBlock)
	}

	function Write-PSServicePrincipalMessage
	{
		[CmdletBinding()]
		param (
			[Parameter(ValueFromPipeline = $true)]
			$Message,

			[bool]
			$IncludeHeader,

			[string]
			$FileType,

			[string]
			$Path,

			[string]
			$CsvDelimiter,

			[string[]]
			$Headers
		)

		$parent = Split-Path $Path
		if (-not (Test-Path $parent))
		{
			$null = New-Item $parent -ItemType Directory -Force
		}
		$fileExists = Test-Path $Path

		#region Type-Based Output
		switch ($FileType)
		{
			#region Csv
			"Csv"
			{
				if ((-not $fileExists) -and $IncludeHeader) { $Message | ConvertTo-Csv -NoTypeInformation -Delimiter $CsvDelimiter | Set-Content -Path $Path -Encoding UTF8 }
				else { $Message | ConvertTo-Csv -NoTypeInformation -Delimiter $CsvDelimiter | Select-Object -Skip 1 | Add-Content -Path $Path -Encoding UTF8 }
			}
			#endregion Csv
			#region Json
			"Json"
			{
				if ($fileExists) { Add-Content -Path $Path -Value "," -Encoding UTF8 }
				$Message | ConvertTo-Json | Add-Content -Path $Path -NoNewline -Encoding UTF8
			}
			#endregion Json
			#region XML
			"XML"
			{
				[xml]$xml = $message | ConvertTo-Xml -NoTypeInformation
				$xml.Objects.InnerXml | Add-Content -Path $Path -Encoding UTF8
			}
			#endregion XML
			#region Html
			"Html"
			{
				[xml]$xml = $message | ConvertTo-Html -Fragment

				if ((-not $fileExists) -and $IncludeHeader)
				{
					$xml.table.tr[0].OuterXml | Add-Content -Path $Path -Encoding UTF8
				}

				$xml.table.tr[1].OuterXml | Add-Content -Path $Path -Encoding UTF8
			}
			#endregion Html
		}
		#endregion Type-Based Output
	}

	$PSServicePrincipal_includeheader = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.IncludeHeader'
	$PSServicePrincipal_headers = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.Headers'
	$PSServicePrincipal_filetype = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.FileType'
	$PSServicePrincipal_CsvDelimiter = Get-PSFConfigValue -FullName 'PSServicePrincipal.Logging.PSServicePrincipal.CsvDelimiter'

	if ($PSServicePrincipal_headers -contains 'Tags')
	{
		$PSServicePrincipal_headers = $PSServicePrincipal_headers | ForEach-Object {
			switch ($_)
			{
				'Tags'
				{
					@{
						Name	   = 'Tags'
						Expression = { $_.Tags -join "," }
					}
				}
				'Message'
				{
					@{
						Name	   = 'Message'
						Expression = { $_.LogMessage }
					}
				}
				default { $_ }
			}
		}
	}

	$PSServicePrincipal_paramWriteLogFileMessage = @{
		IncludeHeader    = $PSServicePrincipal_includeheader
		FileType		 = $PSServicePrincipal_filetype
		CsvDelimiter	 = $PSServicePrincipal_CsvDelimiter
		Headers		     = $PSServicePrincipal_headers
	}
}

# Action that is performed at the beginning of each logging cycle
$start_event = {
	$PSServicePrincipal_paramWriteLogFileMessage["Path"] = Get-PSServicePrincipalPath
}

# Action that is performed for each message item that is being logged
$message_Event = {
	Param (
		$Message
	)

	$Message | Select-Object $PSServicePrincipal_headers | Write-PSServicePrincipalMessage @PSServicePrincipal_paramWriteLogFileMessage
}

# Action that is performed for each error item that is being logged
$error_Event = {
	Param (
		$ErrorItem
	)


}

# Action that is performed at the end of each logging cycle
$end_event = {

}

# Action that is performed when stopping the logging script
$final_event = {

}
#endregion Logging Execution

#region Function Extension / Integration
# Script that generates the necessary dynamic parameter for Set-PSFLoggingProvider
$configurationParameters = {
	$configroot = "PSServicePrincipal.Logging.PSServicePrincipal"

	$configurations = Get-PSFConfig -FullName "$configroot.*"

	$RuntimeParamDic = New-Object  System.Management.Automation.RuntimeDefinedParameterDictionary

	foreach ($config in $configurations)
	{
		$ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
		$ParamAttrib.ParameterSetName = '__AllParameterSets'
		$AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$AttribColl.Add($ParamAttrib)
		$RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter(($config.FullName.Replace($configroot, "").Trim(".")), $config.Value.GetType(), $AttribColl)

		$RuntimeParamDic.Add(($config.FullName.Replace($configroot, "").Trim(".")), $RuntimeParam)
	}
	return $RuntimeParamDic
}

# Script that is executes when configuring the provider using Set-PSFLoggingProvider
$configurationScript = {
	$configroot = "PSServicePrincipal.Logging.PSServicePrincipal"

	$configurations = Get-PSFConfig -FullName "$configroot.*"

	foreach ($config in $configurations)
	{
		if ($PSBoundParameters.ContainsKey(($config.FullName.Replace($configroot, "").Trim("."))))
		{
			Set-PSFConfig -Module $config.Module -Name $config.Name -Value $PSBoundParameters[($config.FullName.Replace($configroot, "").Trim("."))]
		}
	}
}

# Script that returns a boolean value. "True" if all prerequisites are installed, "False" if installation is required
$isInstalledScript = {
	return $true
}

# Script that provides dynamic parameter for Install-PSFLoggingProvider
$installationParameters = {
	# None needed
}

# Script that performs the actual installation, based on the parameters (if any) specified in the $installationParameters script
$installationScript = {
	# Nothing to be done - if you need to install your filesystem, you probably have other issues you need to deal with first ;)
}
#endregion Function Extension / Integration

# Configuration settings to initialize
if($IsMacOS)
{
	$script:loggingFolder = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "/Documents/PowerShell Script Logging"
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.FilePath' -Value "$($script:loggingFolder)/%logname%-%date%.csv" -Initialize -Validation string -Handler { } -Description "The path to where the logfile is written. Supports some placeholders such as %Date% to allow for timestamp in the name. For full documentation on the supported wildcards, see the documentation on https://psframework.org"
}
else
{
	$script:loggingFolder = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "\PowerShell Script Logging"
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.FilePath' -Value "$($script:loggingFolder)\%logname%-%date%.csv" -Initialize -Validation string -Handler { } -Description "The path to where the logfile is written. Supports some placeholders such as %Date% to allow for timestamp in the name. For full documentation on the supported wildcards, see the documentation on https://psframework.org"
}
$configuration_Settings = {
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.FilePath' -Value "$($script:loggingFolder)\%logname%-%date%.csv" -Initialize -Validation string -Handler { } -Description "The path to where the logfile is written. Supports some placeholders such as %Date% to allow for timestamp in the name. For full documentation on the supported wildcards, see the documentation on https://psframework.org"
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.Logname' -Value "New-ServicePrincipalObject" -Initialize -Validation string -Handler { } -Description "A special string you can use as a placeholder in the logfile path (by using '%logname%' as placeholder)"
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.IncludeHeader' -Value $true -Initialize -Validation bool -Handler { } -Description "Whether a written csv file will include headers"
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.Headers' -Value @('Timestamp', 'Level', 'FunctionName', 'Message') -Initialize -Validation stringarray -Handler { } -Description "The properties to export, in the order to select them."
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.FileType' -Value "CSV" -Initialize -Validation psframework.logfilefiletype -Handler { } -Description "In what format to write the logfile. Supported styles: CSV, XML, Html or Json. Html, XML and Json will be written as fragments."
	Set-PSFConfig -Module PSServicePrincipal -Name 'Logging.PSServicePrincipal.CsvDelimiter' -Value "," -Initialize -Validation string -Handler { } -Description "The delimiter to use when writing to csv."

	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.Enabled' -Value $true -Initialize -Validation "bool" -Handler { if ([PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal']) { [PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal'].Enabled = $args[0] } } -Description "Whether the logging provider should be enabled on registration"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.AutoInstall' -Value $false -Initialize -Validation "bool" -Handler { } -Description "Whether the logging provider should be installed on registration"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.InstallOptional' -Value $true -Initialize -Validation "bool" -Handler { } -Description "Whether installing the logging provider is mandatory, in order for it to be enabled"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.IncludeModules' -Value @('PSServicePrincipal') -Initialize -Validation "stringarray" -Handler { if ([PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal']) { [PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal'].IncludeModules = ($args[0] | Write-Output) } } -Description "Module whitelist. Only messages from listed modules will be logged"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.ExcludeModules' -Value @() -Initialize -Validation "stringarray" -Handler { if ([PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal']) { [PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal'].ExcludeModules = ($args[0] | Write-Output) } } -Description "Module blacklist. Messages from listed modules will not be logged"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.IncludeTags' -Value @() -Initialize -Validation "stringarray" -Handler { if ([PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal']) { [PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal'].IncludeTags = ($args[0] | Write-Output) } } -Description "Tag whitelist. Only messages with these tags will be logged"
	Set-PSFConfig -Module LoggingProvider -Name 'PSServicePrincipal.ExcludeTags' -Value @() -Initialize -Validation "stringarray" -Handler { if ([PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal']) { [PSFramework.Logging.ProviderHost]::Providers['PSServicePrincipal'].ExcludeTags = ($args[0] | Write-Output) } } -Description "Tag blacklist. Messages with these tags will not be logged"
}

# This is needed to register the PSServicePrincipal logging provider
Register-PSFLoggingProvider -Name "PSServicePrincipal" -RegistrationEvent $registrationEvent -BeginEvent $begin_event -StartEvent $start_event -MessageEvent $message_Event -ErrorEvent $error_Event -EndEvent $end_event -FinalEvent $final_event -ConfigurationParameters $configurationParameters -ConfigurationScript $configurationScript -IsInstalledScript $isInstalledScript -InstallationScript $installationScript -InstallationParameters $installationParameters -ConfigurationSettings $configuration_Settings