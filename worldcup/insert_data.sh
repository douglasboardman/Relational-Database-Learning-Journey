#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate all data to begin
echo $($PSQL "truncate games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  READING_LINE="YEAR = $YEAR, ROUND = $ROUND, WINNER = $WINNER, OPPONENT = $OPPONENT, W_GOALS = $W_GOALS, O_GOALS = $O_GOALS"
  echo $READING_LINE
  if [[ $YEAR != "year" ]]
  then
    # get winner id
    W_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    O_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
  
    
    # if winner not found
    if [[ -z $W_ID ]]
    then
      
      # insert winner
      INS_TEAM_RES=$($PSQL "insert into teams (name) values ('$WINNER')")
      if [[ $INS_TEAM_RES == "INSERT 0 1" ]]
      then
        echo Winner inserted into teams, $WINNER
      fi
      
      # get new winner id
      W_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    fi

    # if opponent not found
    if [[ -z $O_ID ]]
    then
      
      # insert opponent
      INS_TEAM_RES=$($PSQL "insert into teams (name) values ('$OPPONENT')")
      if [[ $INS_TEAM_RES == "INSERT 0 1" ]]
      then
        echo Opponent inserted into teams, $OPPONENT
      fi
      
      # get new opponent id
      O_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    fi

    # insert row in games
    INS_GAME_RES=$($PSQL "insert into games (year, winner_id, opponent_id, winner_goals, opponent_goals, round) values ($YEAR, $W_ID, $O_ID, $W_GOALS, $O_GOALS, '$ROUND')")
    if [[ $INS_GAME_RES == "INSERT 0 1" ]]
    then
      echo Inserted in games, $ROUND: $WINNER $W_GOALS X $O_GOALS $OPPONENT
    fi

  fi

done


