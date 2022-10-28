#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

function get_valid_guess () {
  local __resultvar=$1
  read STRING
  while [[ ! $STRING =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read STRING
  done
  eval $__resultvar="'$STRING'"
}

echo "Enter your username:"
read USERNAME
USERINFO=$($PSQL "select games,best_game from users where username='$USERNAME'")
if [[ -z $USERINFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  STATUS=$($PSQL "insert into users(username) values('$USERNAME')")
  if [[ $STATUS != "INSERT 0 1" ]]
  then
    echo "problem with insert"
    exit -1;
  fi
  GAMES=0;
else
  GAMES=`echo $USERINFO | sed -e "s/|.*$//" `
  BEST=`echo $USERINFO | sed  -e "s/^.*|//" `
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi

SECRET=$(( ($RANDOM%1000)+1 ))
TRIES=1
echo Guess the secret number between 1 and 1000:
get_valid_guess GUESS
while [ $GUESS -ne $SECRET ]
do
  if [ $GUESS -lt $SECRET ]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  (( TRIES++ ))
  get_valid_guess GUESS
done
echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
(( GAMES ++ ))
if [[ -z $BEST || $TRIES -lt $BEST ]]
then
  BEST=$TRIES
fi
STATUS=$($PSQL "update users set games=$GAMES,best_game=$BEST where username='$USERNAME'")
if [[ $STATUS != "UPDATE 1" ]]
then
  echo "problem with update" $STATUS
  exit -1;
fi
exit 0
