# Import random module to make the game random
import random
import os

# The options you're able to pick in the game
Guesses = 5
WrongGuesses = 1
RandNumber = random.randrange(0,100)

# Ask user for number
print("""
A command based number guessing game

You have 5 guesses to win!
""")
UserGuess = input(f"Enter your number: ")


# Game code
while 1:
    if WrongGuesses < Guesses:
        if UserGuess == RandNumber:
            print(f"{RandNumber} was correct! Well done!")
        else:
            print(f"{UserGuess} was incorrect")
            if int(UserGuess) < int(RandNumber):
                UserGuess = input(f"You're too low, Enter your guess [{WrongGuesses}/5]: ")
                WrongGuesses += 1
            elif int(UserGuess) > int(RandNumber):
                UserGuess = input(f"You're too high, Enter your guess [{WrongGuesses}/5]: ")
                WrongGuesses += 1
    else:
        break