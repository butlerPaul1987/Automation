param(
    [Parameter(Mandatory=$true)]
    [string]$namespace,
    
    [Parameter(Mandatory=$true)]
    [string]$filename
)

# Function to test access to the namespace
function Test-NamespaceAccess {
    param([string]$ns)
    
    $result = kubectl get namespace $ns 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Unable to access namespace '$ns'. Please check your permissions and namespace name." -ForegroundColor Red
        exit 1
    }
    Write-Host "Successfully accessed namespace '$ns'." -ForegroundColor Green
}

# Function to restart a pod
function Restart-Pod {
    param([string]$podName)
    
    Write-Host "Restarting pod: $podName" -ForegroundColor Yellow
    $result = kubectl delete pod $podName -n $namespace 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error restarting pod $podName: $result" -ForegroundColor Red
    } else {
        Write-Host "Successfully restarted pod $podName" -ForegroundColor Green
    }
}

# Main script execution
try {
    # Test access to the namespace
    Test-NamespaceAccess -ns $namespace

    # Read pod names from the file
    if (-not (Test-Path $filename)) {
        Write-Host "Error: File '$filename' not found." -ForegroundColor Red
        exit 1
    }
    
    $pods = Get-Content $filename

    # Restart each pod
    foreach ($pod in $pods) {
        if (-not [string]::IsNullOrWhiteSpace($pod)) {
            Restart-Pod -podName $pod.Trim()
        }
    }
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
