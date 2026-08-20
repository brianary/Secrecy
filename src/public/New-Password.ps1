<#
.SYNOPSIS
Generates a new random password.

.OUTPUTS
System.String containing the new password.

.LINK
Get-Random

.EXAMPLE
New-Password

6x~?sPDKT("hyV5k
#>

[CmdletBinding()][OutputType([string])] Param(
# The number of characters in the password.
[Parameter(Position=0)][int] $Length = 16,
<#
The required elements to include in the password:
* Anything: No complexity requirements, use any valid password character.
* Everything: An uppercase character, a lowercase character, a digit, and a symbol will all be included.
* Alphanumeric: An uppercase character, a lowercase character, and a digit will all be included, but no symbols.
#>
[Parameter(Position=1)][ValidateSet('Anything','Everything','Alphanumeric')][string] $Include = 'Everything',
# Which characters are allowed and considered symbols. Space is included by default.
[string] $AllowedSymbols = ' !"#$%&''()*+,-./:;<=>?@[\\]^_`{|}~'
)
Begin
{
	function Initialize-Charsets
	{
		Set-Variable -Name upper -Value ('A'..'Z' |Out-String -NoNewline) -Scope Script -Option Constant
		Set-Variable -Name lower -Value ('a'..'z' |Out-String -NoNewline) -Scope Script -Option Constant
		Set-Variable -Name digit -Value ('0'..'9' |Out-String -NoNewline) -Scope Script -Option Constant
		Set-Variable -Name alphanum -Value "$upper$digit$lower" -Scope Script -Option Constant
		Set-Variable -Name any -Value "$AllowedSymbols$upper$digit$lower" -Scope Script -Option Constant
	}
	function Select-Character
	{
		[CmdletBinding()] Param(
		[Parameter(Position=0,Mandatory=$true)][string] $CharacterSet
		)
		return $CharacterSet[(Get-Random -Maximum $CharacterSet.Length)]
	}
	function Select-CharacterString
	{
		[CmdletBinding()] Param(
		[Parameter(Position=0,Mandatory=$true)][string] $CharacterSet,
		[Parameter(Position=1,Mandatory=$true)][int] $Length
		)
		return 1..$Length |ForEach-Object {Select-Character $CharacterSet} |Out-String -NoNewline
	}
	filter Get-ShuffledString
	{
		[CmdletBinding()] Param(
		[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][string] $Value
		)
		if($Value.Length -le 1) {return $Value}
		$shuffled = ''
		do
		{
			$take = Get-Random -Maximum $Value.Length
			$shuffled += $Value[$take]
			$Value = $Value.Remove($take,1)
		}
		while($Value.Length -ge 1)
		return $shuffled + $Value
	}

	Initialize-Charsets
}
Process
{
	switch($Include)
	{
		Anything {return 1..$Length |ForEach-Object {Select-Character $any} |Out-String -NoNewline}
		Alphanumeric
		{
			return (Select-Character $upper) + (Select-Character $lower) + (Select-Character $digit) +
				(Select-CharacterString $alphanum ($Length-3)) |Get-ShuffledString
		}
		Everything
		{
			return (Select-Character $upper) + (Select-Character $lower) + (Select-Character $digit) +
				(Select-CharacterString $any ($Length-3)) |Get-ShuffledString
		}
	}
}
