#!/bin/bash

# Create a list of services to check
services=("apache2" "mysql" "ssh" "nginx")

# Create HTML file to output - Apache2 default index location
output_file="/var/www/html/service_status.html"

# Start HTML file
cat << @EOF > $output_file
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Status Report</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .running {
            color: green;
        }
        .stopped {
            color: red;
        }
    </style>
</head>
<body>
    <h1>Service Status Report</h1>
    <table>
        <tr>
            <th>Service</th>
            <th>Status</th>
        </tr>
@EOF

# Check each service and add to HTML
for service in "${services[@]}"; do
    status=$(systemctl is-active $service 2>/dev/null)
    if [ "$status" = "active" ]; then
        status_class="running"
    else
        status_class="stopped"
    fi
    
    echo "        <tr>" >> $output_file
    echo "            <td>$service</td>" >> $output_file
    echo "            <td class=\"$status_class\">$status</td>" >> $output_file
    echo "        </tr>" >> $output_file
done

# Close HTML file
cat << @EOF >> $output_file
    </table>
</body>
</html>
EOF

echo "Service status report has been generated in $output_file"
