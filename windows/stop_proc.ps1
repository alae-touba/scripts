<#
.SYNOPSIS
Kills processes listening on a specific TCP port.

.PARAMETER Port
The TCP port number (1-65535) to check for listening processes.

.EXAMPLE
PS> .\stop_proc.ps1 -Port 8080

#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(1, 65535)]
    [int]$Port
)

# Get processes listening on the specified port
$processes = Get-NetTCPConnection -LocalPort $Port -State Listen | Select-Object -ExpandProperty OwningProcess -Unique

if (-not $processes) {
    Write-Host "No processes found listening on port $Port"
    exit
}

foreach ($processId in $processes) {
    try {
        $process = Get-Process -Id $processId -ErrorAction Stop
        Write-Host "Killing process $processId ($($process.ProcessName))"
        Stop-Process -Id $processId -Force -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Host "Failed to kill process $processId : $_" -ForegroundColor Red
    }
}