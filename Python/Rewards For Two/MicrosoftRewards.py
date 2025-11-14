"""
Microsoft Rewards Automation (2025)
Includes:
 - Login with retry
 - Desktop searches
 - Mobile searches (Android UA)
 - Daily sets
 - Quiz automation (This or That, 3-question quiz)
 - Automatic retry / tab cleanup
"""

import time, random, json, datetime, requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import *
from selenium.webdriver.common.keys import Keys

# -------------------------------------------------------------------
# COMMON UTILITIES
# -------------------------------------------------------------------

def retry(action, attempts=3, delay=2):
    """Retry wrapper for any Selenium action."""
    for attempt in range(attempts):
        try:
            return action()
        except Exception as e:
            if attempt == attempts - 1:
                print(f"[ERROR] Final failed attempt: {e}")
                return None
            print(f"[WARN] Retry in {delay}s → {e}")
            time.sleep(delay)


def safe_click(driver, xpath, timeout=12):
    """Click element if clickable; return True if succeeded."""
    def attempt():
        elem = WebDriverWait(driver, timeout).until(EC.element_to_be_clickable((By.XPATH, xpath)))
        elem.click()
        return True
    return retry(attempt)


def close_extra_tabs(driver):
    """Close any tab that isn't the first."""
    while len(driver.window_handles) > 1:
        driver.switch_to.window(driver.window_handles[-1])
        driver.close()
        driver.switch_to.window(driver.window_handles[0])

# -------------------------------------------------------------------
# LOGIN (with retry)
# -------------------------------------------------------------------

def perform_login(driver, email, password):
    print(f"Logging in: {email}")

    def enter_email():
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.ID, "i0116"))
        ).send_keys(email)
        driver.find_element(By.ID, "idSIButton9").click()

    retry(enter_email)

    def enter_pass():
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.ID, "i0118"))
        ).send_keys(password)
        driver.find_element(By.ID, "idSIButton9").click()

    retry(enter_pass)

    # Stay signed in
    try:
        WebDriverWait(driver, 12).until(
            EC.element_to_be_clickable((By.ID, "idSIButton9"))
        ).click()
    except:
        pass

    time.sleep(2)

# -------------------------------------------------------------------
# SEARCHES
# -------------------------------------------------------------------

def perform_searches(driver, user, words_list, RTime, mode="Desktop"):
    print(f"--- {user} → {mode} searches start ---")

    for i, word in enumerate(words_list, start=1):
        def do_search():
            driver.get(f"https://www.bing.com/search?q={word}")

        retry(do_search)
        print(f"[{i}/{len(words_list)}] {mode}: {word}")
        time.sleep(random.choice(RTime))

    print(f"--- {user} → {mode} searches done ---")

# -------------------------------------------------------------------
# QUIZ AUTOMATION
# -------------------------------------------------------------------

def do_this_or_that(driver):
    """Automate ‘This or That’ quiz."""
    print("Solving 'This or That'...")

    for _ in range(10):  # usually 10 items
        try:
            options = driver.find_elements(By.XPATH, "//div[@class='bt_option']")
            random.choice(options).click()
            time.sleep(1.2)
        except:
            break
    print("This or That complete.")


def do_three_question_quiz(driver):
    """Automate 3-question quiz."""
    print("Solving 3-question quiz...")

    for _ in range(3):
        try:
            options = driver.find_elements(By.XPATH, "//button[contains(@class,'rqOption')]")
            random.choice(options).click()
            time.sleep(1)
            next_btn = driver.find_element(By.XPATH, "//button[contains(@id,'rqNext')]")
            next_btn.click()
            time.sleep(1.5)
        except:
            break

    print("3-Question quiz complete.")

# -------------------------------------------------------------------
# DAILY SETS + QUIZZES
# -------------------------------------------------------------------

def complete_daily_sets(driver, user):
    print(f"{user}: Completing daily sets...")
    driver.get("https://rewards.bing.com")
    time.sleep(4)

    cards = driver.find_elements(By.XPATH, "//mee-card[contains(@class,'daily-set-card')]")

    for idx, card in enumerate(cards, start=1):
        try:
            driver.execute_script("arguments[0].scrollIntoView();", card)
            card.click()
            time.sleep(4)

            if len(driver.window_handles) > 1:
                driver.switch_to.window(driver.window_handles[-1])
                time.sleep(4)

                # Decide quiz type
                page_src = driver.page_source.lower()

                if "this or that" in page_src:
                    do_this_or_that(driver)
                elif "multiple choice" in page_src or "rqQuestionState" in page_src:
                    do_three_question_quiz(driver)

                close_extra_tabs(driver)

        except Exception as e:
            print(f"[WARN] Could not complete daily card {idx}: {e}")

    print(f"{user}: Daily sets complete.")

# -------------------------------------------------------------------
# DRIVER SETUP
# -------------------------------------------------------------------

def create_driver(driver_path, mobile=False):
    options = webdriver.EdgeOptions()

    options.add_argument("start-maximized")
    options.add_argument("log-level=3")

    if mobile:
        options.add_argument(
            "user-agent=Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/122 Mobile Safari/537.36"
        )
        print("Mobile driver created.")

    return webdriver.Edge(driver_path, options=options)

# -------------------------------------------------------------------
# MAIN SCRIPT
# -------------------------------------------------------------------

if __name__ == "__main__":

    ACCOUNTS = [
        ("mail@hotmail.com", "password1"),
        ("mail2@outlook.com", "password2")
    ]

    RTime = [1.4, 1.8, 2.0, 2.3, 2.6]
    today = datetime.date.today()
    log_file = r"c:\users\paulf\Desktop\MSPoints\Rewards.txt"
    driver_path = r"c:\users\paulf\Desktop\Drivers\msedgedriver.exe"

    for email, pw in ACCOUNTS:

        # 1) Desktop session
        driver = create_driver(driver_path)
        driver.get("https://www.bing.com/search?q=start")
        time.sleep(3)

        safe_click(driver, '//*[@id="id_a"]')
        perform_login(driver, email, pw)

        # Get 30 random words
        words = json.loads(requests.get("https://www.randomlists.com/data/words.json").text)['data']
        desktop_words = random.sample(words, 30)

        perform_searches(driver, email, desktop_words, RTime, mode="Desktop")

        complete_daily_sets(driver, email)

        driver.quit()

        # 2) Mobile session
        driver_mobile = create_driver(driver_path, mobile=True)
        driver_mobile.get("https://www.bing.com")
        time.sleep(2)

        safe_click(driver_mobile, '//*[@id="mHamburger"]')
        safe_click(driver_mobile, '//a[contains(@href,"login")]')

        perform_login(driver_mobile, email, pw)

        mobile_words = random.sample(words, 20)
        perform_searches(driver_mobile, email, mobile_words, RTime, mode="Mobile")

        driver_mobile.quit()

        # Logging
        with open(log_file, "a") as f:
            f.write(f"[{today}] {email} — Desktop + Mobile searches & quizzes done.\n")

    with open(log_file, "a") as f:
        f.write("-" * 80 + "\n")

    print("ALL ACCOUNTS COMPLETE.")
