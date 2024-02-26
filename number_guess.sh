#!/bin/bash


#
# Variables
#
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
number_of_guesses=0

#
# Functions
#

prompt_user_guess() {

  unset_guess

  while [[ -z "${USER_GUESS}" ]]; do
    read USER_GUESS
    if ! [[ "${USER_GUESS}" =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      unset_guess
    fi
  done

  number_of_guesses=$((number_of_guesses + 1 ))

}

unset_guess() {
  unset USER_GUESS
}

game_on() {

  prompt_user_guess
  
  if [[ "${USER_GUESS}" -eq "${secret_number}" ]]; then
    ins=$( $PSQL "INSERT INTO games (player_id, winning_number, total_guesses) VALUES ((SELECT player_id FROM players WHERE name = '${USERNAME}'), '${secret_number}', '${number_of_guesses}' ) ;")
  elif [[ "${USER_GUESS}" -gt "${secret_number}" ]]; then
    echo "It's lower than that, guess again:"
    game_on
  elif [[ "${USER_GUESS}" -lt "${secret_number}" ]]; then
    echo "It's higher than that, guess again:"
    game_on
  fi
}


#
# Main program
#

echo "Enter your username:"
read USERNAME

check_user=$( ${PSQL} "SELECT name FROM players WHERE name = '${USERNAME}'")

if [[ -z "${check_user}" ]]; then
  echo "Welcome, ${USERNAME}! It looks like this is your first time here."
  ins_user=$($PSQL "INSERT INTO players (name) VALUES('${USERNAME}');")
else
  tot_played=$( ${PSQL} "select COUNT(*) from games where player_id = (SELECT player_id FROM players WHERE name = '${check_user}'); ")
  
  best_play_round=$( ${PSQL} "select min(total_guesses) FROM games WHERE player_id = (SELECT player_id FROM players WHERE name = '${check_user}'); ")
  if [[ -z "${best_play_round}" ]]; then
    best_play_round=0
  fi
  
  echo ""
  echo "Welcome back, ${check_user}! You have played ${tot_played} games, and your best game took ${best_play_round} guesses."

fi

# Will set the random number to guess for.
secret_number=$((1 + RANDOM % 1000))
echo ""
echo "Guess the secret number between 1 and 1000:"

# Start the game looping... :D
game_on

echo "You guessed it in ${number_of_guesses} tries. The secret number was ${secret_number}. Nice job!"