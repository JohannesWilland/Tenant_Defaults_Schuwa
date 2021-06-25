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
    $tenantName = Read-Host
}

Write-Host -ForegroundColor Green "Please enter the credentials for the global admin of the tenant..."
$cred = Get-Credential

Connect-MsolService -Credential $cred
Connect-SPOService -Url "https://$TenantName-admin.sharepoint.com" -Credential $cred
Connect-AzureAD -Credential $cred | Out-Null
Connect-ExchangeOnline -Credential $cred -ShowBanner:$false
Connect-MicrosoftTeams -Credential $cred
Connect-IPPSSession -Credential $cred


function Disconnect-All {
    Disconnect-AzureAD -Confirm:$false 
    Disconnect-ExchangeOnline -Confirm:$false
    Disconnect-SPOService
    Disconnect-MicrosoftTeams
    $TenantName = ""

    Exit
}

Write-Host -ForegroundColor Green "If there is more to do, do it now. `r`nIf you are done type: .\Disconnect-All.ps1"