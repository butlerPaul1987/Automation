# Generate Secure String
## Generate_Secure_String.ps1
This was used as a method of passing a password to a script file, without the use of plaintext passwords. The files were then given certain permissions which meant only certain users could access/read them.

```powershell
# Encrypt the password to disk
$Credential.Password | ConvertFrom-SecureString | Out-File $AccountFile
```

Uses the ```convert-From-SecureString``` commandlet
