<#
.EXAMPLE
PS> .\start_services.ps1 dev
PS> .\start_services.ps1 qa

#>

param (
    [string]$env
)

# Vérifier si un argument a été fourni
if (-not $env) {
    Write-Host "Veuillez fournir un environnement: dev ou qa." -ForegroundColor Red
    exit 1
}

# Set correct kubectl context based on environment
if ($env -in "dev", "qa") {
    Write-Host "Switching to non-prod context..."
    kubectl config use-context alae.touba-OBSIT-cluster-noprod
} elseif ($env -eq "staging") {
    Write-Host "Switching to prod context..."
    kubectl config use-context alae.touba-OBSIT-cluster-prod
}

# Variable to store the process IDs of the background jobs
$jobs = @()

# Function to start a process and store its PID
function Start-Job {
    param (
        [string]$command
    )
    $process = Start-Process -NoNewWindow -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command $command" -PassThru
    $jobs += $process.Id
}

# Function to stop all running jobs
function Stop-Jobs {
    Write-Host "`nStopping all background processes..." -ForegroundColor Yellow
    foreach ($job in $jobs) {
        Stop-Process -Id $job -Force
    }
    exit
}

# Register the event handler for Ctrl+C
$handler = {
    Stop-Jobs
}
$null = Register-EngineEvent -SourceIdentifier ConsoleBreak -Action $handler

# Exécuter les commandes en fonction de l'argument
switch ($env) {
    "dev" {
        Write-Host "Starting services for dev environment..."

        Write-Host "Forwarding DB to port 15432..."
        Start-Job "kubectl port-forward service/iam-dev-pgbouncer 15432:5432 -n 1xm-obs-iam-dev"

        Write-Host "Forwarding kratos public to port 14433..."
        Start-Job "kubectl port-forward service/kratos-develop-public 14433:80 -n 1xm-obs-iam-dev"

        Write-Host "Forwarding kratos admin to port 14434..."
        Start-Job "kubectl port-forward service/kratos-develop-admin 14434:80 -n 1xm-obs-iam-dev"

        Write-Host "Forwarding keto read to port 14466..."
        Start-Job "kubectl port-forward service/keto-develop-read 14466:80 -n 1xm-obs-iam-dev"

        Write-Host "Forwarding keto write to port 14467..."
        Start-Job "kubectl port-forward service/keto-develop-write 14467:80 -n 1xm-obs-iam-dev"

        Write-Host "Forwarding oathkeeper access control decision API to port 14456..."
        Start-Job "kubectl port-forward service/oathkcore-develop-api 14456:4456 -n 1xm-obs-iam-dev"


        Write-Host "Forwarding authnadmin API to port 19050..."
        Start-Job "kubectl port-forward service/iam-authnadmin-develop 19050:8080 -n 1xm-obs-iam-dev"	        
    }
    "qa" {
        Write-Host "Starting services for QA environment..."

        Write-Host "Forwarding DB to port 25432..."
        Start-Job "kubectl port-forward service/iam-qa-noprod-pgbouncer 25432:5432 -n 1xm-obs-iam-qa"

        Write-Host "Forwarding kratos public to port 24433..."
        Start-Job "kubectl port-forward service/kratos-qa-public 24433:80 -n 1xm-obs-iam-qa"

        Write-Host "Forwarding kratos admin to port 24434..."
        Start-Job "kubectl port-forward service/kratos-qa-admin 24434:80 -n 1xm-obs-iam-qa"

        Write-Host "Forwarding keto read to port 24466..."
        Start-Job "kubectl port-forward service/keto-qa-read 24466:80 -n 1xm-obs-iam-qa"

        Write-Host "Forwarding keto write to port 24467..."
        Start-Job "kubectl port-forward service/keto-qa-write 24467:80 -n 1xm-obs-iam-qa"

        Write-Host "Forwarding oathkeeper access control decision API to port 24456..."
        Start-Job "kubectl port-forward service/oathkcore-qa-api 24456:4456 -n 1xm-obs-iam-qa"
    }
    "staging" {
        Write-Host "Starting services for Staging environment..."

        Write-Host "Forwarding DB to port 35432..."
        Start-Job "kubectl port-forward service/iam-staging-noprod-pgbouncer 35432:5432 -n 1xm-obs-iam-staging"

        Write-Host "Forwarding kratos public to port 34433..."
        Start-Job "kubectl port-forward service/kratos-staging-public 34433:80 -n 1xm-obs-iam-staging"

        Write-Host "Forwarding kratos admin to port 34434..."
        Start-Job "kubectl port-forward service/kratos-staging-admin 34434:80 -n 1xm-obs-iam-staging"

        Write-Host "Forwarding keto read to port 34466..."
        Start-Job "kubectl port-forward service/keto-staging-read 34466:80 -n 1xm-obs-iam-staging"

        Write-Host "Forwarding keto write to port 34467..."
        Start-Job "kubectl port-forward service/keto-staging-write 34467:80 -n 1xm-obs-iam-staging"

        Write-Host "Forwarding oathkeeper access control decision API to port 34456..."
        Start-Job "kubectl port-forward service/oathkcore-staging-api 34456:4456 -n 1xm-obs-iam-staging"
    }
    default {
        Write-Host "Environnement inconnu: $env. Veuillez fournir un environnement valide: dev ou qa." -ForegroundColor Red
        exit 1
    }
}

# Keep the script running and waiting for Ctrl+C
Write-Host "Press Ctrl+C to stop all background processes."
while ($true) {
    Start-Sleep -Seconds 1
}
