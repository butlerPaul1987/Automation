# importing modules
import pyautogui
import time
import os

# shell size
os.system("mode con cols=30 lines=20")
now = time.strftime("%H", time.localtime())

print("SupportWorks logger:")
if now < "12":
    print("Good Morning, Paul")
else:
    print("Good Afternoon, Paul. ")

# set pyautogui to p
p = pyautogui

print("     Starting: SupportWorks")
# open and do stuff with SupportWorks
try:
    #os.startfile("C:\\Users\\pb001\\AppData\\Roaming\\Hornbill\\Supportworks Client 8.2.1\\swcli8.exe")
    p.moveTo(610,1055, duration=1)
    p.click(610,1055)
    time.sleep(2)
    p.typewrite("########!\n")
    time.sleep(5)
    p.moveTo(200,580, duration=2)
    p.click(200,580)
except:
    print("Unable to load ServiceDesk")


# start chrome
print("     Starting: Google Chrome")
try:
    os.startfile("Chrome.exe")

except:
    print("Unable to load Chrome")

"""
# start Teams
print(" Starting: Microsoft Teams")
try:
    p.moveTo(759,1059, duration= 2)
    p.click(759,1059)
    time.sleep(1)

    # hope it's full screen and send a message
    p.moveTo(33,187, duration=2) # click on teams
    p.click(33,187)

    p.moveTo(162,193, duration=2) # click on general
    p.click(162,193)

    p.click(808,977) # click on message box
    if now > "11":
        p.typewrite("Afternoon, all!", interval=0.15)
        #p.press('enter')
    else:
        p.typewrite("Morning, all!", interval=0.15)
        #p.press('enter')            
except:
    print("Unable to load Teams")
"""
