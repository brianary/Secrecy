<#
.SYNOPSIS
Publishes the module if it has been updated.
#>

[CmdletBinding()] Param(
# The version to publish.
[version] $ModuleVersion = ($env:MODULEVERSION -replace '\A(?:\w+/)*v'),
# The PowerShell Gallery publish key.
[string] $GalleryKey = $env:GALLERYKEY
)
Process
{
	Push-Location "$PSScriptRoot/../src/.publish"
	$name = Get-Item *.psd1 |Test-ModuleManifest |Select-Object -ExpandProperty Name
	[version] $publishedVersion = (Find-PSResource -Name $name -Repository PSGallery -ErrorAction Ignore |
		Select-Object -ExpandProperty Version) ?? '0.0.0.0'
	if($ModuleVersion -le $publishedVersion)
	{
		Write-Output ("::warning file=$(Resolve-Path *.psd1 -Relative)," +
			"title=Not Published::Module was not published. " +
			"Manifest version must be greater than $publishedVersion to publish.")
	}
	else
	{
		Update-ModuleManifest -Path *.psd1 -ModuleVersion $ModuleVersion -FunctionsToExport (
			Get-Item ../public/*.ps1 |Split-Path -LeafBase)
		# see bug https://github.com/PowerShell/PSResourceGet/issues/1806#issuecomment-2992975199
		Get-PSResourceRepository -Name PSGallery
		Publish-PSResource -Path *.psd1 -Repository PSGallery -ApiKey $GalleryKey
		Write-Output ("::notice file=$(Resolve-Path *.psd1 -Relative)," +
			"title=Published::Module version $publishedVersion was published.")
	}
}
Clean
{
	Pop-Location
}
