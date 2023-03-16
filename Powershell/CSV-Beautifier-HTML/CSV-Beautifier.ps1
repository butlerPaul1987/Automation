<#
    Title:  CSV Importer de-shitter
    Author: PButler
    Date:   16/03/2023
    
    Changes:

    Version:    Author:    Date:       Changes:
    --------    -------    -----       --------
    v1.0        PButler    16/03/23    Initial Build
#>

# Set vars
Set-Location -Path 'C:\Users\Paul.Butler\OneDrive - toob Limited\Desktop'
$File = 'servicedesktickets.csv'
$SetTime = Get-Date -Format 'HH:mm'
# end vars

$html = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Toob Test</title>
  <meta charset="utf-8">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Amatic+SC:wght@700&display=swap" rel="stylesheet">
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

  <style>
    h1 {
      font-family: 'Amatic SC', cursive;
    } 
    .jumbotron{
        background-color: #44475a;
        white-space: nowrap;
        color: white;
        align-items: center;
    }
  </style>
<!-- Icon for web page-->
<link rel = "icon" href = 
"https://www.toob.co.uk/wp-content/uploads/2019/10/Pink-Donut-150x150.png" 
        type = "image/x-icon">
</head>
<body>
  <script>
    $(document).ready(function() {
        $("#gfg").on("keyup", function() {
            var value = $(this).val().toLowerCase();
            $("#table tr").filter(function() {
                $(this).toggle($(this).text()
                .toLowerCase().indexOf(value) > -1)
            });
        });
    });
</script>
<!-- New Jumbotron container-->
<div class="container">
    <div class="jumbotron">
        <div class="container">
            <div class="row">
                <div class="col-9">
                    <h1 class="display-1">ServiceDesk - <small class="text-muted">Tickets</small></h1>
                </div>
                <div class="col">
                    <img src="https://www.toob.co.uk/wp-content/uploads/2019/11/Jade-toob-Logo-with-pink-strapline-Transparent-Back.png" width="200" height="150"/>
                </div>
            </div>
        </div>
    </div>
</div>
<!--  search box-->
<div class="container">
  <div class="row">
    <div class="col-10">
      <input id="gfg" type="text" 
      placeholder="Search here">
    </div>

    <div class="col align-self-start">
      <span class="badge rounded-pill bg-success">Connected: <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-emoji-smile-fill" viewBox="0 0 16 16">
        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zM7 6.5C7 7.328 6.552 8 6 8s-1-.672-1-1.5S5.448 5 6 5s1 .672 1 1.5zM4.285 9.567a.5.5 0 0 1 .683.183A3.498 3.498 0 0 0 8 11.5a3.498 3.498 0 0 0 3.032-1.75.5.5 0 1 1 .866.5A4.498 4.498 0 0 1 8 12.5a4.498 4.498 0 0 1-3.898-2.25.5.5 0 0 1 .183-.683zM10 8c-.552 0-1-.672-1-1.5S9.448 5 10 5s1 .672 1 1.5S10.552 8 10 8z"/>
      </svg></span>
    </div>
  </div>
</div>
<!-- table container-->
<div class="container">
    <table id = "table" class="table table-sm">
        <thead>
          <tr>
            <thead class="table-light">
                <th scope="col">Request ID</th>
                <th scope="col">Ticket Title</th>
                <th scope="col">Requester Name</th>
                <th scope="col">Assigned Technician</th>
                <th scope="col">Request Status</th>
            </thead>
          </tr>
        </thead>
        <tbody id ="table">
'@




$CSV = Import-Csv -Path $File -Delimiter '|' 

ForEach($Line in $CSV){

    $html = @"  
    $html  
          <tr>
            <th scope='row'>$($Line.'request ID')</th>
            <td>$($Line.'Ticket Title')</td>
            <td>$($Line.'Requester Name')</td>
            <td>$($Line.'Assigned Technician')</td>
            <td>$($Line.'Request Status')</td>
          </tr>
"@
}

$html = @"
    $html
        </tbody>
      </table>
    </div>
    <!-- EOF container-->
    <div class="container">
      <p>Last Updated: 15:13</p>  
    </div>
    <!-- switch for something-->
    <div class="container">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-emoji-smile" viewBox="0 0 16 16">
        <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
        <path d="M4.285 9.567a.5.5 0 0 1 .683.183A3.498 3.498 0 0 0 8 11.5a3.498 3.498 0 0 0 3.032-1.75.5.5 0 1 1 .866.5A4.498 4.498 0 0 1 8 12.5a4.498 4.498 0 0 1-3.898-2.25.5.5 0 0 1 .183-.683zM7 6.5C7 7.328 6.552 8 6 8s-1-.672-1-1.5S5.448 5 6 5s1 .672 1 1.5zm4 0c0 .828-.448 1.5-1 1.5s-1-.672-1-1.5S9.448 5 10 5s1 .672 1 1.5z"/>
      </svg>
    </div>
</body>
</html>
"@

$html | Out-File .\index_new.html 
