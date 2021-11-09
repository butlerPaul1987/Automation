<#
    Title:   EMS Log file capture
    Author:  P.Butler
    Date:    13/11/2020

    Version:    Author:    	Changes:  
    --------    -------    	--------
    v1.0        P.Butler   	Initial draft 
	v1.1		P.Butler	Added file move capacity

#>

# create a small text menu
Clear-Host # so the screen is blank
$Menu = @"
    --------------------------------
    EMS log file generator for Tikit
    --------------------------------

    This will copy the log files into 
    a directory on the desktop, which 
    can then be copied across and sent
    to TIKIT for analysis.

    Press 'Y' to start

"@

Do{
    #title - colourssss
    Write-Host $Menu -ForegroundColor Cyan
    Write-Host ""

    $Answer = Read-Host -Prompt "Enter Value"
    Clear-Host
}
until($Answer -eq 'y')

# do a warning
Write-Host "Warning: if there are a lot of files this will take a while.. please be patient" -ForegroundColor Red
  

# variables start
# date
$TodayNowDate = Get-Date -Format 'dd-MMM-yy HH:mm'
$YesterdayDateNow = (Get-Date).AddDays(-1).ToString("dd-MMM-yy HH:mm")

#folder
$FileLocationUI = 'C:\Program Files\Tikit\eMarketing\UI\App_Data' #UI
$FileLocationData =  'C:\Program Files\Tikit\eMarketing\DATA\App_Data' #DATA
$FileLocationCrm = 'C:\Program Files\Tikit\eMarketing\CRM\App_Data' #CRM
# variables end

# get file counts
$UI = Get-ChildItem -Path $FileLocationUI | Where-Object { $_.LastWriteTime -gt $YesterdayDateNow -and $_.LastWriteTime -lt $TodayNowDate }
$Data = Get-ChildItem -Path $FileLocationData | Where-Object { $_.LastWriteTime -gt $YesterdayDateNow -and $_.LastWriteTime -lt $TodayNowDate } 
$CRM = Get-ChildItem -Path $FileLocationCrm | Where-Object { $_.LastWriteTime -gt $YesterdayDateNow -and $_.LastWriteTime -lt $TodayNowDate }  
$UICount = ($UI).Count
$DataCount = ($Data).Count
$CrmCount = ($CRM).Count

Clear-Host
Write-Host @"
    There are: 
        $UICount UI file(s) to process
        $DataCount Data file(s) to process
        $CrmCount CRM file(s) to process
        
"@ 

# move files
#UI
ForEach($FileUI in $UI){
    if(!(Test-Path 'C:\Users\$username\Desktop\EMS_Logs\UI\')){New-Item -Path 'C:\Users\$username\Desktop\EMS_Logs\UI\' -ItemType Directory | Out-Null }
	Move-Item -Path $($UI.FullName) -Destination C:\Users\$username\Desktop\EMS_Logs\
}

# data
ForEach($FileData in $Data){
    if(!(Test-Path 'C:\Users\$username\Desktop\EMS_Logs\Data\')){New-Item -Path 'C:\Users\$username\Desktop\EMS_Logs\Data\' -ItemType Directory | Out-Null }
	Move-Item -Path $($Data.FullName) -Destination C:\Users\$username\Desktop\EMS_Logs\
}

# crm
ForEach($FileCRM in $CRM){
    if(!(Test-Path 'C:\Users\$username\Desktop\EMS_Logs\CRM\')){New-Item -Path 'C:\Users\$username\Desktop\EMS_Logs\CRM\' -ItemType Directory | Out-Null }
	Move-Item -Path $($CRM.FullName) -Destination C:\Users\$username\Desktop\EMS_Logs\
}