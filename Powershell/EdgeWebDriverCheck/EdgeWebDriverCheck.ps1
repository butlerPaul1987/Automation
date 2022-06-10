<#
    .SYNOPSIS
        WebDriver version checker
    .NOTES
        URL format: https://msedgedriver.azureedge.net/103.0.1264.11/edgedriver_win64.zip
    .DESCRIPTION
        A small script with the sole purpose of checking
        the current version installed of Edge, it will then
        run checks against the verison of the webdriver installed
        and from there determine if you need a new version.
        
        These will not run unless the version of Edge and webdriver
        are in sync. 
    .OUTPUTS
        The outputs created are:
            WebDriver(zipped): edgedrive.zip
            WebDriver(unzip) : msedgedriver.exe
            FileLocation     : C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\ 
    .INPUTS
        N/A
    .NOTES
        Version:    Author:         Creation Date:    Purpose/Change:
        --------    -------         --------------    ---------------
        v1.0        Paul Butler     10/06/2022        Initial Build
#>

<# Check that edgeWeb Driver is installed#>
# Should be the same location.. soooo
if(!(Test-Path -Path "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\msedgedriver.exe")){

    # gets version of Edge installed on box
    $Version = Get-WmiObject -Class Win32_Product | where Name -Like "*Edge*" | Select-Object Version

    # downloads newest/ required version of edge
    Invoke-WebRequest `
        -Uri "https://msedgedriver.azureedge.net/$($Version.Version)/edgedriver_win64.zip" `
        -OutFile "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\edgedrive.zip"

    # extract file
    Expand-Archive `
        -LiteralPath "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\edgedrive.zip" `
        -DestinationPath "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\msedgedriver.exe"

}
else{
    # check versions are the same
    $InstalledVersion = (Get-Item "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\msedgedriver.exe").VersionInfo.FileVersion
    $Version = Get-WmiObject -Class Win32_Product | where Name -Like "*Edge*" | Select-Object Version

    if($InstalledVersion -eq $Version){
        Write-Host "Up to date with version: $Version"
    }
    else{
        Write-Host "Version: $Version : Out of date"

        # downloads newest/ required version of edge
        Invoke-WebRequest `
            -Uri "https://msedgedriver.azureedge.net/$($Version.Version)/edgedriver_win64.zip" `
            -OutFile "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\edgedrive.zip"

        # extract file
        Expand-Archive `
            -LiteralPath "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\edgedrive.zip" `
            -DestinationPath "C:\Users\paul.butler\OneDrive - toob Limited\Desktop\WebDriver\msedgedriver.exe"
    }
}
