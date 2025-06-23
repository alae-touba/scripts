# PowerShell script to automate PC setup using winget.
# Ensures admin rights, then checks for and installs a predefined list of apps.

#--------------------------------------------------------------------------
# 1. SCRIPT INITIALIZATION & PRIVILEGE CHECK
#--------------------------------------------------------------------------
function Ensure-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "Admin privileges required. Relaunching..."
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File `"$PSCommandPath`""
        exit
    }
    Write-Host "Running with Administrator privileges." -ForegroundColor Green
}
Ensure-Administrator

#--------------------------------------------------------------------------
# 2. APPLICATION DEFINITIONS
#--------------------------------------------------------------------------
$applications = @{
    # --- Browsers & Comms ---
    "Chrome"         = "Google.Chrome"
    "Firefox"        = "Mozilla.Firefox"
    "Discord"        = "Discord.Discord"
    "Teams"          = "Microsoft.Teams"
    "Outlook"        = "Microsoft.Outlook"
    "Telegram"       = "Telegram.Desktop"
    "WhatsApp"       = "WhatsApp.WhatsApp"

    # --- Development & API ---
    "VS Code"        = "Microsoft.VisualStudioCode"
    "Git"            = "Git.Git"
    "Golang"         = "Go.Go"
    "Python 3"       = "Python.Python.3"
    "NVM"            = "CoreyButler.NVMforWindows"
    "Postman"        = "Postman.Postman"
    "Bruno"          = "usebruno.bruno"
    
    # --- Java JDKs ---
    "OpenJDK 8"      = "Microsoft.OpenJDK.8"
    "OpenJDK 11"     = "Microsoft.OpenJDK.11"
    "OpenJDK 17"     = "Microsoft.OpenJDK.17"
    "OpenJDK 22"     = "Microsoft.OpenJDK.22"

    # --- Database & FTP ---
    "DBeaver"        = "dbeaver.dbeaver"
    "MySQL Workbench"= "Oracle.MySQL.Workbench"
    "FileZilla"      = "FileZilla.FileZilla.Client"
    "PuTTY"          = "PuTTY.PuTTY"

    # --- Utilities & Productivity ---
    "7-Zip"          = "7zip.7zip"
    "Google Drive"   = "Google.Drive"
    "Notepad++"      = "Notepad++.Notepad++"
    "Bitwarden"      = "Bitwarden.Bitwarden"
    "Notion"         = "Notion.Notion"
    "OBS Studio"     = "OBSProject.OBSStudio"
    "VLC"            = "VideoLAN.VLC"

    # --- Store Apps ---
    "Instagram"      = "9NBLGGH5L9XT"
    "Netflix"        = "9NCBC7F2N2WJ"
}

#--------------------------------------------------------------------------
# 3. INSTALLATION ENGINE
#--------------------------------------------------------------------------
Write-Host "`nUpdating winget sources..." -ForegroundColor Cyan
winget source update

Write-Host "`nStarting application setup..." -ForegroundColor Cyan

foreach ($name in $applications.Keys | Sort-Object) {
    $id = $applications[$name]
    Write-Host "--------------------------------------------------"
    Write-Host "Processing: $name"

    # Check if package is already installed
    $isInstalled = winget list --id $id --accept-source-agreements | Select-String -Pattern $id -Quiet

    if ($isInstalled) {
        Write-Host "[$name] is already installed. Skipping." -ForegroundColor Green
    } else {
        Write-Host "[$name] not found. Installing..." -ForegroundColor Yellow
        
        # Install the package silently
        winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements --silent
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$name] installed successfully." -ForegroundColor Green
        } else {
            Write-Host "[$name] installation finished with exit code: $LASTEXITCODE. Verify manually." -ForegroundColor Yellow
        }
    }
    Write-Host ""
}


#--------------------------------------------------------------------------
# 4. POST-INSTALLATION CONFIGURATION
#--------------------------------------------------------------------------
Write-Host "`nStarting post-installation configuration..." -ForegroundColor Cyan

# --- Git Configuration ---
# Check if Git was requested for installation before trying to configure it.
if ($applications.ContainsKey("Git")) {
    Write-Host "--------------------------------------------------"
    Write-Host "Configuring Git..."
    
    # We assume git.exe is now in the PATH. If Git installation failed, these commands will also fail.
    try {
        git config --global user.name "alae-touba"
        git config --global user.email "alae2ba@gmail.com"
        git config --global core.editor "code --wait" # --wait is crucial for git to work correctly with VS Code

        # Verify the configuration
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


#--------------------------------------------------------------------------
# 5. POST-INSTALLATION SUMMARY
#--------------------------------------------------------------------------
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PC Setup Script Finished" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "NOTE: For 'Go', 'NVM', 'Python', and 'Java', open a NEW terminal for changes to apply." -ForegroundColor Yellow
Write-Host "All requested applications have been processed." -ForegroundColor Green