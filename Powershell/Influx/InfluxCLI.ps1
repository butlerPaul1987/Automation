#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        INFLUX CLI VM collector script
    .NOTES
        This will need to be run as admin
    .DESCRIPTION
        A small automation script which will get data
        from the VM query: 'Get-VM' and output to the
        InfluxDB buckets via the InfluxCLI. 
    .OUTPUTS
        The outputs created are:
            DB:     INFLUXDB - http://<INFLUX URL>:8086
            BUCKET: <BUCKET NAME>
    .INPUTS
        N/A
    .NOTES
        Version:    Author:         Creation Date:    Purpose/Change:
        --------    -------         --------------    ---------------
        v1.0        Paul Butler     11/02/2022        Initial Build
        v1.1        Paul Butler     17/02/2022        Added RAM check   
#>

# Config
$TOKEN = "<TOKEN>"
$Header = @{Authorization = "Token <TOKEN>"}
$URL = "http://<INFLUX URL>:8086"
$ORG = "<ORG NAME>"
$BUCKET = '<BUCKET NAME>'
$COMPUTERNAME = cmd.exe /c hostname
$VMDetails = 0 # check in place for NULL values

# if a config file doesn't exist create this is because you can only create one config with the same name per host
Set-Location 'C:\VMCount\'
if(!(Test-Path -Path 'config-check.txt')){
    # create a config if not exists
    .\influx.exe config create --config-name "InfluxCLI" `
      --host-url "http://192.168.15.24:8086" `
      --org "my-org" `
      --token $TOKEN `
      --active

    # create file
    New-Item -Path 'config-check.txt' -ItemType File
}

while(1){
    # Get total RAM size
    $RAM = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum

    # Get VM Info
    $VMDetails = Get-VM 
    $RunningCount = ($VMDetails | Where-Object { $_.State -eq 'Running' }).Count
    $StoppedCount = ($VMDetails | Where-Object { $_.State -ne 'Running' }).Count
    $TimeStamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds() * 1000000
    $URI = $URL + "/api/v2/write?org=" + $ORG + "&bucket=" + $BUCKET

    if($VMDetails = 0){ # if details = zero the Get-VM commandlet hasn't worked
        Write-Host @"
    VMDetails blank please check details:

    VMDetails:     $VMDetails
    RunningCount:  $RunningCount
    StoppedCount:  $StoppedCount
    Host:          $COMPUTERNAME

"@ # do not indent it will break script
        Start-Sleep -Seconds 60
    }
    else{
        # Send data for Stopped
        Invoke-WebRequest -Uri $URI `
            -Header $Header `
            -Method POST `
            -Body "VMStats,Host=$COMPUTERNAME Stopped=0 $TimeStamp" # sends stopped stats

        # Send data for Running
    
        Invoke-WebRequest -Uri $URI `
            -Header $Header `
            -Method POST `
            -Body "VMStats,Host=$COMPUTERNAME Running=0 $TimeStamp" # sends running stats 

        # Send data for RAM total size
        Invoke-WebRequest -Uri $URI `
            -Header $Header `
            -Method POST `
            -Body "TotalPhysicalMemory,Host=$COMPUTERNAME MemTotal=$RAM $TimeStamp" # sends ram stats 

        # Sleep for a defined time?
        Start-Sleep -Seconds 60
    }
}
