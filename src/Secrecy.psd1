# see https://docs.microsoft.com/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest
# and https://docs.microsoft.com/powershell/module/microsoft.powershell.core/new-modulemanifest
@{
RootModule = 'Secrecy.psm1'
ModuleVersion = '0.0.0.0' # placeholder to be overridden
CompatiblePSEditions = @('Core')
GUID = 'a9e73a60-985d-4626-b83e-2f9c6ca56b28'
Author = 'Brian Lalonde'
CompanyName = 'Unknown'
Copyright = 'Copyright © 2026 Brian Lalonde'
Description = 'Secret storage manipulation utilities.'
PowerShellVersion = '7.0'
# RequiredModules = @()
FunctionsToExport = @('*') # '*'
CmdletsToExport = @() # '*'
VariablesToExport = @() # '*'
# AliasesToExport = @()
FileList = @('Secrecy.psd1','Secrecy.psm1')
PrivateData = @{
	PSData = @{
		Tags = @('SecretVault', 'Secrets', 'Passwords', 'DPAPI')
		LicenseUri = 'https://github.com/brianary/Secrecy/blob/master/LICENSE'
		ProjectUri = 'https://github.com/brianary/Secrecy/'
		IconUri = 'http://webcoder.info/images/Secrecy.svg'
		# ReleaseNotes = ''
		# PS7: A list of external modules that this module is dependent upon.
		# ExternalModuleDependencies = ,'Microsoft.PowerShell.Utility'
	}
}
}
