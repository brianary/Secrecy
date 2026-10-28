<#
.SYNOPSIS
Returns secret info from the secret vaults, including metadata as properties.

.FUNCTIONALITY
Credential

.EXAMPLE
Get-SecretDetails

Name        : test-creds
Type        : PSCredential
VaultName   : SecretStore
Title       : Test
Description : Example credentials.
Note        : Just for testing.
Uri         : https://example.org/
Created     : 2024-12-31 00:00:00
Expires     : 2036-01-01 00:00:00
#>

[CmdletBinding()] Param(
<#
This parameter takes a String argument, including wildcard characters.
It is used to filter the search results that match on secret names the provided name pattern.
If no Name parameter argument is provided, then all stored secret metadata is returned.
#>
[Parameter(Position=0)]
[ArgumentCompleter({
	Param($cmd,$param,$value)
	Get-SecretInfo |
		Select-Object -ExpandProperty Name |
		Where-Object {$_ -like "$value*"}
})]
[string] $Name,
# Optional parameter which takes a String argument that specifies a single vault to search.
[Parameter(Position=1)]
[ArgumentCompleter({
	Param($cmd,$param,$value)
	Get-SecretVault |
		Select-Object -ExpandProperty Name |
		Where-Object {$_ -like "$value*"}
})]
[string] $Vault
)
Process
{
    Get-SecretInfo @PSBoundParameters |
        ForEach-Object {[pscustomobject][ordered]@{
            Name        = $_.Name
            Type        = $_.Type
            VaultName   = $_.VaultName
            Title       = $_.Metadata['Title']
            Description = $_.Metadata['Description']
            Note        = $_.Metadata['Note']
            Uri         = $_.Metadata['Uri']
            Created     = $_.Metadata['Created']
            Expires     = $_.Metadata['Expires']
        }}
}
