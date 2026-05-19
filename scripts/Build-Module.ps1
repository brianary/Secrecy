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
        $public = Get-Item public/*.ps1
		$psm1 = [path]::ChangeExtension((Resolve-Path .publish/*.psd1),'psm1')
        return @"
$(Get-Item private/*.ps1 |Format-Function)
$($public |Format-Function)
Export-ModuleMember -Function $($public.BaseName -join ',')
"@ |Out-File $psm1 utf8BOM
    }

	Push-Location "$PSScriptRoot/../src"
	New-Item .publish -Type Directory -ErrorAction Ignore |Out-Null
	Copy-Item *.psd1 .publish
}
Process
{
	Out-Module
}
Clean
{
	Pop-Location
}
