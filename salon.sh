#!/bin/bash
PSQL="psql -t --no-align --username=freecodecamp --dbname=salon -c"

echo -e "\n~~ MY SALON ~~\n"

MENU_PRINCIPAL(){
  if [[ $1 ]]
  then
    echo -e "$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  echo "$($PSQL "SELECT service_id, name FROM services")" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo $SERVICE_ID\) $SERVICE_NAME
  done

  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo $SERVICE_ID
  if [[ -z $SERVICE_ID ]]
  then
    MENU_PRINCIPAL "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      # insert new customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get service name
    SERVICE_SELECTED_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
    echo -e "\nWhat time would you like your $SERVICE_SELECTED_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_SELECTED_NAME at $SERVICE_TIME, $CUSTOMER_NAME." 
  fi
}

MENU_PRINCIPAL