# Powershell automation

## Tasks I've written to automate life 

### PCI Checker
This was a small script I'd written to check over an estate of a company we were looking after in a previous role and see that certain security updates had been applied. There were around 300 sites and 3-5 devices on each site. The task was to open any KB log file and check for certain keywords as at the time, these were being performed manually - thus saving the users responsible months of time. As you can see there were different folders, actions etc to be taken. This could be cleared up and made simpler but for the time and urgency, this was warranted.

### Service Desk Monitor
Possibly my largest script and written over several iterations, the primary goal of this script was to be a monitoring webpage for the largest supplier for a previous company I'd worked for. It would take readings of different metrics for every site and output them all in an HTML formatted page to all of the involved support staff to monitor in real-time.

This would also resolve common faults and even log calls for any issues found, this was probably one of the best things implemented in my time at my previous job.

Changes below:
- [x]    v1.0            PButler        28/05/2019          Test version using 172.16.4.111.: 
- [x]    v1.1            PButler        29/05/2019          Adding HTML conditional formatting     
- [x]    v1.2            PButler        29/05/2019          Added try{} catch{} for service checker.  
- [x]    v1.3            PButler	       31/05/2019	       Added clean up of functions etc (general housekeeping)	
- [x]    v1.4            PButler        03/05/2019          Adding Invoke-sqlcmd commandlet for shift 11 issue. **not working**
- [x]    v1.5            PButler        04/06/2019          Slowly adding in service restarts:
- [x]    v1.6            PButler        11/06/2019          Adding service checkers for powershell CLI - removed for now 
- [x]    v1.7            Pbutler        07/11/2019          Added call logging feature 

### SoundCloud-Bot
This was more of a 'because I can' script and was written to showcase some of Powershell's 'greater' uses with some of my ex-colleague, the bulk of this script is as seen below:

```powershell
while(1){
    # start chome on page
    $Process = Get-Process | Where-Object { $_.Name -eq 'Chrome' }

    if ($Process -eq $null){
        Start-Process -FilePath "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -ArgumentList 'https://soundcloud.com/g-dann'
    }
    
    $mouse = [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(88,49) #1 - won't change
    Click-MouseButton -Button {left}
	Start-Sleep -seconds 5
    $mouse = [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(558,550) #2 - won't change
    Click-MouseButton -Button {left}
    Start-sleep -seconds 35
}
```

### Time File Check 
This was written as a stopgap as we had missing features for certain software, which needed filling for a short time. I was tasked with writing this and creating a small script to enable a firm to have monitoring tools.:

```powershell
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
```

- [x] Deletes log file if older than 30 days
- [x] Checks files in certain directory
- [x] If count in said directory is greater than 0 it will move the files
- [x] It will format and send an email to alert staff of quarantined files
