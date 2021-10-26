﻿@{
	# Script module or binary module file associated with this manifest
	RootModule = 'PSServicePrincipal.psm1'

	# Version number of this module.
	ModuleVersion = '1.0.49'

	# ID used to uniquely identify this module
	GUID = '2a29304f-a72b-47a5-b623-7cd998db75b3'

	# Author of this module
	Author = 'Dave Goldman'

	# Company or vendor of this module
	CompanyName = ' '

	# Copyright statement for this module
	Copyright = '(c) 2020 Dave Goldman. All rights reserved.'

	# Description of the functionality provided by this module
	Description = 'PowerShell module for creating, retrieving and deleting enterprise and registered applications and service principals'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.6.205' }
		@{ ModuleName='AzureAD'; ModuleVersion='2.0.2.140' }
		@{ ModuleName='Az.Accounts'; ModuleVersion='2.6.0' }
		@{ ModuleName='Az.Resources'; ModuleVersion='4.4.0' }
		)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\PSServicePrincipal.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\PSServicePrincipal.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\PSServicePrincipal.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-ToAzureInteractively'
		'Connect-ToCloudTenant'
		'Get-LogFolder'
		'Get-EnterpriseApplication'
		'Get-RegisteredApplication'
		'Get-ServicePrincipalObject'
		'New-SelfSignedCert'
		'New-ServicePrincipalObject'
		'Remove-ServicePrincipalObject'
		)

	# Cmdlets to export from this module
	CmdletsToExport = ''

	# Variables to export from this module
	VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport = ''

	# List of all modules packaged with this module
	ModuleList = @()

	# List of all files packaged with this module
	FileList = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# A mark of utter evil that should never be enabled
			# Prevents installation in default PowerShellGet
			# RequireLicenseAcceptance = $false

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @(
				'Application'
				'Automation'
				'Azure'
				'Configuration'
				'CertBasedAuth'
				'Exchange'
				'ExchangeOnline'
				'EXO'
				'ServicePrincipal'
				'Windows'
				)

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/dgoldman-msft/PSServicePrincipal/blob/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/dgoldman-msft/PSServicePrincipal'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/dgoldman-msft/PSServicePrincipal/blob/master/PSServicePrincipal/changelog.md'

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}