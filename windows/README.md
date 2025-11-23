# Windows Scripts

This directory contains PowerShell scripts for Windows automation and setup.

## Scripts

### `new_pc_setup.ps1`
Automates the setup of a new PC by installing applications via `winget`, configuring Git, setting up Node.js (via NVM), and configuring the PowerShell profile.

### `stop_proc.ps1`
A utility script to kill processes listening on a specific TCP port.

## Usage

You can get help for any script using `Get-Help`:

```powershell
Get-Help .\windows\new_pc_setup.ps1 -Full
Get-Help .\windows\stop_proc.ps1 -Full
```
