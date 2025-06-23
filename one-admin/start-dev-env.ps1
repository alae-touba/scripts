#link to gemini 2.5 pro chat https://aistudio.google.com/prompts/1M6g8g9ZzFZqgGsCEhb2zlLad0gkE8MgE


Corrected $tabConfigs (specifically the "ory tunnel" entry):

# Define your tab configurations
$tabConfigs = @(
    @{
        Title = "iam-core"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\iam-core"
        Command = "make run"
    },
    @{
        Title = "iam-core hurl"
        Profile = "Git bash"
        Path = "C:\Users\NCDD0815\work\one-admin\iam-core\hurl"
        Command = "" # No command for this tab
    },
    @{
        Title = "iam-authnadmin"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\iam-authnadmin"
        Command = "go run main.go serve --config config.yaml"
    },
    @{
        Title = "iam-authorization"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\iam-authorization"
        Command = "make run"
    },
    @{
        Title = "ory tunnel"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\obs-iam-ui"
        # --- Use a Script Block for complex commands ---
        Command = {
            # Set environment variable ONLY for this process
            $env:ORY_SDK_URL = 'https://auth.ui.1xm-obs-iam-dev.caas-cnp-apps-v2-np.com.intraorange/'
            # Pipe 'n' (as a string) to the npx command
            Write-Output 'n' | npx @ory/cli@0.3.2 tunnel https://auth.ui.1xm-obs-iam-dev.caas-cnp-apps-v2-np.com.intraorange/
        }
        # --- End Script Block ---
    },
    @{
        Title = "obs-iam-ui"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\obs-iam-ui"
        Command = "pnpm start"
    },
    @{
        Title = "obs-iam-ui tests"
        Profile = "Windows PowerShell"
        Path = "C:\Users\NCDD0815\work\one-admin\obs-iam-ui"
        Command = "pnpm test"
    }
    # Add more tabs here if needed
)

# --- Build the argument list for wt.exe ---
$wtArgs = @()
$isFirstTab = $true # Flag to treat the first tab specially

# Determine the appropriate PowerShell executable based on the version
$psExecutable = if ($PSVersionTable.PSVersion.Major -ge 7) { "pwsh.exe" } else { "powershell.exe" }


foreach ($tab in $tabConfigs) {
    # --- Determine Command Value (Handle String or ScriptBlock) ---
    $commandValue = $null
    if ($tab.Command) { # Check if Command property exists and is not null/empty
        if ($tab.Command -is [ScriptBlock]) {
            # Convert script block to its string representation "{ ... }"
            $commandValue = $tab.Command.ToString()
        } elseif ($tab.Command -is [string] -and -not [string]::IsNullOrWhiteSpace($tab.Command)) {
            # Use the command string directly
            $commandValue = $tab.Command
        }
    }

    # --- Build Arguments for wt.exe ---
    if ($isFirstTab) {
        # --- First Tab Configuration ---
        $wtArgs += "-p", $tab.Profile, "--title", $tab.Title, "--startingDirectory", $tab.Path
        if ($commandValue) {
            # Separator + command execution for PowerShell profiles
            # NOTE: This assumes PowerShell profiles. For others like Git Bash,
            # you might want different logic if they need commands executed.
            $wtArgs += "--", $psExecutable, "-NoExit", "-Command", $commandValue
        }
        $isFirstTab = $false
    } else {
        # --- Subsequent Tab Configuration ---
        $wtArgs += ";", "new-tab", "-p", $tab.Profile, "--title", $tab.Title, "--startingDirectory", $tab.Path
        if ($commandValue) {
            # Separator + command execution for PowerShell profiles
            $wtArgs += "--", $psExecutable, "-NoExit", "-Command", $commandValue
        }
    }
}

# --- Launch Windows Terminal ---
Write-Host "Launching Windows Terminal with args: $($wtArgs -join ' ')"
# Use wt.exe explicitly for clarity and splatting
wt.exe @wtArgs

Write-Host "Windows Terminal launch command sent."


