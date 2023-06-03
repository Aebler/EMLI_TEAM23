#!/bin/bash

# Config
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"

TOPIC="moisture"

threshold="20"

# Endless loop
while true
do
    # Get the last value from the MQTT topic
    
    
    last_value=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC -C 1)

    # If the last value is less than the threshold, run the script
    if (( $(echo "$last_value < $threshold" | bc -l) )); then
        /home/pi/scripts/doSendPump.sh
    fi

    # Sleep for 1 hour
    sleep 3600
done
