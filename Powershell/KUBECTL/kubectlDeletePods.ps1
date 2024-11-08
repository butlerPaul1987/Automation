param(
    [Parameter(Mandatory=$true)]
    [string]$namespace,
    
    [Parameter(Mandatory=$true)]
    [string]$filename,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Function to test access to the namespace
function Test-NamespaceAccess {
    param([string]$ns)
    
    Write-Host "Testing access to namespace '$ns'..." -ForegroundColor Cyan
    $result = kubectl get namespace $ns 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to access namespace '$ns'. Please check your permissions and namespace name."
    }
    Write-Host "Successfully accessed namespace '$ns'." -ForegroundColor Green
}

# Function to restart a pod
function Restart-Pod {
    param(
        [string]$podName,
        [switch]$DryRun
    )
    
    Write-Host "Restarting pod: $podName" -ForegroundColor Yellow
    if ($DryRun) {
        Write-Host "[DRY RUN] Would restart pod: $podName" -ForegroundColor Cyan
    } else {
        $result = kubectl delete pod $podName -n $namespace 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error restarting pod $podName: $result" -ForegroundColor Red
        } else {
            Write-Host "Successfully restarted pod $podName" -ForegroundColor Green
        }
    }
}

# Function to validate pod existence
function Test-PodExistence {
    param(
        [string]$podName
    )

    $result = kubectl get pod $podName -n $namespace --no-headers 2>&1
    return ($LASTEXITCODE -eq 0)
}

# Main script execution
try {
    # Test access to the namespace
    Test-NamespaceAccess -ns $namespace

    # Read pod names from the file
    if (-not (Test-Path $filename)) {
        throw "File '$filename' not found."
    }
    
    $pods = Get-Content $filename

    # Validate and restart each pod
    $totalPods = $pods.Count
    $successfulRestarts = 0
    $failedRestarts = 0

    foreach ($pod in $pods) {
        if (-not [string]::IsNullOrWhiteSpace($pod)) {
            $podName = $pod.Trim()
            if (Test-PodExistence -podName $podName) {
                Restart-Pod -podName $podName -DryRun:$DryRun
                if (-not $DryRun) {
                    $successfulRestarts++
                }
            } else {
                Write-Host "Pod '$podName' not found in namespace '$namespace'. Skipping." -ForegroundColor Yellow
                $failedRestarts++
            }
        }
    }

    # Summary
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "Total pods processed: $totalPods" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "Dry run completed. No actual restarts performed." -ForegroundColor Cyan
    } else {
        Write-Host "Successfully restarted: $successfulRestarts" -ForegroundColor Green
        Write-Host "Failed to restart: $failedRestarts" -ForegroundColor Red
    }

} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
} finally {
    # No actions needed
}
