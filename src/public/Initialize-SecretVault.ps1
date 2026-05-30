<#
.SYNOPSIS
Sets up secret storage for the first time.

.FUNCTIONALITY
Credential

.LINK
https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/

.EXAMPLE
Initialize-SecretVault


#>

#Requires -Version 7
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')] Param(
# Disable password prompts
[Alias('Headless')][switch] $HandsFree
)
if(Test-SecretVault) {Write-Information 'Secret vault is already set up.'; return}
if(!$HandsFree) {Set-SecretStoreConfiguration -Default}
else
{
	if(!$PSCmdlet.ShouldProcess('secret vault','set up without a password')) {return}
	Set-SecretStoreConfiguration -Authentication None -Interaction None
}
Register-SecretVault -Name SecretVault -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
if(Test-SecretVault) {Write-Information 'Secret vault has been set up!'}
