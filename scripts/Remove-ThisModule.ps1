<#
.SYNOPSIS
Unloads this repository's module.
#>

#Requires -Version 7
[CmdletBinding()] Param()
$PSScriptRoot |
	Split-Path |
	Join-Path -ChildPath .publish -AdditionalChildPath *.psd1 |
	Get-Item |
	Split-Path -LeafBase |
	Remove-Module -Force
