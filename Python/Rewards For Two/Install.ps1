<#
.SYNOPSIS
  Installation script for Rewards For Two.py script which automates the manual process of Bing searches.
.DESCRIPTION
  This script automates the installation process for Rewards For Two.py by:
    1. Downloading requirements.txt from GitHub and installing the Python packages.
    2. Downloading and unzipping Microsoft Edge WebDriver.
    3. Allowing the user to run the script.
.INPUTS
  None
.NOTES
  Version:        1.0
  Author:         PButler
  Creation Date:  01/01/2022
  Purpose/Change: Initial script development
#>

# Set the error action to Stop on error
$ErrorActionPreference = "Stop"

# Script Version
$sScriptVersion = "1.0"

# Set the user's desktop path
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Function to install Python packages from requirements.txt
function Install-PythonPackages {
    if (-not (Test-Path $DesktopPath\Drivers)) {
        New-Item -Path $DesktopPath\Drivers -ItemType Directory | Out-Null
    }

    if (-not (Get-Command pip)) {
        Write-Host "Pip is not installed, please install Pip and start again." -ForegroundColor Red
        return
    }

    # Install Python packages from requirements.txt
    py -m pip install -r $DesktopPath\requirements.txt
}

# Function to download and unzip Microsoft Edge WebDriver
function Download-AndUnzip-EdgeDriver {
    # Check if Edge is installed
    $EdgeExePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $EdgeExePath)) {
        Write-Host "Microsoft Edge is not installed, please install it and start again." -ForegroundColor Red
        return
    }

    $DriverVersion = (Get-Item $EdgeExePath).VersionInfo.ProductVersion
    $EdgeDriverUrl = "https://msedgedriver.azureedge.net/$DriverVersion/edgedriver_win64.zip"
    $DriverZipPath = $DesktopPath\Drivers\edgedriver.zip

    # Download Edge WebDriver
    Invoke-WebRequest -Uri $EdgeDriverUrl -OutFile $DriverZipPath

    # Unzip Edge WebDriver
    Expand-Archive -Path $DriverZipPath -DestinationPath $DesktopPath\Drivers
    Remove-Item $DriverZipPath  # Remove the downloaded ZIP file
}

# Set the working directory to the user's desktop
Set-Location $DesktopPath

# Download requirements.txt from GitHub
$GitHubRequirementsUrl = "https://raw.githubusercontent.com/butlerPaul1987/Automation/main/Python/Rewards%20For%20Two/Requirements.txt"
Invoke-WebRequest -Uri $GitHubRequirementsUrl -OutFile "$DesktopPath\requirements.txt"

# Check if Python is installed
if (-not (Get-Command python)) {
    Write-Host "Python is not installed, please install Python and start again." -ForegroundColor Red
} else {
    Install-PythonPackages
    Download-AndUnzip-EdgeDriver
}

# Provide a message to the user for running the script
Write-Host "You can now run Rewards For Two.py." -ForegroundColor Green
