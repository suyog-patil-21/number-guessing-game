#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_GAME_INFO=$($PSQL "SELECT * FROM game WHERE username LIKE '$USERNAME'")

if [[ -z $USER_GAME_INFO ]] 
then
    USER_INSERT_RESULT=$($PSQL "INSERT INTO game(username) VALUES ('$USERNAME')")
    USER_GAME_INFO=$($PSQL "SELECT * FROM game WHERE username LIKE '$USERNAME'")
    USER_ID=$(echo "$USER_GAME_INFO" | cut -d '|' -f1)
    GAME_PLAYED=$(echo "$USER_GAME_INFO" | cut -d '|' -f3)
    BEST_GAME=$(echo "$USER_GAME_INFO" | cut -d '|' -f4)
    echo  "Welcome, $USERNAME! It looks like this is your first time here."
else
    USER_ID=$(echo "$USER_GAME_INFO" | cut -d '|' -f1)
    GAME_PLAYED=$(echo "$USER_GAME_INFO" | cut -d '|' -f3)
    BEST_GAME=$(echo "$USER_GAME_INFO" | cut -d '|' -f4)
    echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
GUESS_COUNT=0
until [[ $USER_GUESS -eq $RANDOM_NUMBER ]]
do
    read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
    else
        (( GUESS_COUNT+=1 ))
        if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
        then 
            echo "It's lower than that, guess again:"
        elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
        else 
            (( GAME_PLAYED +=1 ))
            if [[  ( $BEST_GAME -eq 0 ) || ( $GUESS_COUNT -gt 0 && $GUESS_COUNT -lt $BEST_GAME ) ]] 
            then 
                UPDATE_USER_RESULT=$($PSQL "UPDATE game SET games_played = $GAME_PLAYED, best_game_guess=$GUESS_COUNT WHERE user_id=$USER_ID")
            else
                UPDATE_USER_RESULT=$($PSQL "UPDATE game SET games_played = $GAME_PLAYED WHERE user_id=$USER_ID")
            fi
            echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
        fi
    fi
done

