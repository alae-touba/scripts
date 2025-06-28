<#
.SYNOPSIS
Automates PC setup by installing predefined applications using winget, including Node.js via NVM.

.DESCRIPTION
This script ensures administrator privileges, updates winget sources, and installs a list of predefined applications.
It also performs post-installation configuration for tools like Git and Node.js (via NVM).
Each major section is now in its own function for easy enabling/disabling.

Before running this script:
1. Open PowerShell as Administrator.
2. Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` to allow script execution.

#>

# Script initialization & privilege check
function Ensure-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "Admin privileges required. Relaunching..."
        # Relaunch the script with elevated privileges
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File `"$PSCommandPath`""
        exit
    }
    Write-Host "Running with Administrator privileges." -ForegroundColor Green
}

function Set-ExecutionPolicy-Configuration {
    Write-Host "`nChecking PowerShell execution policy..." -ForegroundColor Cyan
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Host "Current execution policy for CurrentUser: $currentPolicy" -ForegroundColor Yellow

    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        Write-Host "Setting execution policy to RemoteSigned for CurrentUser to allow profile loading..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "Execution policy updated successfully!" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to set execution policy: $($_.Exception.Message)"
            Write-Host "You may need to manually run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Execution policy is already set to allow script execution." -ForegroundColor Green
    }
}

function Install-Applications {
    # Application definitions
    $applications = @{
        # Browsers
        "Chrome"           = "Google.Chrome"
        "Firefox"          = "Mozilla.Firefox"

        # dev tools
        "VS Code"          = "Microsoft.VisualStudioCode"
        "Git"              = "Git.Git"
        "Golang"           = "GoLang.Go"
        "Python 3"         = "Python.Python.3.12"
        "NVM"              = "CoreyButler.NVMforWindows"
        "Postman"          = "Postman.Postman"
        "Bruno"            = "Bruno.Bruno"
        "OpenJDK 8 (Temurin)" = "EclipseAdoptium.Temurin.8.JDK"
        "OpenJDK 11"       = "Microsoft.OpenJDK.11"
        "OpenJDK 17"       = "Microsoft.OpenJDK.17"
        "OpenJDK 21"       = "Microsoft.OpenJDK.21"
        "DBeaver"          = "DBeaver.DBeaver.Community"
        "MySQL Workbench"  = "Oracle.MySQLWorkbench"
        "WinSCP"           = "WinSCP.WinSCP"
        "PuTTY"            = "PuTTY.PuTTY"
        "Notepad++"        = "Notepad++.Notepad++"

        # Utilities & Productivity
        "7-Zip"            = "7zip.7zip"
        "Bitwarden"        = "Bitwarden.Bitwarden"
        "Notion"           = "Notion.Notion"
        "OBS Studio"       = "OBSProject.OBSStudio"
        "VLC"              = "VideoLAN.VLC"

        # chat
        "Discord"          = "Discord.Discord"
        "Teams"            = "Microsoft.Teams"
        "Outlook"          = "Microsoft.Outlook"
        "Telegram"         = "Telegram.TelegramDesktop"
        "WhatsApp"         = "9NKSQGP7F2NH"
        "Instagram"        = "9NBLGGH5L9XT"
        "Netflix"          = "9WZDNCRFJ3TJ"
    }

    # Installation engine
    Write-Host "`nUpdating winget sources..." -ForegroundColor Cyan
    winget source update

    Write-Host "`nStarting application setup..." -ForegroundColor Cyan
    foreach ($name in $applications.Keys | Sort-Object) {
        $id = $applications[$name]
        Write-Host "--------------------------------------------------"
        Write-Host "Processing: $name"

        try {
            winget list --id $id --accept-source-agreements | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$name] is already installed. Skipping." -ForegroundColor Green
            } else {
                Write-Host "[$name] not found. Installing..." -ForegroundColor Yellow
                
                # Install the package silently, allowing winget to use any source (incl. msstore)
                winget install --id $id -e --accept-package-agreements --accept-source-agreements --silent
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[$name] installed successfully." -ForegroundColor Green
                } else {
                    Write-Host "[$name] installation finished with exit code: $LASTEXITCODE. Verify manually." -ForegroundColor Yellow
                }
            }
        }
        catch {
            Write-Error "An error occurred while checking or installing [$name]: $($_.Exception.Message)"
        }
        Write-Host ""
    }

    # Refresh environment variables for this session
    Write-Host "`nRefreshing environment variables for this session..." -ForegroundColor Cyan
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Create-WorkDirectories {
    Write-Host "`nEnsuring 'work' and 'github' directories exist..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------------"
    Write-Host "Ensuring 'work' and 'github' directories exist in user profile..."
    
    $workDirPath = Join-Path $env:USERPROFILE 'work'
    try {
        if (-not (Test-Path -Path $workDirPath -PathType Container)) {
            New-Item -ItemType Directory -Path $workDirPath -Force | Out-Null
            Write-Host "Created 'work' directory at: $workDirPath" -ForegroundColor Green
        } else {
            Write-Host "'work' directory already exists at: $workDirPath" -ForegroundColor DarkYellow
        }

        $githubDirPath = Join-Path $workDirPath 'github'
        if (-not (Test-Path -Path $githubDirPath -PathType Container)) {
            New-Item -ItemType Directory -Path $githubDirPath -Force | Out-Null
            Write-Host "Created 'github' directory at: $githubDirPath" -ForegroundColor Green
        } else {
            Write-Host "'github' directory already exists at: $githubDirPath" -ForegroundColor DarkYellow
        }
    }
    catch {
        Write-Error "Failed to ensure 'work' or 'github' directories exist: $($_.Exception.Message)"
    }
}

