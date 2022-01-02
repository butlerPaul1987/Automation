# Python-Creations

## MicrosoftRewardsForTwoAccounts.py
Just an easy way to get 90 points for MicrosoftRewards, this will perform the following options:
---
1. Open up Bing using a web browser 
2. ForEach user selected (there can be as many as you'd like, although I can see limitations with larger numbers)
3. There is a search using a JSON website search (30 words returned)
5. It will log on with a username and password
4. For each of the items returned it will perform a search 
6. It will output a comment on a document which will document the following:
	```	
	Today	 : The date in American format
	UserName : The email being used
	EndPoints: This is the points after all searches
	Sum      : This is the total sum of points gained today.
	```
```python
Sum = int(EndPoints) - int(StartPoints)
Output = f"[{today}]: '{user}' has {EndPoints} points [Up {Sum} points]"
```

After each session it will close and restart the session.

You'll need to run (in order): 
1. Open preferred CLI (Powershell/CMD) and run: 
```powershell
	Set-Location "C:\Users\$env:username\Desktop\" 
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/butlerPaul1987/Automation/main/Python/Rewards%20For%20Two/Requirments.txt" -OutFile requirements.txt
```
3. When this has downloaded run ```py -m pip install -r requirements.txt``` 
4. Then run the next sequence of commands:
- Download WebDriver / create directory: 
```powershell
if(!(Test-Path "C:\Users\$env:username\Desktop\Drivers\")){ 
	New-Item -Path "C:\Users\$env:username\Desktop\Drivers\" -ItemType Directory | Out-Null 
}  
Invoke-WebRequest -Uri "https://msedgedriver.azureedge.net/96.0.1054.62/edgedriver_win64.zip" -OutFile .\Drivers\edgedriver.zip
```
- Unzip webdriver: 
```powershell
Expand-Archive -Path .\Drivers\edgedriver.zip -DestinationPath "C:\Users\$env:username\Desktop\Drivers\"
```




