# Microsoft Rewards for two accounts
import os
import time
import random
import requests
import json
import datetime
from selenium import webdriver

# before doing anything. perform random sleep time
BeforeYouStart = [
    600, 505.1, 666.2, 60, 100, 150.2
]
SleepTimer = random.choice(BeforeYouStart)
time.sleep(SleepTimer)

# config stuff #####################
AccountEmail = [
    "xxx-xxxxx@hotmail.com", 
    "xxxxxxx@hotmail.com"
]
AccountPword = [
    "xxxxxxxx", 
    "xxxxxxxx!"
]
RTime = [
    3.7,4,4.1,4.4,4.5,5,6.1,7,7.9,8,8.3,8.5
]
List = 0
StartPoints = []
EndPoints = []
today = datetime.date.today()
randomlists_url = "https://www.randomlists.com/data/words.json"
response = requests.get(randomlists_url)
words_list = random.sample(json.loads(response.text)['data'], 30)
# end config stuff #####################

for user in AccountEmail:
    driver = webdriver.Edge("c:\\users\\pb001\\Desktop\\Drivers\\msedgedriver.exe")
    driver.get("https://login.live.com/")
    time.sleep(6)

    # enter username
    print("Logging on using email:", user)
    driver.find_element_by_id("i0116").send_keys(user)
    driver.find_element_by_id("idSIButton9").click()
    time.sleep(6) 

    # enter password
    driver.find_element_by_id ("i0118").send_keys(AccountPword[List])
    driver.find_element_by_id("idSIButton9").click()
    time.sleep(6)
    List = List + 1

    # search 30 times
    search = 1
    driver.get("https://www.bing.com/search?q=steam")
    time.sleep(10)
    driver.get("https://www.bing.com/search?q=steam")
    time.sleep(10)
    StartPoints = driver.find_element_by_id("id_rc").text

    for word in words_list:
        GetRandTime = random.choice(RTime)
        url = f"https://www.bing.com/search?q={word}"
        print(f"[{search}/30] Searching: '{word}' for {user}")
        driver.get(url)
        search = search + 1
        time.sleep(GetRandTime)

    # get deets of reward points count
    EndPoints = driver.find_element_by_id("id_rc").text
    Sum = int(EndPoints) - int(StartPoints)
    Output = f"[{today}]: '{user}' has {EndPoints} points [Up {Sum} points]"

    # output to file
    f = open(("c:\\users\\pb001\\Desktop\\Rewards.txt"), "a")
    f.write(f"{Output}\n")
    f.close()

    # sign off
    driver.find_element_by_id("id_p").click()
    time.sleep(2)
    driver.find_element_by_class_name("id_link_text").click()
    print(" ")
    driver.close()
    time.sleep(10)

# finish off file with a line
f = open(("c:\\users\\pb001\\Desktop\\Rewards.txt"), "a")
f.write("-===============================================================================-\n")
f.close()
