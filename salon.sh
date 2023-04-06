#!/bin/bash
PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c"

declare -A prompts
prompts[welcome]="Welcome to My Salon, how can I help you?"
prompts[wrong_service]="I could not find that service. What would you like today?"
prompts[ask_phone]="What's your phone number?"
prompts[ask_name]="I don't have a record for that phone number, what's your name?"
prompts[ask_time]="What time would you like your cut,"

echo -e "\n~~~~~ MY SALON ~~~~~"


MAIN_MENU() {
    if [[ $1 ]]
    then echo -e "\n$1\n"
    fi
    SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
    echo "$SERVICE_ID) $SERVICE_NAME"
    fi
    done
    read SERVICE_ID_SELECTED
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED ]]

    then MAIN_MENU  "${prompts[wrong_service]}"
    else echo ${prompts[ask_phone]}
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo $CUSTOMER_ID
        if [[ -z $CUSTOMER_ID ]]
        then
        echo ${prompts[ask_name]}
        read CUSTOMER_NAME
        CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        fi
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ +//g' )
        echo "${prompts[ask_time]} $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME
        APPOINT_INSERT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ +//g')
        echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

    fi
    exit

}


MAIN_MENU "${prompts[welcome]}"