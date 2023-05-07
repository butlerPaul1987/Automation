<#
    .SYNOPSIS
        Automated Postgres Backup Script
    .NOTES
        Adapted from: https://github.com/bakingclouds/PostgreSQL/blob/master/Backup-PostgreSQL-DB.ps1
    .DESCRIPTION
        A small automation script which will backup 
        the 4 main Postgres databases to a default location
        which will improve monitoring processes etc.
    .OUTPUTS
        The outputs created are:
            Backup locations: E:\Postgres_Backups\Backups\{Database}\
            Log locations:    E:\Postgres_Backups\Logs\
    .INPUTS
        N/A
    .NOTES
        Version:        1.2
        Author:         PButler
        Creation Date:  27/01/2022
        Purpose/Change: Initial script
    .CHANGELOG
    Version:     Author:    CreateDate:   Change:
    --------     -------    -----------   -------
    V1.0         PButler    27/01/2022    InitialBuild
    v1.1         PButler    11/03/2022    Added Logging
    v1.2         PButler    16/08/2022    Adding mailing via SMTP
     
#>

Write-Host "Adding configuration settings:" -ForegroundColor Yellow -NoNewline
##### Job configuration #####
    $num = 0
    $DBhost = "xxx.xxx.xxx.xxx"
    $ports = "xxx", "xxx", "xxx", "xxx"
# Username used for backup task
    $username = "xxx", "xxx", "xxx", "xxx"
# Parameters for backup job
    $format = "t" # t for TAR file
    $DBnamesarray = @(
        'xxx',
        'xxx',
        'xxx',
        'xxx'
    )
    $dumpFilePath = "E:\Postgres_Backups\Backups\"
    $date = Get-Date -Format yyyy-MM-dd_HH-mm-
    $LogDate = Get-Date -Format dd-MM-yy

# Email configuration

    $SmtpServer = "127.0.0.1"
    $mailFrom = "Postgres Backup<postgresbackup@xxx.co.uk>"
    $mailTo = "xxx.xxx@xxx.co.uk"

    $mailBody = @"
Transcript of executed job attached.

Please review.
"@

Write-Host " Completed!" -ForegroundColor Green
$LineBreak = "##---[$LogDate]:[$dumpFilePath]:[$num]---##"

################## Begin cleanup configuration ##################

Write-Host "Running Cleanup: " -ForegroundColor Yellow -NoNewline
# files older than 7 days 
$OldFiles = Get-ChildItem -Path "E:\Postgres_Backups\Backups\" -Recurse | Where-Object {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)}

# removebackups

if($($OldFiles).Count -gt 0){
    Write-Output $LineBreak | Out-File "E:\Postgres_Backups\Logs\RemovedFiles.txt" -Append
    Write-Host "$($OldFiles.Count) files to remove" -ForegroundColor Yellow
    Write-Output "[$LogDate]: Total to remove: $($OldFiles.Count)" | Out-File "E:\Postgres_Backups\Logs\RemovedFiles.txt" -Append

    ForEach($file in $OldFiles){
        Remove-Item -Path $($file.FullName) -Force
        Write-Output "[$LogDate]: Removing: $($file.Name)" | Out-File "E:\Postgres_Backups\Logs\RemovedFiles.txt" -Append
    }
}
else{
    Write-Host "No file clean up needed" -ForegroundColor Green
}

# removelogs
$OldLogFiles = Get-ChildItem -Path "E:\Postgres_Backups\Logs" -Recurse | Where-Object {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)}
if($($OldLogFiles).Count -gt 0){
    Write-Output $LineBreak | Out-File "E:\Postgres_Backups\Logs\LogRemovedFiles.txt" -Append
    Write-Host "$($OldLogFiles.Count) log files to remove" -ForegroundColor Yellow
    Write-Output "[$LogDate]: Total logs to remove: $($OldLogFiles.Count)" | Out-File "E:\Postgres_Backups\Logs\LogRemovedFiles.txt" -Append

    ForEach($file in $OldLogFiles){
        Remove-Item -Path $($file.FullName) -Force
        Write-Output "[$LogDate]: Removing: $($file.Name)" | Out-File "E:\Postgres_Backups\Logs\LogRemovedFiles.txt" -Append
    }
}
else{
    Write-Host "No log files clean up needed" -ForegroundColor Green
}

