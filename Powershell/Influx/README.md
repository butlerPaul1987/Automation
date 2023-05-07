# Influx
### InfluxCLI.ps1
This was written to generate information from Window's servers to send to a Linux Influx server taking the parameters below:

```powershell
# Config
$TOKEN = "<TOKEN>"
$Header = @{Authorization = "Token <TOKEN>"}
$URL = "http://<INFLUX URL>:8086"
$ORG = "<ORG NAME>"
$BUCKET = '<BUCKET NAME>'
$COMPUTERNAME = cmd.exe /c hostname
$VMDetails = 0 # check in place for NULL values
```

This was used in production for about a year until I used a different method to generate logs.
