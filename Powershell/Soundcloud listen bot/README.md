# SoundCloud-Bot
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
