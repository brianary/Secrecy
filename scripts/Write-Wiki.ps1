<#
.SYNOPSIS
Uses PlatyPS to create pages for the wiki.
#>

#Requires -Version 7.3
[CmdletBinding()] Param()
Begin
{
	if(!(Get-Module PlatyPS -ListAvailable))
	{
		Install-PSResource PlatyPS -Repository PSGallery -Scope CurrentUser -TrustRepository
	}
	Push-Location "$PSScriptRoot/.."
}
Process
{
	$ModuleName = Get-Item src/*.psd1 |Split-Path -LeafBase
	& './scripts/Build-Module.ps1'
	$psd1 = Get-Item src/.publish/*.psd1
	Import-Module $psd1
	$manifest = Test-ModuleManifest $psd1.FullName
	if($manifest.RequiredModules)
	{
		$manifest.RequiredModules.Name |ForEach-Object {
			Install-PSResource $_ -Scope CurrentUser -Repository PSGallery -TrustRepository -wa Ignore
			Import-Module $_
		}
	}
	New-MarkdownHelp -Module $ModuleName -OutputFolder .github/wiki -ErrorAction Ignore
}
Clean {Pop-Location}
