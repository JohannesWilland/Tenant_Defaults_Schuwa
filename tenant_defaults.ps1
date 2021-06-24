<#
    .SYNOPSIS
        This script will set default Settings on the tenant
    .EXAMPLE
        .\tennant-defaults.ps1 -TennantName sw666
    .PARAMETER SharePointUrl
        Flag indicating whether or not the Azure AD application should be configured for preconsent.
#>

Param
(
    #[Parameter(Mandatory = $true)]
    #[switch]$ConfigurePreconsent,
    #[Parameter(Mandatory = $true)]
    #[string]$DisplayName,
    [Parameter(Mandatory = $false)]
    [string]$TenantName
)

# Needed modules will be loaded or installed

# Check if the Azure AD PowerShell module has already been loaded.
if ( ! ( Get-Module AzureAD ) ) {
    # Check if the Azure AD PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name AzureAD ) {
        # The Azure AD PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor Green "Loading the Azure AD PowerShell module..."
        Import-Module AzureAD
    } else {
        Install-Module AzureAD
    }
}
# Check if the Azure ExchangeOnlineManagement module has already been loaded.
if ( ! ( Get-Module ExchangeOnlineManagement ) ) {
    # Check if the Azure ExchangeOnlineManagement module is installed.
    if ( Get-Module -ListAvailable -Name ExchangeOnlineManagement ) {
        # The ExchangeOnlineManagement module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor Green "Loading the Azure ExchangeOnlineManagement module..."
        Import-Module ExchangeOnlineManagement
    } else {
        Install-Module ExchangeOnlineManagement
    }
}
# Check if the Azure Microsoft.Online.SharePoint.PowerShell module has already been loaded.
if ( ! ( Get-Module Microsoft.Online.SharePoint.PowerShell ) ) {
    # Check if the Azure Microsoft.Online.SharePoint.PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell ) {
        # The Microsoft.Online.SharePoint.PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor Green "Loading the Azure SharePoint module..."
        Import-Module Microsoft.Online.SharePoint.PowerShell
    } else {
        Install-Module Microsoft.Online.SharePoint.PowerShell
    }
}
# Check if the Azure MsOnline module has already been loaded.
if ( ! ( Get-Module MsOnline ) ) {
    # Check if the Azure MsOnline module is installed.
    if ( Get-Module -ListAvailable -Name MsOnline ) {
        # The MsOnline module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor Green "Loading the MsOnline module..."
        Import-Module MsOnline
    } else {
        Install-Module MsOnline
    }
}
# Check if the Azure MicrosoftTeams module has already been loaded.
if ( ! ( Get-Module MicrosoftTeams ) ) {
    # Check if the Azure MicrosoftTeams module is installed.
    if ( Get-Module -ListAvailable -Name MicrosoftTeams ) {
        # The MicrosoftTeams module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor Green "Loading the MsOnline module..."
        Import-Module MicrosoftTeams
    } else {
        Install-Module MicrosoftTeams
    }
}

# Ask for credentials and the Url for sharepoint if not given as a parameter save them for the later connections
if([string]::IsNullOrEmpty($TenantName)) {
    Write-Host -ForegroundColor Green 'Please enter the tenant-name (the part between the "@" and the ".onmicrosoft.com"):'
    $tenantName = Read-Host -Prompt "Tenant-Name"
}

Write-Host -ForegroundColor Green "Please enter the credentials for the global admin of the tenant..."
$cred = Get-Credential

Connect-MsolService -Credential $cred
Connect-SPOService -Url "https://$TenantName-admin.sharepoint.com" -Credential $cred
Connect-AzureAD -Credential $cred | Out-Null
Connect-ExchangeOnline -Credential $cred -ShowBanner:$false
Connect-MicrosoftTeams -Credential $cred
Connect-IPPSSession -Credential $cred



########### change timezone for sharepointonline ##############

# Disable RichTextFormat (RTF) for the Exchange-Tenant
function DisableRTF {
    Get-RemoteDomain | Set-RemoteDomain -TNEFEnabled $false
    Get-RemoteDomain -identity default | fl TNEFEnabled
}

# Set all Mailboxes to TimeZone W. Europe Standard
function Set-MailboxRegionalConfigurationDE {
    Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited | Set-MailboxRegionalConfiguration -Language de-DE -DateFormat "dd.MM.yyyy" -TimeFormat HH:mm -TimeZone "W. Europe Standard Time" -LocalizeDefaultFolderName:$true
    Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Set-MailboxRegionalConfiguration -Language de-DE -DateFormat "dd.MM.yyyy" -TimeFormat HH:mm -TimeZone "W. Europe Standard Time" -LocalizeDefaultFolderName:$true
    Get-Mailbox –RecipientTypeDetails UserMailbox | Get-MailboxRegionalConfiguration
    Get-Mailbox –RecipientTypeDetails SharedMailbox | Get-MailboxRegionalConfiguration
}

# Disable the FocusedInbox
function DisableRelevantFunction {
    Set-OrganizationConfig -FocusedInboxOn $false
    Get-OrganizationConfig | fl *foc*
}

# Disconnect and Exit
function Disconnect {
    Disconnect-AzureAD -Confirm:$false 
    Disconnect-ExchangeOnline -Confirm:$false
    Disconnect-SPOService
    Disconnect-MicrosoftTeams
    $TenantName = ""

    Exit
}

############ MENU ##############

while (1 -eq 1) {
    Write-Host -ForegroundColor Cyan "Please Choose what you whant to do:"
    Write-Host -ForegroundColor Magenta "1 = Set all Schuwa-Standarts     2 = Disable RichTextFormat`n3 = Set all Mailboxes to DE      0 = Disconnect and Exit"
    $choice = Read-Host -Prompt "Type a number and press enter"
    if ($choice -eq 1) {
        DisableRTF
        DisableRelevantFunction
    }
    elseif ($choice -eq 2) {
        DisableRTF
    }
    elseif ($choice -eq 3) {
        Set-MailboxRegionalConfigurationDE
    }
    elseif ($choice -eq 0) {
        Disconnect
    }
    else {
        Write-Host -ForegroundColor Red "Invalid entry, please only enter the number infront of the preferred outcome `n Try again."
    }
}