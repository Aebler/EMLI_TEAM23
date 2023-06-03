#!/bin/bash

# Config
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"

TOPIC="moisture"
PUB_TOPIC="pub_topic"

threshold="10"
sleep_interval=60  # Check every minute
reset_value="RESET"

# Initialize last_pub_time to current time
last_pub_time=$(date +%s)

# Endless loop
while true
do
    # Get the last value from the MQTT topic
    last_value=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC -C 1)

    # Get the last message from the publish topic
    last_pub_message=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $PUB_TOPIC -C 1)

    # If the last message from the publish topic is the reset value, reset the last_pub_time
    if [ "$last_pub_message" == "$reset_value" ]; then
        last_pub_time=$(date +%s)
    fi

    # If the last value is less than the threshold and it has been an hour since the last reset, run the script
    if awk 'BEGIN {exit !('$last_value' < '$threshold')}' && [ $(date +%s) -ge $((last_pub_time + 3600)) ]; then
        /home/pi/scripts/doSendPump.sh
        last_pub_time=$(date +%s)
    fi

    # Sleep for a minute
    sleep $sleep_interval
done
