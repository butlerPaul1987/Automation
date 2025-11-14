# Title:    Microsoft Rewards for two accounts
# Author:   Paul Butler
# Date:     24/09/2023 
# Desc:     Written as a replacement to MicrosoftRewards.py as this utilised Selenium3
#           which is no longer supported with msedge webdriver.

import random
import requests
import json
import datetime
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Function to perform the login
def perform_login(driver, user, password):
    print("Logging on using email:", user)
    driver.find_element(By.ID, "i0116").send_keys(user)
    driver.find_element(By.ID, "idSIButton9").click()
    time.sleep(5)
    driver.find_element(By.ID, "i0118").send_keys(password)
    driver.find_element(By.ID, "idSIButton9").click()
    time.sleep(5)
    driver.find_element(By.ID, "idSIButton9").click()
    time.sleep(5)

# Function to perform searches
def perform_searches(driver, user, words_list, RTime):
    search = 1
    StartPoints = driver.find_element(By.ID, "id_rc").text

    for word in words_list:
        GetRandTime = random.choice(RTime)
        url = f"https://www.bing.com/search?q={word}"
        print(f"[{search}/30] Searching: '{word}' for {user}")
        driver.get(url)
        search += 1
        time.sleep(GetRandTime)

    EndPoints = driver.find_element(By.ID, "id_rc").text
    return StartPoints, EndPoints

# Function to complete daily sets
def complete_daily_sets(driver, user, EndPoints):
    driver.get("https://rewards.bing.com/#daily-sets")

    for i in range(1, 4):
        card_xpath = f'//*[@id="daily-sets"]/mee-card-group[1]/div/mee-card[{i}]/div'
        
        try:
            wait = WebDriverWait(driver, 10)
            element = wait.until(EC.element_to_be_clickable((By.XPATH, card_xpath)))
            element.click()
            print(f"{user}: Completing daily set {i}")
            time.sleep(5)
        except Exception as e:
            print(f"Error while completing daily set {i}: {e}")

    setEndPoints = driver.find_element(By.XPATH, '//*[@id="balanceToolTipDiv"]/p/mee-rewards-counter-animation/span').text
    setEndPoints = setEndPoints.replace(',', '')
    Sumation = int(setEndPoints) - int(EndPoints)
    return Sumation

# Main script
if __name__ == "__main__":
    AccountEmail = ["mail@hotmail.com","mail2@outlook.com"]
    AccountPword = ["password1","password2"]
    RTime = [1.4, 2, 2.1, 2.2, 1.9]
    today = datetime.date.today()

    with open(r"c:\users\paulf\Desktop\MSPoints\Rewards.txt", "a") as file:
        edgeOption = webdriver.EdgeOptions()
        edgeOption.use_chromium = True
        edgeOption.add_argument('log-level=3')
        edgeOption.add_argument("start-maximized")
        edgeOption.binary_location = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

        for user, password in zip(AccountEmail, AccountPword):
            service = webdriver.EdgeService(r'c:\users\paulf\Desktop\Drivers\msedgedriver.exe')
            driver = webdriver.Edge(service=service, options=edgeOption)
            driver.get("https://www.bing.com/search?q=steam")
            driver.maximize_window()
            time.sleep(5)
            driver.find_element(By.ID, "id_a").click()
            time.sleep(5)

            perform_login(driver, user, password)

            randomlists_url = "https://www.randomlists.com/data/words.json"
            response = requests.get(randomlists_url)
            words_list = random.sample(json.loads(response.text)['data'], 30)

            StartPoints, EndPoints = perform_searches(driver, user, words_list, RTime)

            Sumation = complete_daily_sets(driver, user, EndPoints)

            Output = f"[{today}]: '{user}' has {EndPoints} points [Up {Sumation} points]"
            file.write(f"{Output}\n")

            driver.close()
            time.sleep(2)

        file.write("-===============================================================================-\n")
        exit()
