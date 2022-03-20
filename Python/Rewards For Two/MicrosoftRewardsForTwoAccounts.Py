# Microsoft Rewards for two accounts
import os
import time
import random
import requests
import json
import datetime
from selenium import webdriver


# config stuff #####################
AccountEmail = [
    "xxx-xxxxxxxx@hotmail.com"
]
AccountPword = [
    "xxxxxxxxxx"
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
    driver = webdriver.Edge("c:\\users\\paulf\\Desktop\\Drivers\\msedgedriver.exe")
    driver.get("https://www.bing.com/search?q=steam")
    time.sleep(5)
    driver.find_element_by_id("id_a").click()
    time.sleep(5)

    # log on user
    print("Logging on using email:", user)
    driver.find_element_by_id("i0116").send_keys(user)
    driver.find_element_by_id("idSIButton9").click()
    time.sleep(6) 

    # enter password
    driver.find_element_by_id ("i0118").send_keys(AccountPword[List])
    driver.find_element_by_id("idSIButton9").click()
    time.sleep(6)

    # click accept...
    driver.find_element_by_id("idSIButton9").click()
    time.sleep(6)

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

    # sign off
    driver.find_element_by_id("id_p").click()
    time.sleep(2)
    driver.find_element_by_class_name("id_link_text").click()
    print(" ")
    driver.close()
    time.sleep(10)

# finish off file with a line
f = open(("c:\\users\\paulf\\Desktop\\MSPoints\\Rewards.txt"), "a")
f.write("-===============================================================================-\n")
f.close()
