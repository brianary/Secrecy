<#
.SYNOPSIS
Increments the module version in the module manifest.
#>

[CmdletBinding()] Param()
Begin
{
	function Get-NextModuleVersion
	{
		[CmdletBinding()] Param()
		$psd1 = Import-PowerShellDataFile *.psd1
		[version] $v = $psd1.ModuleVersion
		return [version]::new($v.Major,$v.Minor,$v.Build,$v.Revision+1)
	}

	function Step-ModuleVersion
	{
		[CmdletBinding()] Param()
		$psd1 = Get-Item *.psd1 |Select-Object -ExpandProperty Name -First 1
		$version = Get-NextModuleVersion
		@(Get-Content $psd1) |
			ForEach-Object {
				if($_ -notmatch '^(\s*ModuleVersion\s*=\s*'')(\d+(\.\d+){1,3})(''.*)$') {$_}
				else {"$($Matches[1])$version$($Matches[4])"}
			} |Out-File $psd1 utf8BOM
		Write-Information "Updated $psd1 to v$version"
	}

	Push-Location "$PSScriptRoot/../src"
}
Process
{
	Step-ModuleVersion
}
Clean
{
	Pop-Location
}
