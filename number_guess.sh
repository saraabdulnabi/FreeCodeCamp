#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  NEW_USER=true
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  NEW_USER=false
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESSES=1

while [[ $GUESS != $SECRET ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ ${#GUESS} -gt 9 ]]
  then
    echo "It's lower than that, guess again:"
  elif (( 10#$GUESS > SECRET ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS || exit
  GUESSES=$(( GUESSES + 1 ))
done

if [[ $NEW_USER == true ]]
then
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESSES)" > /dev/null
else
  $PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESSES) WHERE username='$USERNAME'" > /dev/null
fi

echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
