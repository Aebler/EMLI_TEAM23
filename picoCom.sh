#!/bin/bash

# Set up MQTT credentials
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"

# Set up serial port


# Set up MQTT topics
TOPIC_1="plantsWaterAlarm"
TOPIC_2="pumpWaterAlarm"
TOPIC_3="moisture"
TOPIC_4="light"
TOPIC_5="pump"

# Set up message to trigger serial write
TRIGGER_MESSAGE="doPump"


SERIAL_PORT="/dev/ttyACM0"



# Connect to MQTT broker
mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_5 | while read -r MESSAGE; do
  if [ "$MESSAGE" == "$TRIGGER_MESSAGE" ]; then
    echo "p" > $SERIAL_PORT
  fi
done &

# Read from serial and publish to MQTT
while true; do
  read < $SERIAL_PORT LINE
  
  LINE=$(echo "$LINE" | tr -d '[:space:]')
  
  VALUES=($(echo $LINE | tr "," "\n"))
  
  
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1 -m "${VALUES[0]}"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_2 -m "${VALUES[1]}"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_3 -m "${VALUES[2]}"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_4 -m "${VALUES[3]}"
done
