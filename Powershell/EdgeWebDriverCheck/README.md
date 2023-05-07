# Edge WebDriver Check
### EdgeWebDriverCheck.ps1

This was written as I was using Python and Selenium to scrape data to then be imported into Influx.. which then went to Grafana.

python/selenium > influx > grafana

An issue I had quite often, was that the version of Edge I was using would often be newer than the webdriver version I had installed, which would cause issues.

To mitigate this, if I had errors in any overnight logs. I would run this script which would resolve it for me
