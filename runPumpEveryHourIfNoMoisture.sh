#!/bin/bash

# Config
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"

TOPIC="moisture"
PUB_TOPIC="pump"

threshold="20"
sleep_interval=1  # Check every minute

reset_message="1"  # Message that will reset the timer
pump_timestamp_file="/tmp/pump_every_hour_timestamp"  # File to store the timestamp of the last pump

# Initialize pump_timestamp_file
echo $(date +%s) > $pump_timestamp_file

# Run mosquitto_sub in the background, update pump_timestamp_file when the reset message is published
mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $PUB_TOPIC | while read -r MESSAGE; do
  if [ "$MESSAGE" == "1" ]; then
    echo $(date +%s) > $pump_timestamp_file
    
  fi
done &

# Endless loop
while true
do
    # Get the last value from the MQTT topic
    last_value=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC -C 1)

    # Get the last reset time from the file
    last_reset_time=$(cat $pump_timestamp_file)

    # If the last value is less than the threshold and it has been an hour since the last reset, run the script
    if awk 'BEGIN {exit !('$last_value' < '$threshold')}' && [ $(date +%s) -ge $((last_reset_time + 5)) ]; then
        /home/pi/scripts/doSendPump.sh
        echo $(date +%s) > $pump_timestamp_file
    fi

    # Sleep for a minute
    sleep $sleep_interval
done
