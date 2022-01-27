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
        Version:        1.0
        Author:         PButler
        Creation Date:  27/01/2022
        Purpose/Change: Initial script 
#>

Write-Host "Adding configuration settings:" -ForegroundColor Yellow -NoNewline
##### Job configuration #####
    $num = 0
    $DBhost = "###.###.###.###"
    $ports = "#####", "#####", "#####", "#####"
# Username used for backup task
    $username = "#####", "#####", "#####", "#####"
# Parameters for backup job
    $format = "t" # t for TAR file
    $DBnamesarray = @(
        '#####',
        '#####',
        '#####',
        '#####'
    )
    $dumpFilePath = "E:\Postgres_Backups\Backups\"
    $date = get-date -format yyyy-MM-dd_HH-mm-

# Email configuration
    <#
    $SmtpServer = "127.0.0.1"
    $mailFrom = "Postgres Backup<postgresbackup@company.co.uk>"
    $mailTo = "paul.butler@company.co.uk"

    $mailBody = @"
Transcript of executed job attached.

Please review.
"@
    #>
Write-Host " Completed!" -ForegroundColor Green

################## Begin cleanup configuration ##################
Write-Host "Running Cleanup: " -ForegroundColor Yellow -NoNewline
# files older than 7 days 
$OldFiles = Get-ChildItem -Path "E:\Postgres_Backups\Backups\" -Recurse | Where-Object { $_.Extension -match 'tar' -and $_.LastWriteTime -lt (Get-Date).AddDays(-7) }

if($($OldFiles).Count -gt 0){
    Write-Host "$($OldFiles.Count) files to remove" -ForegroundColor Yellow

    ForEach($file in $OldFiles){
        Remove-Item -Path $($file.FullName) 
        Write-Host "Removing: $($file.Name)" -ForegroundColor Magenta
    }
}
else{
    Write-Host "No file clean up needed" -ForegroundColor Green
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
    if(!(Test-Path -Path ($dumpFilePath + $db))){ 
        New-Item -Path ($dumpFilePath + $db) -ItemType Directory | Out-Null 
    }
    $wrapFileName = $dumpFilePath + $db + "\" + $date+($DB+".tar")

    # create a log of what's happening
    $logLocation = "E:\Postgres_Backups\Logs\$date"+$DB+".log"
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

    # increment num var so it used correct details
    $num = $num + 1
    Clear-Host
}
