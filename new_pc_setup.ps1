<#
.SYNOPSIS
Automates PC setup by installing predefined applications using winget, based on a config file.

.DESCRIPTION
This script ensures administrator privileges, updates winget sources, and installs a list of 
applications defined within the script. It also performs post-installation configuration 
for tools like Git and Node.js (via NVM).

Before running this script:
1. Open PowerShell as Administrator.
3. Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` to allow script execution.

.LINK
https://github.com/your-repo/link-to-this-script

.NOTES
Author: Alae Touba
#>

function Ensure-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "Admin privileges are required. Relaunching..."
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File `"$PSCommandPath`""
        exit
    }
    Write-Host "Running with Administrator privileges." -ForegroundColor Green
}


$ScriptConfig = @{
    Git = @{
        Name  = "alae-touba"
        Email = "alae2ba@gmail.com"
    }
    NodeVersions = @(
        "lts",
        "20",
        "18"
    )
    Applications = @{
        "Chrome"              = "Google.Chrome"
        "Firefox"             = "Mozilla.Firefox"
        "VS Code"             = "Microsoft.VisualStudioCode"
        "Git"                 = "Git.Git"
        "Golang"              = "GoLang.Go"
        "Python 3"            = "Python.Python.3.12"
        "NVM"                 = "CoreyButler.NVMforWindows"
        "Postman"             = "Postman.Postman"
        "Bruno"               = "Bruno.Bruno"
        "OpenJDK 8 (Temurin)" = "EclipseAdoptium.Temurin.8.JDK"
        "OpenJDK 11"          = "Microsoft.OpenJDK.11"
        "OpenJDK 17"          = "Microsoft.OpenJDK.17"
        "OpenJDK 21"          = "Microsoft.OpenJDK.21"
        "DBeaver"             = "DBeaver.DBeaver.Community"
        "MySQL Workbench"     = "Oracle.MySQLWorkbench"
        "WinSCP"              = "WinSCP.WinSCP"
        "PuTTY"               = "PuTTY.PuTTY"
        "Notepad++"           = "Notepad++.Notepad++"
        "7-Zip"               = "7zip.7zip"
        "Bitwarden"           = "Bitwarden.Bitwarden"
        "Notion"              = "Notion.Notion"
        "OBS Studio"          = "OBSProject.OBSStudio"
        "VLC"                 = "VideoLAN.VLC"
        "Discord"             = "Discord.Discord"
        "Teams"               = "Microsoft.Teams"
        "Outlook"             = "Microsoft.Outlook"
        "Telegram"            = "Telegram.TelegramDesktop"
        "WhatsApp"            = "9NKSQGP7F2NH"
        "Instagram"           = "9NBLGGH5L9XT"
        "Netflix"             = "9WZDNCRFJ3TJ"
    }
}

function Set-ExecutionPolicy-Configuration {
    [CmdletBinding()]
    param()

    Write-Host "`nChecking PowerShell execution policy..." -ForegroundColor Cyan
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Host "Current execution policy for CurrentUser: $currentPolicy" -ForegroundColor Yellow

    if ($currentPolicy -in @("Restricted", "Undefined")) {
        Write-Host "Setting execution policy to RemoteSigned for CurrentUser..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "Execution policy updated successfully!" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to set execution policy: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Execution policy is already configured." -ForegroundColor Green
    }
}

function Install-Applications {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Applications
    )

    Write-Host "`nUpdating winget sources..." -ForegroundColor Cyan
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget command not found. Please install the App Installer from the Microsoft Store."
        return
    }
    winget source update

    Write-Host "`nStarting application setup..." -ForegroundColor Cyan
    foreach ($name in $Applications.Keys | Sort-Object) {
        $id = $Applications[$name]
        Write-Host "--------------------------------------------------"
        Write-Host "Processing: $name ($id)"

        try {
            winget list --id $id --accept-source-agreements | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$name] is already installed. Skipping." -ForegroundColor Green
            } else {
                Write-Host "[$name] not found. Installing..." -ForegroundColor Yellow
                winget install --id $id -e --accept-package-agreements --accept-source-agreements --silent
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[$name] installed successfully." -ForegroundColor Green
                } else {
                    Write-Host "[$name] installation finished with exit code: $LASTEXITCODE. Verify manually." -ForegroundColor Yellow
                }
            }
        }
        catch {
            Write-Error "An error occurred while processing [$name]: $($_.Exception.Message)"
        }
    }
}

function Create-WorkDirectories {
    [CmdletBinding()]
    param()

    Write-Host "`nEnsuring 'work' and 'github' directories exist..." -ForegroundColor Cyan
    $workDirPath = Join-Path $env:USERPROFILE 'work'
    $githubDirPath = Join-Path $workDirPath 'github'

    foreach ($dir in @($workDirPath, $githubDirPath)) {
        if (-not (Test-Path -Path $dir -PathType Container)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "Created directory: $dir" -ForegroundColor Green
        } else {
            Write-Host "Directory already exists: $dir" -ForegroundColor DarkYellow
        }
    }
}

function Configure-Git {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [psobject]$GitConfig
    )

    Write-Host "`nConfiguring Git..." -ForegroundColor Cyan
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "Git command not found. Skipping Git configuration."
        return
    }

    $userName = $GitConfig.name
    $userEmail = $GitConfig.email

    if ([string]::IsNullOrWhiteSpace($userName)) {
        $userName = Read-Host "Enter your Git user name"
    }
    if ([string]::IsNullOrWhiteSpace($userEmail)) {
        $userEmail = Read-Host "Enter your Git user email"
    }

    try {
        git config --global user.name $userName
        git config --global user.email $userEmail
        git config --global core.editor "code --wait"

        $configuredName = $(git config --global user.name)
        if ($configuredName -eq $userName) {
            Write-Host "Git configured successfully for user: $configuredName ($userEmail)" -ForegroundColor Green
        } else {
            Write-Error "Git configuration failed. Please verify manually."
        }
    }
    catch {
        Write-Error "Failed to execute git config commands: $($_.Exception.Message)"
    }
}

function Configure-NVM-NodeJS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$NodeVersions
    )

    Write-Host "`nConfiguring NVM and Node.js..." -ForegroundColor Cyan
    if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
        Write-Warning "NVM command not found. Skipping Node.js configuration."
        return
    }

    Write-Host "Ensuring the following Node.js versions are installed: $($NodeVersions -join ', ')"
    foreach ($version in $NodeVersions) {
        Write-Host "-> Processing Node.js version '$version'..."
        nvm install $version
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install Node.js version '$version'."
        }
    }

    Write-Host "`nSetting LTS version as active..."
    nvm use lts
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Node.js LTS version is now active." -ForegroundColor Green
        Write-Host "Active Node version: $(node --version)" -ForegroundColor Green
        Write-Host "Active NPM version:  $(npm --version)" -ForegroundColor Green
    } else {
        Write-Warning "Failed to set LTS version. Please select one manually using 'nvm use <version>'."
    }
}

function Configure-PowerShellProfile {
    [CmdletBinding()]
    param()

    Write-Host "`nConfiguring custom PowerShell profile..." -ForegroundColor Cyan
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDirectory = Split-Path $profilePath

    if (-not (Test-Path $profileDirectory)) {
        New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    }
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $profileItems = @{
        ".."     = "Set-Alias -Name '..' -Value 'Set-Location ..\..'"
        "..."    = "Set-Alias -Name '...' -Value 'Set-Location ..\..\..'"
        "ll"     = "function ll { Get-ChildItem -Force @args }"
        "work"   = "function work { Set-Location (Join-Path `$env:USERPROFILE 'work') }"
        "github" = "function github { Set-Location (Join-Path `$env:USERPROFILE 'work\github') }"
    }

    $existingContent = Get-Content -Path $profilePath
    foreach ($name in $profileItems.Keys) {
        $command = $profileItems[$name]
        if ($existingContent -notcontains $command) {
            Add-Content -Path $profilePath -Value $command
            Write-Host "Added alias/function: $name" -ForegroundColor Green
        } else {
            Write-Host "Alias/function already exists: $name" -ForegroundColor DarkYellow
        }
    }

    Write-Host "Sourcing profile for current session..."
    . $profilePath
    Write-Host "PowerShell profile configured: $profilePath" -ForegroundColor Green
}

function Show-CompletionSummary {
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host " PC Setup Script Finished" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "NOTE: A new terminal may be required for all changes to take effect (e.g., NVM, Go, Python)." -ForegroundColor Yellow
}

Ensure-Administrator
Set-ExecutionPolicy-Configuration

Install-Applications -Applications $ScriptConfig.Applications
Create-WorkDirectories
Configure-Git -GitConfig $ScriptConfig.Git
Configure-NVM-NodeJS -NodeVersions $ScriptConfig.NodeVersions
Configure-PowerShellProfile

Show-CompletionSummary