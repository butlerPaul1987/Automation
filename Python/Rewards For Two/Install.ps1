<#
.SYNOPSIS
  Installation script for Rewards For Two.py script which allows users to automate the manual process of bing searches.
.DESCRIPTION
  This has been written to automate the installation process, although there are installation steps I felt this could
  imporve the installation process and streamline any possible issues. This installation script is run in 3 parts:
    1. downloads the requirements.txt file from GitHub and runs them
    2. downloads the webdrivers a
    3. finally unzips the webdrivers and allows user to run script
.INPUTS
  None
.NOTES
  Version:        1.0
  Author:         PButler
  Creation Date:  01/01/2022
  Purpose/Change: Initial script development
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#-----------------------------------------------------------[ScriptBlock]------------------------------------------------------------

# set the location to the desktop as the script requires this
Set-Location C:\Users\$env:username\Desktop\

# download the requirements.txt file from GitHub
Invoke-WebRequest -Uri https://raw.githubusercontent.com/butlerPaul1987/Automation/main/Python/Rewards%20For%20Two/Requirments.txt -OutFile requirements.txt

# check pip version/ if installed
if(!(Get-Command python).version.Major){
  Write-Host "Python not installed, please install Python and start again." -ForegroundColor Red
}
else{
    if(!(Get-Command pip).Version){

    # when downloaded, run the pip installation
    py -m pip install -r requirements.txt
   
    # if the Drivers folder doesn't exist, create it
    if(!(Test-Path C:\Users\$env:username\Desktop\Drivers\)){ 
        New-Item -Path C:\Users\$env:username\Desktop\Drivers\ -ItemType Directory | Out-Null 
    }
    
    # check version of edge (if/else)
    $DriverVersion = (Get-ItemProperty -Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion

    # Download the webdriver
    Invoke-WebRequest -Uri "https://msedgedriver.azureedge.net/$DriverVersion/edgedriver_win64.zip" -OutFile .\Drivers\edgedriver.zip

    # Unzip the webdriver
    Expand-Archive -Path .\Drivers\edgedriver.zip -DestinationPath C:\Users\$env:username\Desktop\Drivers\
    }
    else{
        Write-Host "Pip not installed, please install pip and start again." -ForegroundColor Red
    }
}

