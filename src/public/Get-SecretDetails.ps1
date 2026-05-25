<#
.SYNOPSIS
Returns secret info from the secret vaults, including metadata as properties.

.PARAMETER Name
This parameter takes a String argument, including wildcard characters.
It is used to filter the search results that match on secret names the provided name pattern.
If no Name parameter argument is provided, then all stored secret metadata is returned.

.PARAMETER Vault
Optional parameter which takes a String argument that specifies a single vault to search.

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

[CmdletBinding()] Param()
DynamicParam
{
    Get-SecretInfo |Select-Object -ExpandProperty Name |Add-DynamicParam Name string -Position 0
    Get-SecretVault |Select-Object -ExpandProperty Name |Add-DynamicParam Vault string -Position 1
    $DynamicParams
}
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