function Configure-Git {
    Write-Host "`nConfiguring Git..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------------"
    Write-Host "Configuring Git..."
    
    try {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git config --global user.name "alae-touba"
            git config --global user.email "alae2ba@gmail.com"
            git config --global core.editor "code --wait"

            $gitUser = $(git config --global user.name)
            if ($gitUser -eq "alae-touba") {
                Write-Host "Git configured successfully for user: $gitUser (alae2ba@gmail.com)" -ForegroundColor Green
            } else {
                Write-Host "Git configuration may have failed. Please verify manually using 'git config --global -l'." -ForegroundColor Red
            }
        } else {
            Write-Warning "Git command not found. Skipping Git configuration."
        }
    }
    catch {
        Write-Error "Failed to execute git config commands: $($_.Exception.Message)"
        Write-Error "Is Git installed and in your PATH?"
    }
}

function Configure-NVM-NodeJS {
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Configuring NVM and installing required Node.js versions..."
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    
    try {
        if (Get-Command nvm -ErrorAction SilentlyContinue) {
            Write-Host "NVM is available."

            $versionsToInstall = @("lts", "20", "18")
            
            Write-Host "Ensuring the following Node.js versions are installed: $($versionsToInstall -join ', ')"

            foreach ($version in $versionsToInstall) {
                Write-Host "-> Processing Node.js version '$version'..."
                
                nvm install $version
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   Node.js version '$version' is now available." -ForegroundColor Green
                } else {
                    Write-Host "   Failed to install or verify Node.js version '$version'. Exit code: $LASTEXITCODE." -ForegroundColor Red
                }
            }

            Write-Host "--------------------------------------------------"
            
            Write-Host "All currently installed Node.js versions:"
            nvm list
            
            Write-Host "Setting the LTS version as active for this session..."
            nvm use lts
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Node.js LTS version is now active." -ForegroundColor Green
                
                # Verify that Node.js and npm are working
                $nodeVersion = node --version 2>$null
                $npmVersion = npm --version 2>$null
                
                if ($nodeVersion) {
                    Write-Host "Verification successful:"
                    Write-Host "  Active Node version: $nodeVersion" -ForegroundColor Green
                    Write-Host "  Active NPM version:  $npmVersion" -ForegroundColor Green
                } else {
                    Write-Host "Verification failed. Could not retrieve Node.js version." -ForegroundColor Yellow
                }
            } else {
                Write-Host "Failed to use the Node.js LTS version. Exit code: $LASTEXITCODE." -ForegroundColor Yellow
                Write-Host "You may need to select a version manually with: nvm use <version>"
            }                
        } else {
            Write-Warning "NVM command not found. Skipping Node.js configuration. Please ensure NVM is correctly installed and in your PATH."
        }
    }
    catch {
        Write-Error "An unexpected error occurred while configuring NVM: $($_.Exception.Message)"
    }
}

