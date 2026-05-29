<#
.SYNOPSIS
Updates the README.md file with the list of public cmdlets.
#>

#Requires -Version 7
[CmdletBinding()] Param()
Begin
{
	$PSScriptRoot |Split-Path |Push-Location
}
Process
{
	$ModuleName = Join-Path src *.psd1 |Get-Item |Split-Path -LeafBase
	$readme = Get-Content README.md -Raw
	$cmdlets = (Join-Path src public *.ps1 |
		Get-Item |
		Show-Progress 'Listing cmdlets' {$_.BaseName} |
		ForEach-Object {
			$cmdlet,$file = $_.BaseName,$_.FullName
			try
			{
				'- [{1}](https://github.com/brianary/{0}/wiki/{1}): {2}' -f $ModuleName,$cmdlet,
					(Get-Help $file -ErrorAction Stop).Synopsis
			}
			catch
			{
				'- [{0}]({1}): <!-- ERROR: {2} -->' -f $cmdlet,
					(Resolve-Path $file -RelativeBasePath "$PSScriptRoot/.." -Relative),$_
			}}) -join "`r`n"
	$readme -replace '(?m)(^- .+$\r?\n)+',$cmdlets |Out-File README.md utf8BOM
}
Clean
{
	Pop-Location
}
