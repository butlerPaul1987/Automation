<#     
    Author:         Paul Butler
    Date:           01/07/2019
    Title:          PCI Patching check script

    Description:    This will check each device POS1-4 and ANPR for patching (KB files)
                    and will then check if those KB files have been applied and installed
                    correctly.

    Update:         Author:        Date:               Desc:
    -------         -------        -----               -----
    v1.0            PButler        01/07/2019          Test version to be run against one site. 
    v1.1            PButler        07/07/2019          Added $Device variable to check each device 
    v1.2            PButler        11/07/2019          Added sanity checks to see if patch installed without error
    v1.3            PButler        11/09/2019          Addec checks for necessary files (7z.exe and SiteList.csv files)

    Info :- Please see below directories that are checked:
        --> c\PCI\Win 7 updates\Client\Static\Custom\
        --> c\PCI\Win 10 updates\Client\Static\Custom\
        --> c\ PCI\Win 10 updates\Client\Static\Custom\
        --> c\Temp\GDPRPatching\client\static\custom\
        --> C\TEMP\Win 10 updates\client\static\custom\
#>
Clear-Host

$Email = "PCI Script<apci@company.co.uk>"
$Host.UI.RawUI.WindowTitle = "PCI patch checker!"

# See if all files exist
if(!(Test-Path -Path 'Y:\PaulB\PCI\7za.exe'))
    { 
        Write-Host "7z.exe does not exist!" -ForegroundColor Red  
        Start-Sleep -Seconds 10
        Exit
    }
if(!(Test-Path -Path 'Y:\PaulB\PCI\sitelist.csv'))
    { 
        Write-Host "SiteList.csv does not exist!" -ForegroundColor Red 
        Start-Sleep -Seconds 10
        Exit
    }


$Date = Get-Date -Format 'dd-MM-yy'
if(!(Test-Path -Path "Y:\PaulB\PCI\Logs\$Date")){ New-Item -Path "Y:\PaulB\PCI\Logs\$Date" -ItemType Directory | Out-Null } 
$estate = Import-Csv 'Y:\PaulB\PCI\sitelist.csv'

#csv file header
Write-Output "SiteNum,SiteName,Device,Patch,Date,Applied" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" 

# script block
foreach($site in $estate){
    foreach($device in 'POS1IP','POS2IP','POS3IP','ANPRIP'){
        if($($site.$device) -ne '111.111.111.111'){ 
            net use "\\$($site.$device)" /User:username password | Out-Null
            Write-Host "Checking $($site.SiteName): " -NoNewline
            Write-Host "$($device.Substring(0,4))" -ForegroundColor Yellow

            #c\PCI\Win 7 updates\Client\Static\Custom\
            if(Test-Path "\\$($site.$device)\c\PCI\Win 7 updates\Client\Static\Custom\"){ 
                Write-Host "Win 7 Exists!" -ForegroundColor Green
                $files = gci -Path "\\$($site.$device)\c\PCI\Win 7 updates\Client\Static\Custom\" | select -Property Name

                foreach($file in $files){
                    $kb = Import-Csv -path "\\$($site.$device)\c\PCI\Win 7 updates\Client\Static\Custom\$($file.Name)" -Delimiter ',' -Header 'KB', 'LineDetail' | Where-Object 'LineDetail' -match '2019-' 
                    foreach($kbLine in $kb){
                        if((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Warning'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),FAILED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Magenta
                        }
                        elseif((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Installed'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),INSTALLED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Green                            
                        }
                        else{
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),NO" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Red
                        }
                    }
                }
            }
            #c\PCI\Win 10 updates\Client\Static\Custom\
            elseif(Test-Path "\\$($site.$device)\c\PCI\Win 10 updates\Client\Static\Custom\"){
                Write-Host "Win 10 Exists!" -ForegroundColor Green
                $files = gci -Path "\\$($site.$device)\c\PCI\Win 10 updates\Client\Static\Custom\" | select -Property Name

                foreach($file in $files){
                    $kb = Import-Csv -path "\\$($site.$device)\c\PCI\Win 10 updates\Client\Static\Custom\$($file.Name)" -Delimiter ',' -Header 'KB', 'LineDetail'  | Where-Object 'LineDetail' -match '2019-' 
                    foreach($kbLine in $kb){
                        if((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Warning'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),FAILED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Magenta
                        }
                        elseif((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Installed'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),INSTALLED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Green                            
                        }
                        else{
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),NO" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Red
                        }
                    }
                }
            }
            #c\ PCI\Win 10 updates\Client\Static\Custom\
            elseif(Test-Path "\\$($site.$device)\c\ PCI\Win 10 updates\Client\Static\Custom\"){
                Write-Host "PCI Win 10 Exists!" -ForegroundColor Green
                $files = gci -Path "\\$($site.$device)\c\PCI\Win 10 updates\Client\Static\Custom\" | select -Property Name
                foreach($file in $files){
                    $kb = Import-Csv -path "\\$($site.$device)\c\PCI\Win 10 updates\Client\Static\Custom\$($file.Name)" -Delimiter ',' -Header 'KB', 'LineDetail'  | Where-Object 'LineDetail' -match '2019-' 
                    foreach($kbLine in $kb){
                        if((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Warning'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),FAILED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Magenta
                        }
                        elseif((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Installed'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),INSTALLED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Green                            
                        }
                        else{
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),NO" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Red
                        }
                    }
                }
            }
            #C\Temp\GDPRPatching\client\static\custom\
            elseif(Test-Path "\\$($site.$device)\C\Temp\GDPRPatching\client\static\custom\"){
                Write-Host "GDPR Patching Exists!" -ForegroundColor Green
                $files = gci -Path "\\$($site.$device)\C\Temp\GDPRPatching\client\static\custom\" | select -Property Name

                foreach($file in $files){
                    $kb = Import-Csv -path "\\$($site.$device)\C\Temp\GDPRPatching\client\static\custom\$($file.Name)" -Delimiter ',' -Header 'KB', 'LineDetail'  | Where-Object 'LineDetail' -match '2019-' 
                    foreach($kbLine in $kb){
                        if((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Warning'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),FAILED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Magenta
                        }
                        elseif((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Installed'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),INSTALLED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Green                            
                        }
                        else{
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),NO" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Red
                        }
                    }
                }
            }
            #C\TEMP\Win 10 updates\client\static\custom\
            elseif(Test-Path "\\$($site.$device)\C\TEMP\Win 10 updates\client\static\custom\"){ 
                Write-Host "Temp\Win10 Exists!" -ForegroundColor Green
                $files = gci -Path "\\$($site.$device)\C\TEMP\Win 10 updates\client\static\custom\" | select -Property Name

                foreach($file in $files){
                    $kb = Import-Csv -path "\\$($site.$device)\C\TEMP\Win 10 updates\client\static\custom\\$($file.Name)" -Delimiter ',' -Header 'KB', 'LineDetail'  | Where-Object 'LineDetail' -match '2019-' 
                    foreach($kbLine in $kb){
                        if((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Warning'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),FAILED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Magenta
                        }
                        elseif((Get-Content "\\$($site.$device)\c\WINDOWS\wsusofflineupdate.log" | Select-String "$($kbLine.KB)") -match 'Installed'){
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),INSTALLED" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Green                            
                        }
                        else{
                            Write-Output "$($site.SiteNum),$($site.SiteName),$($Device.Substring(0,4)),$($kbLine.KB),$($kbLine.LineDetail.Substring(0,7)),NO" | Out-File "Y:\PaulB\PCI\Logs\$Date\PCI.csv" -Append 
                            Write-Host "$($kbLine.Kb): $($kbLine.LineDetail.Substring(0,7))" -ForegroundColor Red
                        }
                    }
                }
            }
            else{
            #can't find anything :( - do a le cry
                Write-Host "No folders found!" -ForegroundColor Red
                Write-Output "$($site.SiteName) [$($device.Substring(0,4))]: No folders found" | Out-File "Y:\PaulB\PCI\Logs\$Date\NotFound.log" -Append 
            }

            Write-Host ""

            net use "\\$($site.$device)" /delete | Out-Null
        }
    }
} 

# find last created file
$day = 1
do{
    $Yesterday = (get-date (get-date).addDays(-$day) -UFormat "%d-%m-%y")
    $TestPath = Test-Path "Y:\PaulB\PCI\Logs\$Yesterday\PCI.csv"
    
    Write-Host "Trying: " -NoNewline
    Write-Host "$Yesterday " -ForegroundColor Yellow -NoNewline
    
    if($TestPath -ne $true){
        Write-Host "[x]" -ForegroundColor Red -BackgroundColor Black
    }
    else{
        Write-Host "[!]" -ForegroundColor Green -BackgroundColor Black
    }
    # if it fails.. add an extra day
    $day = $day + 1 

}
until($TestPath -eq $true)

# add old/new files into variable
$FileNew = Import-Csv "Y:\PaulB\PCI\Logs\$Date\PCI.csv"
$FileOld = Import-Csv "Y:\PaulB\PCI\Logs\$Yesterday\PCI.csv"

# add compare object into variable
$Compare = Compare-Object -ReferenceObject $FileOld -DifferenceObject $FileNew

ForEach($Line in $Compare){
     $InputObject = @"
     $InputObject
     $($Line.InputObject.SiteNum),$($Line.InputObject.SiteName),$($Line.InputObject.Applied),$($Line.SideIndicator)
"@
}


# e-mail Mel when done, so I don't have to get asked/keep checking.
$Body = @"
Hello,

    The script has run and the file will be in "Y:\PaulB\PCI\Logs\$Date\PCI.csv".

    The following changes have been made:

$InputObject

    This is an automated e-mail. Please do not respond.

Kind Regards,
Beep Boop Beep.
"@

Set-Alias zip "Y:\PaulB\PCI\7za.exe"
zip a -mx=9 "Y:\PaulB\PCI\Logs\$Date\PCI.7z" "Y:\PaulB\PCI\Logs\$Date\PCI.csv"
$To =  'pbutler@company.co.uk','email@company.co.uk','email@company.co.uk','email@company.co.uk'

Send-MailMessage -To $To -From $Email -Subject "PCI script run" -Body $Body -SmtpServer 'mail.company.co.uk' -Bcc 'pbutler@company.co.uk' -Attachments "Y:\PaulB\PCI\Logs\$Date\PCI.7z" 

