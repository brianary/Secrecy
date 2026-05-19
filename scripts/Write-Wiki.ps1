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
	Import-Module (Get-Item src/.publish/*.psd1)
	New-MarkdownHelp -Module $ModuleName -OutputFolder .github/wiki -ErrorAction Ignore
}
Clean {Pop-Location}
