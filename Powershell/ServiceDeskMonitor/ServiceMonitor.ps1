<#
    Author:         Paul Butler
    Date:           28/05/2019
    Title:          NXG Service monitor: HTML output

    Description:    This checks all figures and such and outputs to 
                    a HTML file.

    Update:         Author:        Date:               Desc:
    -------         -------        -----               -----
    v1.0            PButler        28/05/2019          Test version using 172.16.4.111.: 
    v1.1            PButler        29/05/2019          Adding HTML conditional formatting     
    v1.2            PButler        29/05/2019          Added try{} catch{} for service checker.  
    v1.3            PButler	       31/05/2019	       Added clean up of functions etc (general housekeeping)	
    v1.4            PButler        03/05/2019          Adding Invoke-sqlcmd commandlet for shift 11 issue. **not working**
    v1.5            PButler        04/06/2019          Slowly adding in service restarts:
    v1.6            PButler        11/06/2019          Adding service checkers for powershell CLI - removed for now 
    v1.7            Pbutler        07/11/2019          Added call logging feature 
#>

# basic config
$currentversion = "1.7"
$host.ui.RawUI.WindowTitle = "System Monitor v$currentversion"
$sites = Import-CSV "Y:\PaulB\Quaz\SiteList.csv"
$LastEmail = $null

$emailrecipients = "pbutler@company.co.uk"
$From = 'Quarantine Check<Quaz@company.co.uk>'
$smtp = 'mail.company.co.uk'

# only do this once per run of the script
$resp = Invoke-WebRequest `
    -Uri 'https://calllogging.company.co.uk/login.aspx' `
    -Method Get `
    -SessionVariable Session

$inputs = $resp.Content.Split([System.Environment]::NewLine) | Select-String 'name="__' | ForEach-Object { [xml]$_ }   

$resp = Invoke-WebRequest `
    -Uri 'https://calllogging.company.co.uk/login.aspx' `
    -Method Post `
    -Body @{
        "__LASTFOCUS" = $inputs.input | Where-Object { $_.name -eq "__LASTFOCUS" } | Select-Object -ExpandProperty value
        "__VIEWSTATE" = $inputs.input | Where-Object { $_.name -eq "__VIEWSTATE" } | Select-Object -ExpandProperty value
        "__VIEWSTATEGENERATOR" = $inputs.input | Where-Object { $_.name -eq "__VIEWSTATEGENERATOR" } | Select-Object -ExpandProperty value
        "__EVENTTARGET" = $inputs.input | Where-Object { $_.name -eq "__EVENTTARGET" } | Select-Object -ExpandProperty value
        "__EVENTARGUMENT" = $inputs.input | Where-Object { $_.name -eq "__EVENTARGUMENT" } | Select-Object -ExpandProperty value
        "__EVENTVALIDATION" = $inputs.input | Where-Object { $_.name -eq "__EVENTVALIDATION" } | Select-Object -ExpandProperty value
        lfUserName = 'username' # change me
        lfPassword = 'password' # change me
        loginButton = 'Login'
    } `
    -WebSession $Session 
# end config

# title 
Write-Host @"
                                                             
                                                             
  ███╗   ███╗ ██████╗ ███╗   ██╗██╗████████╗ ██████╗ ██████╗ 
  ████╗ ████║██╔═══██╗████╗  ██║██║╚══██╔══╝██╔═══██╗██╔══██╗
  ██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝
  ██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗
  ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║
  ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
"@ -ForegroundColor Red -BackgroundColor White
Write-Host @"
      - notes : 
      Site will be 
"@ -NoNewline -ForegroundColor Yellow

Write-Host "green " -ForegroundColor Green -NoNewline

Write-Host @"
if script can connect to site
      sitename will be in 
"@ -ForegroundColor Yellow -NoNewline
Write-Host "red " -NoNewline -ForegroundColor Red
Write-Host @"
if it can't.  

"@ -ForegroundColor Yellow
# end title settings

# css output
$OutputStyleSheet = @"
<link href='https://fonts.googleapis.com/css?family=Pacifico' rel='stylesheet'> 
<div id = "scoped-content">
    <style>
    table {
		font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        width: 100%;
    }
    h1 {
        font-family: 'Pacifico';
	    color: white;
    }
    table td, table th {
      border: 1px solid #ddd;
      padding: 8px;
    }
    body{
	    background-color: 46BADF;
	    color: white;
    }
    table tr:hover {
		background-color: #ddd;
	}
    table th {
          padding-top: 12px;
          padding-bottom: 12px;
          text-align: left;
          background-color: #4680DF;
          color: white;
    }
    </style>
"@ 

while(1){
# delete export file
if(Test-Path -Path C:\Users\$env:username\Desktop\Export.csv){
    Remove-Item -Path C:\Users\$env:username\Desktop\Export.csv -Force
}
# start log file
$Date = Get-Date -Format 'dd MMM yy'
if(!(Test-Path -Path "Y:\PaulB\Log\$Date\")){
    New-Item -Path "Y:\PaulB\Monitor\Log\$Date\" -ItemType Directory | Out-Null }
Write-Output "SiteName,BackOfficePCIPaddress,Error" | Out-File "Y:\PaulB\Monitor\Log\$Date\BadSites.csv"
# end log file
	$bodytext = @"
    <div id = "scoped-content">
    $OutputStyleSheet
    <h1>Service Monitor</h1>
    <table style="width:100%">
    <tr>
	    <th>SiteID</th>
	    <th>Site Name</th>
	    <th>Import Count</th>
	    <th>Quarantine RP files</th>
	    <th>RP files (Unprocessed)</th>
	    <th>VBO Count(UP)</th>
	    <th>VBO Count(Down)</th>
        <th>PreProcessing(MOR)</th>
    </tr> 
"@
    ## <-- START SCRIPT BLOCK --> 
    foreach($site in $sites){
        try{
            if($($site.Win10) -eq 'N'){
                net use \\$($site.BackOfficePCIPaddress) /User:SiteName Password | Out-Null
            }
            else{
                net use \\$($site.BackOfficePCIPaddress) /User:SiteName "Password" | Out-Null
            }
        }
        catch{
            Write-Host "Failed to connect to $($site.Name). Please investigate." -ForegroundColor Red
        }

        if(!(Test-Path "\\$($site.BackOfficePCIPaddress)\c\Temp\NXG\")){
            Write-Host "Connected to: " -NoNewline
            Write-Host "$($site.SiteName)" -ForegroundColor Red

            Write-Output "$($site.SiteName),$($site.BackOfficePCIPaddress),Can't Connect" | Out-File "Y:\PaulB\Monitor\Log\$Date\Sites_Bad.csv" -Append

            # html output for failures
           $bodytext = @"
           $bodytext
        <tr>
            <td bgcolor="#DF4646"><font color="white">$($site.SiteId)</font></td>
		    <td bgcolor="#DF4646"><font color="white">$($site.SiteName)</font></td>
            <td>N/A</td>
            <td>N/A</td>
            <td>N/A</td>
            <td>N/A</td>
            <td>N/A</td>
            <td>N/A</td>
"@

            Write-Host "" # just to space it out.
        }
        else{
            Write-Host "Connected to: " -NoNewline
            Write-Host "$($site.SiteName)" -ForegroundColor Green

        # total import files
        Write-Host "Total import count - " -NoNewline
        try{
            $CountTotal = (Get-ChildItem -af "\\$($site.BackOfficePCIPAddress)\c\Temp\NXG\Import\").Count
            Write-Host "$CountTotal" -ForegroundColor Yellow
        }
        catch{
            Write-Host "[X]" -ForegroundColor Red
        }

        # quarantine transaction files
        Write-Host "Quarantine count   - " -NoNewline
        try{
            if(!(Test-Path -Path "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\Quarantine\")){New-Item "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\Quarantine\" -ItemType Directory | Out-Null} 
            $rpQuaz = Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\Quarantine\" | Where-Object -FilterScript {($_.Name -Match "RP") -and ($_.Extension -eq ".csv")}
            $countRPQuaz = ($($rpQuaz.Count))
            if($countRPQuaz -gt '0'){
                Move-Item -Path "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\Quarantine\RP*.csv" -Destination "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\" -Force
                Start-Sleep -Seconds 15
                $countRPQuazNew = (Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\Quarantine\" | Where-Object -FilterScript {($_.Name -Match "RP") -and ($_.Extension -eq ".csv")}).Count
                if($countRPQuazNew -gt '0'){
                    Write-Host "$countRPQuazNew : file(s) failed. Sending e-mail..." -ForegroundColor Red
                    if($LastEmail -eq $null){
                        Send-MailMessage -To $emailrecipients -From $From -Subject "$($site.SiteName) has quarantined RP files" -Body "$($rpQuaz.Name)<br><br>There are quarantined files that require attention.<br> Please investigate." -SmtpServer $smtp -BodyAsHtml
                        $LastEmail = $null
                        Write-Output "RPOS$($site.SiteId),$countRPQuazNew" | Out-File "C:\Users\$env:username\Desktop\Export.csv" -Append
                    }
                    else{
                        $TimeNow = Get-Date
                        $TimeSince = (New-TimeSpan $LastEmail $TimeNow).TotalHours
                        if($TimeSince -ge 1){ 
                            Send-MailMessage -To $emailrecipients -From $From -Subject "$($site.SiteName) has quarantined RP files" -Body "$($rpQuaz.Name)<br><br>There are quarantined files that require attention.<br> Please investigate." -SmtpServer $smtp -BodyAsHtml
                            $LastEmail = $null
                        }   
                    }
                    else{
                        Write-Host "$countRPQuaz" -ForegroundColor Cyan
                    }

                }
                else{
                    Write-Host "$countRPQuazNew : all reprocessed!" -ForegroundColor Green
                    Send-MailMessage -To $emailrecipients -From $From -Subject "$($site.SiteName) reprocessed quarantined RP files" -Body "$($rpQuaz.Name)<br><br> Quarantined files were reprocessed. <br> This is an automated email." -SmtpServer $smtp -BodyAsHtml
                }
            }
            else{
                Write-Host "$countRPQuaz" -ForegroundColor Yellow    
            }
        }
        catch{
            Write-Host "[X]" -ForegroundColor Red
        }

        # transaction files
        Write-Host "Transaction count  - " -NoNewline
        try{
            $countRP = (Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\Retserv\Output\" | Where-Object -FilterScript {($_.Name -Match "RP") -and ($_.Extension -eq ".csv")}).Count

            if($countRP -gt 20){
                try{
                    $TranService = (Get-Service -Name 'NXGTran*' -ComputerName "$($site.BackOfficePCIPAddress)")
                    if($($TranService.Status) -eq 'Stopped'){
                        Start-Sleep -Seconds 2
                        $TranService.Start()
                        Write-Host "$countRP" -ForegroundColor Green
                        Send-MailMessage -To $emailrecipients -From $From -Subject "$($site.SiteName) has unprocessed RP files" -Body "There are '$countRP' files unprocessed <br> Please investigate." -SmtpServer $smtp -BodyAsHtml 
                    }
                    else{
                        $TranService.Stop()
                        Start-Sleep -Seconds 2
                        $TranService.Start()
                        Write-Host "$countRP" -ForegroundColor Green
                        Send-MailMessage -To $emailrecipients -From $From -Subject "$($site.SiteName) has unprocessed RP files" -Body "There are '$countRP' files unprocessed <br> Please investigate." -SmtpServer $smtp -BodyAsHtml 
                    }
                }
                catch{
                    Write-Host "$countRP" -ForegroundColor Red
                }
            }
            else{
                Write-Host "$countRP" -ForegroundColor Yellow
            }
        }
        catch{
            Write-Host "[X]" -ForegroundColor Red
        }

        # vbo files
        Write-Host "VBO count (up)     - " -NoNewline
        try{
            $countvbo = (Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\VBO\Up\").Count
            Write-Host "$countvbo" -ForegroundColor Yellow
        }
        catch{
            Write-Host "[X]" -ForegroundColor Red
        }

        # vbo dowm files
        Write-Host "VBO count (down)   - " -NoNewline
        try{
            $countvboDown = (Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\VBO\Down\" -Filter IBOS*.txt).Count
            Write-Host "$countvboDown" -ForegroundColor Yellow
        }
        catch{
            Write-Host "[X]" -ForegroundColor Red
        }
        
        # morrisons import check
        if($($site.Supplier) -eq 'M'){
            Write-Host "PreProcessing      - " -NoNewline
            $PreProcessing = (Get-ChildItem "\\$($site.BackOfficePCIPAddress)\c\Temp\NXG\Import\PreProcessing\").Count
            Write-Host "$PreProcessing" -ForegroundColor Yellow            
        }
        else{
            Write-Host "PreProcessing      - " -NoNewline
            Write-Host "N/A" -ForegroundColor Gray
        }

        # output to html
        $bodytext = @"
        $bodytext
        <tr>
            <td bgcolor=#619bf9><font color="white">$($site.SiteId)</font></td>
		    <td bgcolor=#619bf9><font color="white">$($site.SiteName)</font></td>
"@
        # total import count
        if($CountTotal -gt '5' -and $CountTotal -lt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="orange">$CountTotal</td>
"@
        }
        elseif($CountTotal -gt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$CountTotal</td>
"@            
        }
        else{
            $bodytext = @"
            $bodytext
            <td>$CountTotal</td>
"@
        }

        # quaz rp count
        if($countRPQuaz -gt '0'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$countRPQuaz</td>
"@
        }
        else{
            $bodytext = @"
            $bodytext
            <td>$countRPQuaz</td>
"@
        }

        # rp count
        if($countRP -gt '5' -and $countRP -lt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="orange">$countRP</td>
"@
        }
        elseif($countRP -gt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$countRP</td>
"@
        }
        else{
            $bodytext = @"
            $bodytext
            <td>$countRP</td>
"@
        }

        # vbo up count
        if($countvbo -gt '5' -and $countvbo -lt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="orange">$countvbo</td>
"@
        }
        elseif($countvbo -gt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$countvbo</td>
"@
        }
        else{
            $bodytext = @"
            $bodytext
            <td>$countvbo</td>
"@
        }
        # vbo down count
        if($countvboDown -gt '5' -and $countvboDown -lt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="orange">$countvboDown</td>
"@
        }
        elseif($countvboDown -gt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$countvboDown</td>
"@
        }
        else{
            $bodytext = @"
            $bodytext
            <td>$countvboDown</td>
"@
        }

        # pre-Processing
        if($PreProcessing -gt '5' -and $PreProcessing -lt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="orange">$PreProcessing</td>
"@
        }
        elseif($PreProcessing -gt '20'){
            $bodytext = @"
            $bodytext
            <td bgcolor="red">$PreProcessing</td>
"@
        }
        else{
            if($($site.Supplier) -ne 'M'){
                $bodytext = @"
                $bodytext
                <td>N/A</td>
"@
            }
            else{
                $bodytext = @"
                $bodytext
                <td>$PreProcessing</td>
"@
            }
        }
            # remove net use connection
            Write-Output " "
            net use \\$($site.BackOfficePCIPaddress) /delete | Out-Null
        }
    }

    # close off $bodytext variable with closing tages
    $date = Get-Date -Format 'dd-MMM-yy HH:mm'
    $bodytext = @"
    $bodytext
    </table>
<p>Last Updated: $date</p>
<meta http-equiv="refresh" content="60">
"@
    # output $bodytext variable to html file!
    $bodytext | Out-File '\\company-fs\DCGENERAL\PaulB\Monitor\ServiceMonitorTEST.html'

    # for each file do stuff
    $sitelist = Import-Csv "C:\Users\$env:username\Desktop\SiteList.csv" -Header 'siteId', 'count'

    foreach($site in $sitelist){

    $body = @{
        title = ""
        details = "Quarantine file(s) have been found at $($site.SiteId)" # change me
        customerRef = "None"
        siteId = "$($site.siteId)"
        assignedTo = "$env:username" # change me
        team = "FOURTHLINE" # change me
        received = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        scheduled = $false
        scheduledDuration = 12
        specifiedEnd = $false
        endDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ" 
        serviceGroup = ""
        incidentType = 0
        masterSymptom = 0
        subSymptom = 0
        chargeable = $false
        receivedFrom = "Internal Request"
        b2bVisible = $true
        sourceReference = ""
        sourceType = ""
        serialNumber = "0"
        siteAssetIndexId = 0
        priorityId = 1140
        product = "NA"
    }

    $resp = Invoke-WebRequest `
        -Uri 'https://calllogging.company.co.uk/modules/incidents/controller.aspx/OpenIncident' `
        -Method Post `
        -Body ($body | ConvertTo-Json) `
        -Headers @{
            "Accept" = 'application/json, text/plain, */*'
            "Accept-Language" = 'en-GB,en;q=0.5'
            "Accept-Encoding" = 'gzip, deflate, br'
            "Referer" = 'https://calllogging.company.co.uk/'
            "Content-Type" = 'application/json;charset=utf-8'
            "Pragma" = 'no-cache'
            "Cache-Control" = 'no-cache'
        } `
        -WebSession $Session

        Write-Host "Opening call for: " -NoNewline
        Write-Host "$($site.SiteId)" -ForegroundColor Green
    }
    Write-Host "Starting Sleep Cycle..." -ForegroundColor DarkCyan
    Start-Sleep -Seconds '3600'
}
