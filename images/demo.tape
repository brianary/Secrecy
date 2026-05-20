# VHS https://github.com/charmbracelet/vhs
Output demo.gif
Hide
Set Shell pwsh
Type "Import-Module ../src/.publish/Secrecy.psd1"
Enter
Type "Clear-Host"
Enter
Show
Type "Save-Secret -Name ApiKey -Secret $apikey -Url https://example.net/apikey"
Enter
Sleep 9s
