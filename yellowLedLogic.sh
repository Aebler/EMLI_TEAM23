#!/bin/bash

# MQTT broker details

TOPIC_1="moisture"
RESULT_TOPIC="ledYellow"

threshold=10


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


mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1  |
while read -r line; do
    # Read the values from the MQTT topics
    value=$(echo "$line" | awk '{print int($1)}')
    
    if [ $value == "(null)" ]; then
        :
    else
        

        # Check the values and send output to the third topic
        if [ "$value" -lt "$threshold" ]; then
            publish_to_mqtt "1"
        else
            publish_to_mqtt "0"
        fi
    fi
done





