<#
.SYNOPSIS
Imports this repository's module, installing and importing required modules first.
#>

#Requires -Version 7
[CmdletBinding()] Param()
Write-Information "Importing..."
if(!($PSScriptRoot |Split-Path |Join-Path -ChildPath .publish |Test-Path -Type Container))
{
	$name = $PSScriptRoot |Split-Path |Join-Path -ChildPath src -AdditionalChildPath *.psd1 |Split-Path -LeafBase
	if(Get-Module $name) {Remove-Module $name -Force}
	& (Join-Path $PSScriptRoot Build-ThisModule.ps1)
}
$module = $PSScriptRoot |Split-Path |Join-Path -ChildPath .publish -AdditionalChildPath *.psd1 |Get-Item
$manifest = Import-PowerShellDataFile $module.FullName
Write-Information "Loading $module"
if($manifest.ContainsKey('RequiredModules') -and $manifest['RequiredModules'])
{
	Write-Output "::group::Found required modules: $($manifest.RequiredModules -join ', ')"
	try
	{
		$manifest.RequiredModules |ForEach-Object {
			Write-Output "::notice::Module '$_' is required"
			if(!(Get-Module $_ -ListAvailable -wa Ignore))
			{
				Write-Output "::notice::Installing '$_'"
				Install-PSResource $_ -Scope CurrentUser -Repository PSGallery -TrustRepository
			}
			Import-Module $_
		}
	}
	catch {Write-Output "::error::Trouble loading required modules: $_"}
	Write-Output "::endgroup::"
}
else
{
	Write-Output "::notice::No required modules"
}
Import-Module $module -Force
