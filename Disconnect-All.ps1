Disconnect-AzureAD -Confirm:$false 
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-SPOService
Disconnect-MicrosoftTeams
$TenantName = ""

Exit-PSHostProcess