<#
.SYNOPSIS
Imports this repository's module, installing and importing required modules first.
#>

#Requires -Version 7
[CmdletBinding()] Param()
if(!($PSScriptRoot |Split-Path |Join-Path -ChildPath .publish |Test-Path -Type Container))
{
	$name = $PSScriptRoot |Split-Path |Join-Path -ChildPath src -AdditionalChildPath *.psd1 |Split-Path -LeafBase
	if(Get-Module $name) {Remove-Module $name -Force}
	& (Join-Path $PSScriptRoot Build-ThisModule.ps1)
}
$module = $PSScriptRoot |Split-Path |Join-Path -ChildPath .publish -AdditionalChildPath *.psd1 |Get-Item
$manifest = Import-PowerShellDataFile $module.FullName
if($manifest.PSObject.Properties.Name -contains 'RequiredModules' -and $manifest.RequiredModules)
{
	$manifest.RequiredModules |ForEach-Object {
		if(!(Get-Module $_ -ListAvailable -wa Ignore))
		{
			Install-PSResource $_ -Scope CurrentUser -Repository PSGallery -TrustRepository -wa Ignore
		}
		Import-Module $_
	}
}
Import-Module $module -Force