# cleanupdirectory
$OldDirs = Get-ChildItem -Path "E:\Postgres_Backups\Backups\" -Recurse | Where-Object {$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)}
if($($OldDirs).Count -gt 0){
    Write-Output $LineBreak | Out-File "E:\Postgres_Backups\Logs\RemovedDir.txt" -Append
    Write-Host "$($OldDirs.Count) files to remove" -ForegroundColor Yellow
    Write-Output "[$LogDate]: Total to remove: $($OldDirs.Count)" | Out-File "E:\Postgres_Backups\Logs\RemovedDir.txt" -Append

    ForEach($file in $OldDirs){
        Remove-Item -Path $($file.FullName) -Force
        Write-Output "[$LogDate]: Removing: $($file.Name)" | Out-File "E:\Postgres_Backups\Logs\RemovedDir.txt" -Append
    }
}
else{
    Write-Host "No directory clean up needed" -ForegroundColor Green
}

# clean up log dir
$OldLogDirs = Get-ChildItem -Path "E:\Postgres_Backups\logs\" -Recurse | Where-Object {$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)}
if($($OldLogDirs).Count -gt 0){
    Write-Output $LineBreak | Out-File "E:\Postgres_Backups\Logs\RemovedLogDir.txt" -Append
    Write-Host "$($OldLogDirs.Count) files to remove" -ForegroundColor Yellow
    Write-Output "[$LogDate]: Total to remove: $($OldLogDirs.Count)" | Out-File "E:\Postgres_Backups\Logs\RemovedLogDir.txt" -Append

    ForEach($file in $OldLogDirs){
        Remove-Item -Path $($file.FullName) -Force
        Write-Output "[$LogDate]: Removing: $($file.Name)" | Out-File "E:\Postgres_Backups\Logs\RemovedLogDir.txt" -Append
    }
}
else{
    Write-Host "No directory clean up needed" -ForegroundColor Green
}
################## End cleanup configuration   ##################


# pg_dump path.
cd "C:\Program Files\pgAdmin 4\v6\runtime\"

# script execution
foreach ($DB in $DBnamesarray) {
    # Path for password file
    $AccountFile = "$env:HOMEPATH\" + $num + "_Account.User.pwd"

    # Read password from file
    $SecureString = Get-Content $AccountFile | ConvertTo-SecureString

    # Create credential object programmatically
    $NewCred = New-Object System.Management.Automation.PSCredential("Account",$SecureString)

    # Variable for postgres password in clear text
    $env:PGPASSWORD = $NewCred.GetNetworkCredential().Password

    # create variable for export path
    if(!(Test-Path -Path ($dumpFilePath + $LOGDATE + '\' + $db))){ 
        New-Item -Path ($dumpFilePath + $LOGDATE + '\' + $db) -ItemType Directory | Out-Null 
    }
    $wrapFileName = $dumpFilePath + $LogDate + "\" + $db + "\" + $date + ($DB+".tar")

    # create a log of what's happening
    $logLocation = "E:\Postgres_Backups\Logs\$LogDate\$date"+$DB+".log"
    Start-Transcript $logLocation

    # write to console which job is running
    Write-Host "Ruuning job for $DB" -ForegroundColor Yellow

    # actually do the backup
    .\pg_dump.exe --file "$wrapFileName" --host $DBhost --port $ports[$num] --username $username[$num] --verbose --format=$format --blobs $DB

    # stop the transcript
    Stop-Transcript

    # check for errors:
    $count = (Get-Content -Path $logLocation | Select-String -Pattern 'error:') # this will need reworking to add more examples
    if($($count).Count -gt 0){
        # send email failed
        #$mailSubject = "Postgres backup failed for: $DB"
        #Send-MailMessage -Attachments "E:\Postgres_Backups\Logs\$date"+$DB+".log" -SmtpServer $SmtpServer -From $mailFrom -To $mailTo -Subject $mailSubject
    }
    else{
        # send email success
        #$mailSubject = "Postgres backup for: $DB"
        #Send-MailMessage -Attachments "E:\Postgres_Backups\Logs\$date"+$DB+".log" -SmtpServer $SmtpServer -From $mailFrom -To $mailTo -Subject $mailSubject
    }

    # increment num var so it uses correct sign on details
    $num = $num + 1
    Clear-Host
}
