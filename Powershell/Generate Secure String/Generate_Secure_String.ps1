<#
    .SYNOPSIS
        Secure String Generation
    .NOTES
        Adapted from: https://github.com/bakingclouds/PostgreSQL/blob/master/Backup-PostgreSQL-DB.ps1
    .DESCRIPTION
        Generates a secured string file for password required files
    .OUTPUTS
        The outputs created are:
            file:     Account.User.pwd
            location: $env:HOMEPATH\
    .INPUTS
        N/A
    .NOTES
        Version:        1.0
        Author:         PButler
        Creation Date:  27/01/2022
        Purpose/Change: Initial script 
#>

Function CreateSecureString{
    $AccountFile = "$env:HOMEPATH\Account.User.pwd"

    # Check for password file
        if ((Test-Path $AccountFile) -eq "True") {
        Write-Host "The file $AccountFile exist. Skipping credential request"
    }
    else {
        Write-Host ("The value $AccountFile not found," +
        " creating credentials file.")

        # get creds
        $Credential = Get-Credential

        # Encrypt the password to disk
        $Credential.Password | ConvertFrom-SecureString | Out-File $AccountFile
    }
}

Export-ModuleMember -Function 'CreateSecureString'
