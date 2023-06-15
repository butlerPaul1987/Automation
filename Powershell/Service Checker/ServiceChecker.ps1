$Services = Get-Service | Where-Object { $_.Name -match 'searchterm' }


$html = @"
<!DOCTYPE html>
<html>
    <head>
        <style>
            @import url('https://fonts.googleapis.com/css?family=Space+Mono');

            :root {
            --nice-cyan: #00b9ae;
            --nice-magenta: #ee1d7a;
            }

            body {
                background-color: var(--nice-cyan);
            }

            img {
                background-image: 
                radial-gradient(
                    circle,
                    white 1%,
                    var(--nice-cyan) 75%,
                    var(--nice-cyan) 100%
                );
            }

            h1, h2 {
                font-family: 'Space Mono';
            }

            .header {
                display: flex;
                justify-content: space-around;
            }

            .header h1 {
                padding: 70px 0;
            }

            #services {
                font-family: 'Space Mono';
                border-collapse: collapse;
                width: 100%;
            }
            
            #services td, #services th {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: center;
            }
            
            #cusservicestomers tr:nth-child(even){background-color: #f2f2f2;}
            
            #services tr:hover {background-color: #ddd;}

            #services th {
                padding-top: 12px;
                padding-bottom: 12px;
                background-color: var(--nice-magenta);
                color: white;
            }
        </style>
    </head>
    <body>
        <!-- header section-->
        <section class="header">
            <h1>company: Netadmin Service Checker
            </h1>
            <img src="assets/company.png">
        </section>

        
        <!-- section-->
        <section class="tablesection">
            <div class="tablediv">
                <h2>Service List:</h2>
                <table id="services">
                    <tr>
                        <th>Name:</th>
                        <th>Status</th>
                        <th>Last Checked</th>
                    </tr>
"@

ForEach($Service in $Services){
    $Date = Get-Date -Format 'hh:mm dd/MM/yy'
    $html = $html + @"
                    <tr>
                        <td>$($Service.DisplayName)</td>
                        <td>$($Service.Status)</td>
                        <td>$Date</td> 
                    </tr>
"@               
}

$html = $html + @"
                </table>
            </div>
        </section>      
    </body>
</html>
"@

$html | Out-File -FilePath 'C:\company\SSL\index.html' 
