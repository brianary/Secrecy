<#
.SYNOPSIS
Tests exporting secret vault content.
#>

if((Test-Path .changes -Type Leaf) -and
	!@(Get-Content .changes |Get-Item |Select-Object -ExpandProperty Name |
		Where-Object {$_.StartsWith("$(($MyInvocation.MyCommand.Name -split '\.',2)[0]).")})) {return}
BeforeAll {
	Set-StrictMode -Version Latest
	Get-Module -ListAvailable |% {Write-Information "::warning::$($_.ModuleBase)"}
	$module = Join-Path ($PSScriptRoot |Split-Path) src .publish *.psd1 |Get-Item
	Write-Information "::warning::___SETUP___"
	$manifest = Test-ModuleManifest $module.FullName
	if($manifest.RequiredModules)
	{
		$manifest.RequiredModules.Name |ForEach-Object {
			Install-PSResource $_ -Scope CurrentUser -Repository PSGallery -TrustRepository -wa Ignore
			Import-Module $_
		}
	}
	Get-Module -ListAvailable |% {Write-Information "::warning::$($_.ModuleBase)"}
	Import-Module $module -Force
}
Describe 'Export-SecretVault' -Tag Export-SecretVault {
	BeforeEach {
		# see https://pester.dev/docs/usage/modules#-modulename
		Mock Get-SecretInfo -ModuleName Secrecy {
			$values = New-Object 'Collections.Generic.Dictionary[string,object]'
			[pscustomobject]@{
				Name     = 'MockCredentials'
				Type     = 'PSCredential'
				Vault    = 'MockVault'
				Metadata = New-Object 'Collections.ObjectModel.ReadOnlyDictionary[string,object]' $values
			}
			$values.Add('Url','https://example.net/')
			$values.Add('Usage','Authorization: Bearer <token>')
			$values.Add('Description','API token A1')
			$values.Add('Expires','2024-08-16')
			[pscustomobject]@{
				Name     = 'MockToken'
				Type     = 'String'
				Vault    = 'MockVault'
				Metadata = New-Object 'Collections.ObjectModel.ReadOnlyDictionary[string,object]' $values
			}
		}
		Mock Get-Secret -ModuleName Secrecy {
			switch($Name)
			{
				MockCredentials {[pscustomobject]@{UserName='mockuser';Password='123456' |ConvertTo-SecureString -AsPlainText -Force}}
				MockToken {'token_1234'}
			}
		}
	}
	Context 'Exports secret vault content' -Tag Export-SecretVault,Export,SecretVault {
		It "Returns the contents of the default vault" {
			Export-SecretVault -Confirm:$false |ConvertTo-Json -Depth 100 -AsArray |Should -BeExactly (@"
[
  {
    "Name": "MockCredentials",
    "Type": "PSCredential",
    "Value": {
      "UserName": "mockuser",
      "Password": "123456"
    },
    "Vault": "",
    "Metadata": {
      "Url": "https://example.net/",
      "Usage": "Authorization: Bearer <token>",
      "Description": "API token A1",
      "Expires": "2024-08-16"
    }
  },
  {
    "Name": "MockToken",
    "Type": "String",
    "Value": "token_1234",
    "Vault": "",
    "Metadata": {
      "Url": "https://example.net/",
      "Usage": "Authorization: Bearer <token>",
      "Description": "API token A1",
      "Expires": "2024-08-16"
    }
  }
]
"@ -replace '\r\n',([Environment]::NewLine))
		}
	}

}
AfterAll {
	Remove-Module $module.BaseName -Force
}
