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
	$PSScriptRoot |Split-Path |Push-Location
}
Process
{
	$ModuleName = Join-Path src *.psd1 |Get-Item |Split-Path -LeafBase
	& (Join-Path scripts Build-ThisModule.ps1)
	$psd1 = Join-Path .publish *.psd1 |Get-Item
	& (Join-Path scripts Import-ThisModule.ps1)
	$manifest = Test-ModuleManifest $psd1.FullName
	if($manifest.PSObject.Properties.Name -contains 'RequiredModules' -and $manifest.RequiredModules)
	{
		$manifest.RequiredModules.Name |ForEach-Object {
			Install-PSResource $_ -Scope CurrentUser -Repository PSGallery -TrustRepository -wa Ignore
			Import-Module $_
		}
	}
	New-MarkdownHelp -Module $ModuleName -OutputFolder (Join-Path .github wiki) -ErrorAction Ignore
}
Clean {Pop-Location}
