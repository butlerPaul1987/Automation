# Title:    Microsoft Rewards for two accounts
# Author:   Paul Butler
# Date:     24/09/2023 
# Desc:     Written as a replacement to MicrosoftRewards.py as this utilised Selenium3
#           which is no longer supported with msedge webdriver.

# module imports
from selenium import webdriver
from selenium.webdriver.edge import service
from selenium.webdriver.common.by import By
import os
import random
import requests
import json
import datetime
import time

# config section 
AccountEmail = ["email1@email.com","email2@email.com"]
AccountPword = ["pass1","pass2"]
RTime = [1.4,2,2.1,2.2,1.9]
List = 0
StartPoints = []
EndPoints = []
today = datetime.date.today()


for user in AccountEmail:
    # add randomised search
    randomlists_url = "https://www.randomlists.com/data/words.json"
    response = requests.get(randomlists_url)
    words_list = random.sample(json.loads(response.text)['data'], 30)

    # Opens Edge webdriver
    edgeOption = webdriver.EdgeOptions()
    edgeOption.use_chromium = True
    edgeOption.add_argument('log-level=2')      # 0: INFO / 1: WARNING / 2: LOG_ERROR / 3: LOG_FATAL #
    edgeOption.add_argument("start-maximized")
    edgeOption.binary_location = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    s=service.Service(r'c:\users\paulf\Desktop\Drivers\msedgedriver.exe')
    driver = webdriver.Edge(service=s, options=edgeOption)
    driver.get("https://www.bing.com/search?q=steam")
    driver.maximize_window()
    time.sleep(5)
    driver.find_element(By.ID,"id_a").click()
    time.sleep(5)

    # log on user
    print("Logging on using email:", user)
    driver.find_element(By.ID,"i0116").send_keys(user)
    driver.find_element(By.ID,"idSIButton9").click()
    time.sleep(5) 

    # enter password
    driver.find_element(By.ID,"i0118").send_keys(AccountPword[List])
    driver.find_element(By.ID,"idSIButton9").click()
    List = List + 1
    time.sleep(5)

    # click accept...
    driver.find_element(By.ID,"idSIButton9").click()
    time.sleep(5)

    # load bing (engine you need for this)
    search = 1
    driver.get("https://www.bing.com/search?q=qwerty")
    time.sleep(5)
    StartPoints = driver.find_element(By.ID,"id_rc").text
    
    # search 30 times
    for word in words_list:
        GetRandTime = random.choice(RTime)
        url = f"https://www.bing.com/search?q={word}"
        print(f"[{search}/30] Searching: '{word}' for {user}")
        driver.get(url)
        search = search + 1
        time.sleep(GetRandTime)

    # get deets of reward points count
    EndPoints = driver.find_element(By.ID,"id_rc").text
    Sum = int(EndPoints) - int(StartPoints)
    Output = f"[{today}]: '{user}' has {EndPoints} points [Up {Sum} points]"

    # output to file
    f = open(("c:\\users\\paulf\\Desktop\\MSPoints\\Rewards.txt"), "a")
    f.write(f"{Output}\n")
    f.close()

    # get daily sets :)
    driver.get("https://rewards.bing.com/#daily-sets")
    # select card 1
    driver.find_element(By.XPATH,'//*[@id="daily-sets"]/mee-card-group[1]/div/mee-card[1]/div').click()
    print(f"{user}: Completing daily set 1")
    time.sleep(5)

    # select card 2
    driver.find_element(By.XPATH,'//*[@id="daily-sets"]/mee-card-group[1]/div/mee-card[2]/div').click()
    print(f"{user}: Completing daily set 2")
    time.sleep(5)

    # select card 3
    driver.find_element(By.XPATH,'//*[@id="daily-sets"]/mee-card-group[1]/div/mee-card[3]/div').click()
    print(f"{user}: Completing daily set 3")
    time.sleep(5)

    # output data
    setEndPoints = driver.find_element(By.XPATH, '//*[@id="balanceToolTipDiv"]/p/mee-rewards-counter-animation/span').text
    setEndPoints = setEndPoints.replace(',','')
    Sumation = int(setEndPoints) - int(EndPoints)
    Output = f"[{today}]: '{user}' has [30/30] searches and completed [3/3] daily set points [Up {Sumation} points]"
    f = open(("c:\\users\\paulf\\Desktop\\MSPoints\\Rewards.txt"), "a")
    f.write(f"{Output}\n")
    f.close()

    # sign off
    driver.close()
    time.sleep(2)

# finish off file with a line
f = open(("c:\\users\\paulf\\Desktop\\MSPoints\\Rewards.txt"), "a")
f.write("-===============================================================================-\n")
f.close()
exit()
