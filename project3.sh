#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"
SERVICE_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  
# get available services
AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services order by service_id")
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

      read SERVICE_ID_SELECTED
      SERVICE_AVAILABILITY=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        echo -e "\nI could not find that service. What would you like today?" 
        SERVICE_MENU
      else
      #get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_NUMBER
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_NUMBER'")

      #if not found
      if [[ -z $CUSTOMER_ID ]]
      then
      # ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      #ask for time

      SERVICE_INFO=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
      echo -e "\nWhat time would you like your $(echo $SERVICE_INFO | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME

      echo -e "\nI have put you down for a $(echo $SERVICE_INFO | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      #Insert new customer and appointment
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_NUMBER', '$CUSTOMER_NAME')")
      INSERT_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_NUMBER' ")
      INSERT_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($INSERT_CUSTOMER_ID,$SERVICE_ID_SELECTED,$SERVICE_TIME)")
      else
      # ask for time
      SERVICE_INFO=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_NUMBER'")

      echo -e "\nWhat time would you like your $(echo $SERVICE_INFO | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME
      echo -e "\nI have put you down for a $(echo $SERVICE_INFO | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      INSERT_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_NUMBER'")
      INSERT_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($INSERT_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")




      fi
    fi

 
    
  

}
SERVICE_MENU
