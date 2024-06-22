#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_GAME_INFO=$($PSQL "SELECT * FROM game WHERE username LIKE '$USERNAME'")

if [[ -z $USER_GAME_INFO ]] 
then
    USER_INSERT_RESULT=$($PSQL "INSERT INTO game(username) VALUES ('$USERNAME')")
    USER_GAME_INFO=$($PSQL "SELECT * FROM game WHERE username LIKE '$USERNAME'")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
    USER_ID=$(echo "$USER_GAME_INFO" | cut -d '|' -f1)
    GAME_PLAYED=$(echo "$USER_GAME_INFO" | cut -d '|' -f3)
    BEST_GAME=$(echo "$USER_GAME_INFO" | cut -d '|' -f4)
    echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi
