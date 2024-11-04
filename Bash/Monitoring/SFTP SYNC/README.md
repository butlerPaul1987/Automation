# Mems_sftpsync.sh

## Description
This Bash script monitors and verifies the synchronization of files across two instances using MD5 checksums.

## Author
Paul Butler

## Date
31/03/2023

## Features
- Generates MD5 checksums for files on two different instances
- Compares the checksums to ensure file synchronization
- Provides a status output indicating whether the files are in sync or not

## Usage
1. Ensure the script has execute permissions:
```
chmod +x Mems_sftpsync.sh
```
2. Run the script:
```
./Mems_sftpsync.sh
```

## Requirements
- Bash shell
- SSH access to the remote instance (mcp02)
- Proper file permissions to read and write in the specified directories

## Script Workflow
1. Generates MD5 checksums for files in `/home/location/location/location/location/*.sef` on the local instance (mcp01)
2. Generates MD5 checksums for files in the same directory on the remote instance (mcp02)
3. Compares the MD5 checksums between the two instances
4. Outputs a status file with the following information:
- SFTP_STATUS: Either "WARNING" or "NORMAL"
- SFTP_REASON: Explanation of the status
- LASTCHECK: Timestamp of the last check

## Output
The script generates a status file with the following format:
