# Kubernetes Pod Restart Script

## Description

This PowerShell script automates the process of restarting multiple Kubernetes pods within a specified namespace. It reads pod names from a file and restarts each pod individually.

## Prerequisites

- PowerShell
- kubectl configured with access to your Kubernetes cluster
- Appropriate permissions to access the specified namespace and delete pods

## Usage

```powershell
.\RestartPods.ps1 -namespace <namespace> -filename <path_to_file>
```

## Parameters
- namespace (Mandatory): The Kubernetes namespace where the pods are located.
- filename (Mandatory): Path to the file containing the list of pod names to restart.

## File Format
The file should contain one pod name per line. Empty lines and whitespace are ignored.
Example pods.txt:
text
pod-name-1
pod-name-2
pod-name-3

## Features
1. Namespace Access Check: Verifies access to the specified namespace before proceeding.
2. Pod Restart: Restarts each pod listed in the input file.
3. Error Handling: Provides clear error messages for common issues (e.g., namespace access, file not found).
4. Colored Output: Uses color-coded console output for better readability.

## Functions
```Test-NamespaceAccess```
Checks if the script has access to the specified namespace.<br>
```Restart-Pod```
Restarts a single pod by deleting it, allowing Kubernetes to recreate it.<br>

## Error Handling
The script includes error handling for:
Inaccessible namespaces
Missing input files
Failed pod restarts

## Notes
Ensure you have the necessary permissions in your Kubernetes cluster before running this script.
Use caution when restarting pods in production environments.
The script assumes that deleting a pod will cause Kubernetes to automatically recreate it.

## Author
Paul Butler
