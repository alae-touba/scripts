<#
.SYNOPSIS
Automates PC setup by installing predefined applications using winget.

.DESCRIPTION
This script ensures administrator privileges, updates winget sources, and installs a list of predefined applications. It also performs post-installation configuration for tools like Git.

Before running this script:
1. Open PowerShell as Administrator.
2. Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` to allow script execution.

#>


#script initialization & privilege check
function Ensure-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "Admin privileges required. Relaunching..."
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File `"$PSCommandPath`""
        exit
    }
    Write-Host "Running with Administrator privileges." -ForegroundColor Green
}
Ensure-Administrator

# application definitions
$applications = @{
    #browsers & comms
    "Chrome"         = "Google.Chrome"
    "Firefox"        = "Mozilla.Firefox"
    "Discord"        = "Discord.Discord"
    "Teams"          = "Microsoft.Teams"
    "Outlook"        = "Microsoft.Outlook"
    "Telegram"       = "Telegram.TelegramDesktop"
    "WhatsApp"       = "WhatsApp.WhatsApp"

    #development & api
    "VS Code"        = "Microsoft.VisualStudioCode"
    "Git"            = "Git.Git"
    "Golang"         = "GoLang.Go"
    "Python 3"       = "Python.Python.3.12"
    "NVM"            = "CoreyButler.NVMforWindows"
    "Postman"        = "Postman.Postman"
    "Bruno"          = "Bruno.Bruno"
    
    #java jdks
    "OpenJDK 8 (Temurin)" = "EclipseAdoptium.Temurin.8.JDK"
    "OpenJDK 11"     = "Microsoft.OpenJDK.11"
    "OpenJDK 17"     = "Microsoft.OpenJDK.17"
    "OpenJDK 21"     = "Microsoft.OpenJDK.21"

    #database & ftp
    "DBeaver"        = "DBeaver.DBeaver.Community"
    "MySQL Workbench"= "Oracle.MySQLWorkbench"
    "FileZilla"      = "FileZilla.FileZilla_Client"
    "PuTTY"          = "PuTTY.PuTTY"

    #utilities & productivity
    "7-Zip"          = "7zip.7zip"
    "Notepad++"      = "Notepad++.Notepad++"
    "Bitwarden"      = "Bitwarden.Bitwarden"
    "Notion"         = "Notion.Notion"
    "OBS Studio"     = "OBSProject.OBSStudio"
    "VLC"            = "VideoLAN.VLC"

    #store apps
    "Instagram"      = "9NBLGGH5L9XT"
    "Netflix"        = "9WZDNCRFJ3TJ"
}

# installation engine
Write-Host "`nUpdating winget sources..." -ForegroundColor Cyan
winget source update

Write-Host "`nStarting application setup..." -ForegroundColor Cyan
foreach ($name in $applications.Keys | Sort-Object) {
    $id = $applications[$name]
    Write-Host "--------------------------------------------------"
    Write-Host "Processing: $name"

    $isInstalled = winget list --id $id --accept-source-agreements | Select-String -Pattern $id -Quiet -SimpleMatch

    if ($isInstalled) {
        Write-Host "[$name] is already installed. Skipping." -ForegroundColor Green
    } else {
        Write-Host "[$name] not found. Installing..." -ForegroundColor Yellow
        
        #install the package silently, allowing winget to use any source (incl. msstore)
        winget install --id $id -e --accept-package-agreements --accept-source-agreements --silent
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$name] installed successfully." -ForegroundColor Green
        } else {
            Write-Host "[$name] installation finished with exit code: $LASTEXITCODE. Verify manually." -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

# post-installation configuration
Write-Host "`nRefreshing environment variables for this session..." -ForegroundColor Cyan
#this allows the script to use newly installed command-line tools like Git immediately.
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "`nStarting post-installation configuration..." -ForegroundColor Cyan

# git configuration
if ($applications.ContainsKey("Git")) {
    Write-Host "--------------------------------------------------"
    Write-Host "Configuring Git..."
    
    try {
        git config --global user.name "alae-touba"
        git config --global user.email "alae2ba@gmail.com"
        git config --global core.editor "code --wait"

        #verify the configuration
        $gitUser = $(git config --global user.name)
        if ($gitUser -eq "alae-touba") {
            Write-Host "Git configured successfully for user: $gitUser (alae2ba@gmail.com)" -ForegroundColor Green
        } else {
            Write-Host "Git configuration may have failed. Please verify manually using 'git config --global -l'." -ForegroundColor Red
        }
    }
    catch {
        Write-Error "Failed to execute git config commands. Is Git installed and in your PATH?"
    }
}

# post-installation summary
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PC Setup Script Finished" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "NOTE: For some applications (like Go, NVM, Python, Java), you may need to open a NEW terminal for all changes to fully apply." -ForegroundColor Yellow
Write-Host "All requested applications have been processed." -ForegroundColor Green