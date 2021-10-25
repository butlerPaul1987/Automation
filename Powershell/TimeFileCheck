# TimeFile Check
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
