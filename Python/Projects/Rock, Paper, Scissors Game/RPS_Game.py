# Import random module to make the game random
import random
import os

# The options you're able to pick in the game
Clear = lambda: os.system('cls')
Options = ["rock", "paper", "scissors"]

# Create menu and read user response
Clear()
UserAnswer = input("""Welcome to my Rock, Paper, Scissor game
To play type either Rock, Paper or Scissor
""")

# Check validity of what user inputs
while UserAnswer not in Options:
    Clear()
    print(f"Selection '{UserAnswer}' is not valid")
    UserAnswer = input("""To play type either Rock, Paper or Scissor
""")
else:
    print("Game starting...")


# Picking a random choice from Options
RandOption = random.choice(Options)
print(f"""
Your choice: {UserAnswer}
Their Choice: {RandOption}
""")

# Bonus!!! Work out who won
# paper
if UserAnswer == "paper" and RandOption == "paper":
    print("You drew")
elif UserAnswer == "paper" and RandOption == "scissors":
    print("You lost")
elif UserAnswer == "paper" and RandOption == "rock":
    print("You won!")
# rock
elif UserAnswer == "rock" and RandOption == "paper":
    print("You lost")
elif UserAnswer == "rock" and RandOption == "scissors":
    print("You won!")
elif UserAnswer == "rock" and RandOption == "rock":
    print("You drew!")
# scissors
elif UserAnswer == "scissors" and RandOption == "paper":
    print("You won!")
elif UserAnswer == "scissors" and RandOption == "scissors":
    print("You drew")
elif UserAnswer == "scissors" and RandOption == "rock":
    print("You lost")