<#
.SYNOPSIS
Assembles the module file.
#>

using namespace System.IO
[CmdletBinding()] Param()
Begin
{
    filter Format-Function
    {
        [CmdletBinding()] Param(
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string] $BaseName,
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)][string] $FullName
        )
        $Local:OFS = [Environment]::NewLine
        return @"

function $BaseName
{
$(Get-Content $FullName -Raw)
}
"@
    }

    function Out-Module
    {
        [CmdletBinding()] Param()
        $Local:OFS = [Environment]::NewLine
        $public = Join-Path src public *.ps1 |Get-Item
		$psm1 = [path]::ChangeExtension((Join-Path .publish *.psd1 |Resolve-Path),'psm1')
        return @"
$(Join-Path src private *.ps1 |Get-Item -ErrorAction Ignore |Format-Function)
$($public |Format-Function)
Export-ModuleMember -Function $($public.BaseName -join ',')
"@ |Out-File $psm1 utf8BOM
    }

	$PSScriptRoot |Split-Path |Push-Location
	New-Item .publish -Type Directory -ErrorAction Ignore |Out-Null
	Copy-Item (Join-Path src *.psd1) .publish
}
Process
{
	Out-Module
}
Clean
{
	Pop-Location
}
