<#
    Title:  Time file checker
    Date:   07-06-2021

    Desc:   This will check for tim files and move
            any failed files to a 'to-check' folder
            and email any given recipient to let them know
            they need to check said files

#>

# Variables
Clear-Host # clears host (console screen)
$FolderToCheck = 'C:\Users\pb001\Desktop\Check\'
$Ext = '.TIM' # change extension type if needed
$MovedFiles = 'C:\Users\pb001\Desktop\Check\Moved'
$LogLocation = 'C:\Users\pb001\Desktop\Check\Logs\'
$Days = 30 # delete log files after this many days


# Mailing Variables
$To = 'paul.butler@company.com'
$From = 'Carpe Check Test<CarpeCheck@company.com>'
$Subject = 'Time files require attention'
$SmtpAddress = 'SMTP' #SMTP address goes here
$Port = 25


# Create job -- create move directory if it doesn't exist
if( Test-Path -Path $MovedFiles ){ } else { New-Item -Path $MovedFiles -ItemType Directory | Out-Null }
if( Test-Path -Path $LogLocation ){ } else { New-Item -Path $LogLocation -ItemType Directory | Out-Null }

# clear log file after x days
$RemoveLogs = Get-ChildItem -Path $LogLocation | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Days)}

if($($RemoveLogs).Count -gt 0){
    Write-Output "Removing logs..."
    ForEach($OldLog in $RemoveLogs){
        Write-Output "Removing: $($OldLog.Name)"
        Remove-Item -Path $($OldLog.FullName) | Out-Null
    }
}
else{
    Write-Output "No logs to remove..."
}

# Gets list of files with a particular extension
$BadFiles = Get-ChildItem -Path $FolderToCheck | Where-Object { $_.Extension -match $Ext }

# checks if the count of said files exceeds 0
$LogName = 'MovedFiles_' + (Get-Date -Format 'dd-MM-yy') + '.txt'

if(($BadFiles.Count) -gt 0){
    Write-Host "Count: " -NoNewline 
    Write-Host "$($BadFiles.Count)" -ForegroundColor Red

    $Body = "<!DOCTYPE html>
<html>
<head>
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
}

td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

p {
    font-family: arial, sans-serif;
}
</style>
</head>
<body>

<p>Please be aware there are $($BadFiles.Count) files that require attention.</p>
<p>These will be held in: '$MovedFiles'.</p>
<br>
<table>
  <tr>
    <th>FileName</th>
    <th>DateModified</th>
  </tr>
"

    # move files
    ForEach($File in $BadFiles){
        Write-Host "Moving file: " -NoNewline
        Write-Host "$($File.Name) " -ForegroundColor Yellow -NoNewline

        try{
            Move-Item -Path $($File.FullName) -Destination $MovedFiles
            Write-Host "[]" -BackgroundColor Green
            $Body = $Body + "
  <tr>
    <td>$($File.Name)</td>
    <td>$($File.LastWriteTime)</td>
  </tr>
"
    $Log = $LogLocation + $LogName
    $Time = Get-Date -Format 'HH:mm'
    Write-Output "[$Time]: Moved file: $($File.Name)" | Out-File $Log -Append
        }
        catch{
            Write-Host "[]" -BackgroundColor Red
            $Time = Get-Date -Format 'HH:mm'
            Write-Output "[$Time]: $($File.Name) failed to move! Please investigate" | Out-File $Log -Append
        }
    }

    # send email
    $Body = $Body + "
</table>
<br>
<p>Kind Regards,</p>
<p>Advanced Systems</p>

</body>
</html>
"
    Try{
        Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SmtpAddress -Port $Port
        Write-Host "Email sent successfully" -ForegroundColor Green
        $Time = Get-Date -Format 'HH:mm'
        Write-Output "[$Time]: Email sent to: $To" | Out-File $Log -Append

    }
    catch{
        Write-Host "Email failed" -ForegroundColor Red  
        $Time = Get-Date -Format 'HH:mm'
        Write-Output "[$Time]: Email Failed to send! Please investigate" | Out-File $Log -Append

    }
}


# if there's nothing relevant in the folder, do nothing
else{
    Write-Host "No files, script ending" -ForegroundColor Green
}
