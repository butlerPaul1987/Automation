# Title:    Microsoft Rewards for two accounts
# Author:   Paul Butler
# Date:     24/09/2023 
# Desc:     Written as a replacement to MicrosoftRewards.py as this utilised Selenium3
#           which is no longer supported with msedge webdriver.

# import modules
# selenium
from selenium import webdriver
from selenium.webdriver.edge import service
from selenium.webdriver.common.by import By
import os

# import random json list
import random
import requests
import json

# time/date based
import datetime
import time

# config section #####################
AccountEmail = [
    "user1@email.com",
    "user2@email.com"
]
AccountPword = [
    "pass1",
    "pass2"
]
RTime = [
    1.4,2,2.1,2.2,1.9
]
List = 0
StartPoints = []
EndPoints = []
today = datetime.date.today()
# end config section #####################


# script block -------------------------
for user in AccountEmail:
    # add randomised search
    randomlists_url = "https://www.randomlists.com/data/words.json"
    response = requests.get(randomlists_url)
    words_list = random.sample(json.loads(response.text)['data'], 30)

    # Opens Edge webdriver
    edgeOption = webdriver.EdgeOptions()
    edgeOption.use_chromium = True
    edgeOption.add_argument("start-maximized")
    edgeOption.binary_location = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    s=service.Service(r'c:\users\paulf\Desktop\Drivers\msedgedriver.exe')
    driver = webdriver.Edge(service=s, options=edgeOption)

    driver.get("https://www.bing.com/search?q=steam")
    driver.maximize_window()
    time.sleep(5)
    # driver.find_element_by_id("id_a").click() --deprecated method (use below)
    driver.find_element(By.ID,"id_a").click()
    time.sleep(5)

    # log on user
    print("Logging on using email:", user)
    #driver.find_element_by_id("i0116").send_keys(user) --deprecated method (use below)
    driver.find_element(By.ID,"i0116").send_keys(user)
    #driver.find_element_by_id("idSIButton9").click() --deprecated method (use below)
    driver.find_element(By.ID,"idSIButton9").click()
    time.sleep(5) 

    # enter password
    #driver.find_element_by_id ("i0118").send_keys(AccountPword[List]) --deprecated method (use below)
    driver.find_element(By.ID,"i0118").send_keys(AccountPword[List])
    #driver.find_element_by_id("idSIButton9").click() --deprecated method (use below)
    driver.find_element(By.ID,"idSIButton9").click()
    List = List + 1
    time.sleep(5)

    # click accept...
    #driver.find_element_by_id("idSIButton9").click() --deprecated method (use below)
    driver.find_element(By.ID,"idSIButton9").click()
    time.sleep(5)

    # search 30 times
    search = 1
    driver.get("https://www.bing.com/search?q=qwerty")
    time.sleep(5)
    #StartPoints = driver.find_element_by_id("id_rc").text --deprecated method (use below)
    StartPoints = driver.find_element(By.ID,"id_rc").text

    for word in words_list:
        GetRandTime = random.choice(RTime)
        url = f"https://www.bing.com/search?q={word}"
        print(f"[{search}/30] Searching: '{word}' for {user}")
        driver.get(url)
        search = search + 1
        time.sleep(GetRandTime)

    # get deets of reward points count
    #EndPoints = driver.find_element_by_id("id_rc").text --deprecated method (use below) 
    EndPoints = driver.find_element(By.ID,"id_rc").text
    Sum = int(EndPoints) - int(StartPoints)
    Output = f"[{today}]: '{user}' has {EndPoints} points [Up {Sum} points]"

    # output to file
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
# end script block ---------------------
