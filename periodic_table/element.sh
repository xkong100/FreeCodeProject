#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ $1 ]]
  then
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
  ELEMENT=$($PSQL "SELECT atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type from properties JOIN elements using(atomic_number) JOIN types using (type_id) where elements.name LIKE '$1%' ORDER BY atomic_number LIMIT 1")
  else
  ELEMENT=$($PSQL "SELECT atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type from properties JOIN elements using(atomic_number) JOIN types using (type_id) where elements.atomic_number=$1")
  fi
    if [[ -z $ELEMENT ]]
    then 
      echo "I could not find that element in the database."
    else
      echo $ELEMENT | while IFS=\| read ATOMIC_NUMBER ATOMIC_MASS MPC BPC SY NAME TYPE
      do
         echo "The element with atomic number $(echo $ATOMIC_NUMBER | sed -r 's/^ *| *$//g') is $(echo $NAME | sed -r 's/^ *| *$//g') ($(echo $SY | sed -r 's/^ *| *$//g')). It's a $(echo $TYPE | sed -r 's/^ *| *$//g'), with a mass of $(echo $ATOMIC_MASS | sed -r 's/^ *| *$//g') amu. $(echo $NAME | sed -r 's/^ *| *$//g') has a melting point of $(echo $MPC | sed -r 's/^ *| *$//g') celsius and a boiling point of $(echo $BPC | sed -r 's/^ *| *$//g') celsius."

      done
    fi


  else
  echo "Please provide an element as an argument."
fi
