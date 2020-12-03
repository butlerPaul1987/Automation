import pyautogui
import time

answer = input("""

    Please select one from the following options:

    1. 192.168.8.19 - InterAction
    2. 192.168.8.22 - TikitConnect
    3. 192.168.8.17 - SQL Server

""")

p = pyautogui

p.click(854,1055)
p.click(868,205, duration=1)

if answer == 1:
    p.press('delete')
    p.typewrite("192.168.8.19")
    p.press('enter')
elif answer == 2:
    p.press('delete')
    p.typewrite("192.168.8.22")
    p.press('enter')
elif answer == 3:
    p.press('delete')
    p.typewrite("192.168.8.22")
    p.press('enter')
else:
    print("Incorrect selection made")
    

time.sleep(2)
p.typewrite("######!", interval=0.25)
p.press('enter')


