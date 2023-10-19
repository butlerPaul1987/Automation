# Microsoft Rewards Automation Script

## Overview

This Python script is designed to automate Microsoft Rewards activities, such as daily searches and completing daily sets, for two user accounts. It uses the Selenium library for web automation.

### Author

- Author: Paul Butler
- Date: 24/09/2023

## Prerequisites

Before using the script, ensure you have the following prerequisites:

1. Python installed on your system.
2. Selenium library installed. You can install it using `pip install selenium`.
3. Microsoft Edge browser installed.
4. Microsoft Edge WebDriver (msedgedriver.exe) placed in a directory and referenced in the script.

## Instructions

1. **Script Configuration**:

   - Open the script using a text editor or Python IDE.
   - Modify the `AccountEmail` and `AccountPword` lists with the email addresses and passwords for your Microsoft Rewards accounts.
   - Adjust the `RTime` list to specify random search time intervals in seconds.
   - Set the path for the `Rewards.txt` file where the script will log the results.

2. **Webdriver Configuration**:

   - Ensure the script is configured to use the Microsoft Edge browser. Update the paths to the Edge browser executable and WebDriver if necessary.

3. **Running the Script**:

   - Save your changes to the script.
   - Open a terminal or command prompt.
   - Navigate to the directory where the script is located.
   - Run the script using the command: `python script_name.py` (replace `script_name.py` with the actual script filename).

4. **Script Execution**:

   - The script will open Microsoft Edge and automate the login process for each user account.
   - It will perform searches on random words and log the start and end points.
   - The script will then complete the daily sets and log the points earned.
   - The results will be logged in the specified `Rewards.txt` file.

5. **Logging**:

   - The script will log the results for each account with a timestamp in the `Rewards.txt` file.
   - A separator line is added to separate results for different runs.

## Notes

- Ensure you have a stable internet connection while running the script.
- Microsoft may update its website structure, which could break the script. Check for script updates or make necessary adjustments if this happens.

By following these instructions, you can automate Microsoft Rewards activities for your accounts using the provided Python script.

