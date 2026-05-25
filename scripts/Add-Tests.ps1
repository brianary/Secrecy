<#
.SYNOPSIS
Creates a new Pester testing script from a script's examples and parameter sets.
#>

#Requires -Version 3
[CmdletBinding()] Param(
# The directory to generate tests in.
[ValidateScript({Test-Path $_ -Type Container})][string] $Directory =
	(Join-Path ($PSScriptRoot |Split-Path) test)
)
Begin
{
	function Initialize-Process
	{
		[CmdletBinding()] Param()
		$Script:NL = [Environment]::NewLine
		$src = Join-Path ($PSScriptRoot |Split-Path) src
		$Script:ModuleName = Join-Path $src *.psd1 |Resolve-Path |Split-Path -LeafBase
		if(Get-Module $Script:ModuleName) {Remove-Module $Script:ModuleName}
		& (Join-Path $PSScriptRoot Build-Module.ps1)
		Join-Path $src .publish *.psd1 |Resolve-Path |Import-Module
		Write-Debug "Imported commands: $(Get-Command -Module $Script:ModuleName)"
	}

	filter Format-ExampleTest
	{
		[CmdletBinding()] Param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string] $Title,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][psobject[]] $Introduction,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string] $Code,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][psobject[]] $Remarks
		)
		$cmdtext = (($Introduction |Where-Object Text -notin 'PS > ',' ','',$null |Select-Object -ExpandProperty Text) -join $NL) + $Code
		$output = ($Remarks |Where-Object {$_.Text} |Select-Object -ExpandProperty Text) -join $NL
		return @"
		It "$($Title.Trim(' -'))" -Skip {
			$cmdtext |Should -BeExactly @"
$output
$('"@')
		}
"@
	}

	filter Format-ParameterSetContext
	{
		[CmdletBinding()] Param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][ValidateNotNullOrEmpty()][string] $Name
		)
		if([string]::IsNullOrWhiteSpace($Name)) {return}
		return @"
	Context '$Name' -Tag $Name {
		It "test" -Skip {
			1 |Should -Be 1
		}
	}
"@
	}

	filter Format-ScriptPesterTest
	{
		[CmdletBinding()] Param(
		[Parameter(Position=0,Mandatory=$true)][string] $Name,
		[Parameter(Position=1,Mandatory=$true)][Management.Automation.CommandInfo] $CmdInfo,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string] $Synopsis,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][psobject[]] $Examples
		)
		$Local:OFS = $NL
		if($null -eq $CmdInfo) {Write-CallInfo}
		return @"
<#
.SYNOPSIS
Tests $Synopsis
#>

if((Test-Path .changes -Type Leaf) -and
	!@(Get-Content .changes |Get-Item |Select-Object -ExpandProperty Name |
		Where-Object {`$_.StartsWith("`$((`$MyInvocation.MyCommand.Name -split '\.',2)[0]).")})) {return}
BeforeAll {
	Set-StrictMode -Version Latest
	`$module = Join-Path (`$PSScriptRoot |Split-Path) src .publish *.psd1 |Get-Item
	Import-Module `$module -Force
}
Describe '$Name' -Tag $Name,$($Name -replace '-',',') {
	Context '$($Synopsis -replace "'","''")' -Tag Example {
$($Examples.example |Format-ExampleTest)
	}
$($CmdInfo.ParameterSets |Where-Object Name -ne __AllParameterSets |Format-ParameterSetContext)
}
AfterAll {
	Remove-Module `$module.BaseName -Force
}
"@
	}

	filter Out-Test
	{
		[CmdletBinding()] Param(
		[Parameter(ValueFromPipelineByPropertyName=$true)][string] $Name,
		[Parameter(ValueFromPipeline=$true)][Management.Automation.CommandInfo] $InputObject
		)
		$testfile = Join-Path $Directory "$Name.Tests.ps1"
		if(Test-Path $testfile -Type Leaf)
		{
			Write-Information "$Script:ModuleName\$Name already has tests."
			return
		}
		$InputObject |Get-Help |Format-ScriptPesterTest -Name $Name -CmdInfo $InputObject |Out-File $testfile -Encoding utf8BOM
		Write-Information "$Script:ModuleName\$Name tests started in $(Resolve-Path $testfile -Relative) , be sure to edit that."
	}
}
Process
{
	Initialize-Process
	Get-Command -Module $Script:ModuleName |Out-Test
	Join-Path $Directory Placeholder.Tests.ps1 |Where-Object {Test-Path $_ -Type Leaf} |Remove-Item
}
