<#
.SYNOPSIS
Determines whether the current Pester test script is in scope, when run via workflow.
#>

#Requires -Version 7
[CmdletBinding()] Param(
[Parameter(Position=0)][string] $Name =
	(Get-Variable MyInvocation -Scope 1 -ValueOnly).MyCommand.Name
)
Begin {$PSScriptRoot |Split-Path |Push-Location}
Process
{
	if(!$Name) {return}
	if(!(Test-Path .changes -Type Leaf)) {return $true}
	$target = ($Name -split '\.',2)[0]
	return [bool]@(Get-Content .changes |Get-Item |Select-Object -ExpandProperty Name |
			Where-Object {$_.StartsWith("$target.")}).Count
}
Clean {Pop-Location}
