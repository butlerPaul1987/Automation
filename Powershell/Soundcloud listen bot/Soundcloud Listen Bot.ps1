# automate all the things.
function Click-MouseButton
{
param(
[string]$Button, 
[switch]$help)
    $signature=@' 
      [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
      public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 
    if($Button -eq "left")
    {
        $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
        $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
    }
    if($Button -eq "right")
    {
        $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0);
        $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0);
    }
    if($Button -eq "middle")
    {
        $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0);
        $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0);
    }
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 



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
          
