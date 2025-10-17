#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES_MENU() {
  # Display welcome message if provided
  if [[ -n $1 ]]; then
    echo -e "$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  
  # Get and display services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read NUMBER BAR NAME
  do
    echo "$NUMBER) $NAME"
  done
  
  # Get service selection
  read SERVICE_ID_SELECTED
  
  # Validate service selection
  SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    SERVICES_MENU "I could not find that service. What would you like today?"
  else
    # If service is valid, get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If customer doesn't exist, get their name
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    
    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # Ask for service time
    echo -e "\nWhat time would you like your $(echo $SERVICE_AVAILABILITY | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
    read SERVICE_TIME
    
    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # Confirm appointment
    echo -e "\nI have put you down for a $(echo $SERVICE_AVAILABILITY | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
}

# Start the service menu
SERVICES_MENU