function Configure-PowerShellProfile {
    Write-Host "`nConfiguring custom PowerShell aliases and functions..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------------"
    Write-Host "Configuring custom PowerShell aliases and functions..."

    try {
        # Get the path to the current user's PowerShell profile
        $profilePath = $PROFILE.CurrentUserAllHosts
        $profileDirectory = Split-Path $profilePath

        # Create the profile directory if it doesn't exist
        if (-not (Test-Path $profileDirectory)) {
            New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
            Write-Host "Created PowerShell profile directory: $profileDirectory" -ForegroundColor DarkCyan
        }

        # Create the profile file if it doesn't exist
        if (-not (Test-Path $profilePath)) {
            New-Item -ItemType File -Path $profilePath -Force | Out-Null
            Write-Host "Created PowerShell profile file: $profilePath" -ForegroundColor DarkCyan
        }

        # Define aliases and functions to add/ensure exist
        $profileItems = @(
            @{
                "Command" = "Set-Alias -Name '..' -Value 'Set-Location ..\..'";
                "DisplayName" = ".. (go up 2 directories)"
            },
            @{
                "Command" = "Set-Alias -Name '...' -Value 'Set-Location ..\..\..'";
                "DisplayName" = "... (go up 3 directories)"
            },
            @{
                "Command" = "function ll { Get-ChildItem -Force @args }";
                "DisplayName" = "ll (list all files including hidden)"
            },
            @{
                "Command" = "function work { Set-Location (Join-Path `$env:USERPROFILE 'work') }";
                "DisplayName" = "work (navigate to work directory)"
            }
        )

        # Get existing profile content (if any)
        $existingContent = if (Test-Path $profilePath) { Get-Content -Path $profilePath } else { @() }

        # Add items to the profile, ensuring idempotency (not adding duplicates)
        foreach ($item in $profileItems) {
            $command = $item.Command
            $displayName = $item.DisplayName
            
            # Check if this exact command already exists in the profile
            $commandExists = $existingContent | Where-Object { $_ -eq $command }
            
            if (-not $commandExists) {
                Add-Content -Path $profilePath -Value $command
                Write-Host "Added: $displayName" -ForegroundColor Green
            } else {
                Write-Host "Already exists: $displayName" -ForegroundColor DarkYellow
            }
        }

        # Load the profile in the current session
        Write-Host "Loading profile in current PowerShell session..." -ForegroundColor Cyan
        try {
            # Source the profile to load aliases and functions immediately
            . $profilePath
            Write-Host "Profile loaded successfully in current session!" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to load profile in current session: $($_.Exception.Message)"
            Write-Host "Functions will be available in new PowerShell sessions." -ForegroundColor Yellow
        }

        Write-Host "Custom PowerShell profile configured successfully: $profilePath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to configure custom PowerShell profile: $($_.Exception.Message)"
    }
}

function Show-CompletionSummary {
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host " PC Setup Script Finished" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "NOTE: For some applications (like Go, NVM, Python, Java), you may need to open a NEW terminal for all changes to fully apply." -ForegroundColor Yellow
    Write-Host "All requested applications have been processed." -ForegroundColor Green
}


Ensure-Administrator
Set-ExecutionPolicy-Configuration
Install-Applications               
Create-WorkDirectories             
Configure-Git                      
Configure-NVM-NodeJS              
Configure-PowerShellProfile       
Show-CompletionSummary