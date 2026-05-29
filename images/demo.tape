# VHS https://github.com/charmbracelet/vhs
Output demo.gif
Hide
Set Shell pwsh
Type "../scripts/Import-ThisModule.ps1"
Enter
Type "; $apikey = '████████████████' |ConvertTo-SecureString -AsPlainText"
Enter
Type "Clear-Host"
Enter
Show
Type "Set-SecretDetails -Name ApiKey -Secret $apikey -Title 'Example API key' -Uri https://example.net/apikey -Expires 2038-03-15"
Enter
Sleep 1s
Type "Get-SecretDetails ApiKey"
Enter
Sleep 3s
Type "Export-SecretVault |ConvertTo-Json"
Enter
Type "y"
Sleep 2s
Enter
Sleep 5s
