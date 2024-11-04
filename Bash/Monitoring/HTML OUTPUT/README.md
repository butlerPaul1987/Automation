# Service Status Checker

## Description

This Bash script generates an HTML report of the status of specified services on a Linux system. It checks the status of Apache2, MySQL, SSH, and Nginx services and creates a visually appealing HTML page with the results.

## Features

- Checks the status of multiple services
- Generates an HTML report with a styled table
- Uses color coding for easy status identification (green for running, red for stopped)
- Automatically places the report in the default Apache2 web directory

## Requirements

- Bash shell
- systemd (for using systemctl commands)
- Apache2 web server (for serving the HTML report)

## Usage

1. Make the script executable:
```
chmod +x service_status_checker.sh
```
2. Run the script with root privileges:
```
sudo ./service_status_checker.sh
```

3. The script will generate an HTML report at `/var/www/html/service_status.html`

4. View the report by navigating to `http://your-server-ip/service_status.html` in a web browser

## Customization

- To add or remove services from the check list, modify the `services` array in the script.
- The output file location can be changed by modifying the `output_file` variable.
- The HTML styling can be adjusted by modifying the CSS in the script.

## Notes

- Ensure that Apache2 is running and properly configured to serve files from `/var/www/html/`
- The script must be run with sufficient privileges to check service statuses (typically root)

## Author

Paul Butler

## Version

1.0

## Last Updated

04/11/2024
