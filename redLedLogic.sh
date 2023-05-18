#!/bin/bash

# MQTT broker details

TOPIC_1="plantsWaterAlarm"
TOPIC_2="pumpWaterAlarm"
RESULT_TOPIC="ledRed"


# MQTT Broker details
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"


# Function to publish message to MQTT topic
publish_to_mqtt() {
    mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $RESULT_TOPIC -m $1
}


# Connect to the MQTT broker

value_1="0"
value_2="0"

mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1 -t $TOPIC_2 -v |
while read -r line; do
    # Read the values from the MQTT topics
    topic=$(echo "$line" | awk '{print $1}')
    value=$(echo "$line" | awk '{print $2}')
    
    if [ $value == "(null)" ]; then
        :
    else
        echo $topic
        echo $value
        if [ "$topic" == "$TOPIC_1" ]; then
            value_1="$value"
        elif [ "$topic" == "$TOPIC_2" ]; then
            value_2="$value"

        fi

        # Check the values and send output to the third topic
        if [[ "$value_1" == "1" || "$value_2" == "1" ]]; then
            publish_to_mqtt "1"
        else
            publish_to_mqtt "0"
        fi
    fi
done





