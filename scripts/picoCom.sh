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


SERIAL_PORT="/dev/pico_01"

PLANTS_WATER_ALARM=0
PUMP_WATER_ALARM=0

# Connect to MQTT broker
mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_5 | while read -r MESSAGE; do
  if [ "$MESSAGE" == "$TRIGGER_MESSAGE" ] && [ "$PLANTS_WATER_ALARM" != "1" ] && [ "$PUMP_WATER_ALARM" != "1" ]; then
    echo "1" > $SERIAL_PORT
  fi
done &

# Read from serial and publish to MQTT
while true; do
  if [ -r "$SERIAL_PORT" ]; then
    read -t 1 LINE< $SERIAL_PORT
    
    
    if [ $? -eq 0 ] && [ ! -z "$LINE" ]; then
      LINE=$(echo "$LINE" | tr -d '[:space:]')
      VALUES=($(echo $LINE | tr "," "\n"))
      
      PLANTS_WATER_ALARM="${VALUES[0]}"
      PUMP_WATER_ALARM="${VALUES[1]}"
      
      
      mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1 -m "${VALUES[0]}"
      mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_2 -m "${VALUES[1]}"
      mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_3 -m "${VALUES[2]}"
      mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_4 -m "${VALUES[3]}"
    fi
  else
    sleep 1
  fi



done
