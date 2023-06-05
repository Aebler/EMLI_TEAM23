#!/bin/bash

# Set up MQTT credentials
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"

# Set up MQTT topics
TOPIC_1="sys_hdd"
TOPIC_2="sys_mem"
TOPIC_3="sys_cpu"
TOPIC_4="sys_temp"
TOPIC_5="sys_internet"

# Read from serial and publish to MQTT
while true; do
  disk=$(df -h | awk '$NF=="/"{print $5}' | tr -d '%')
  mem=$(free | awk '/Mem/{printf "%d\n", ($3/$2) * 100}')
  cpu_load=$(top -bn 1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  cpu_temp=$(vcgencmd measure_temp | awk -F "=" '{print $2}' | tr -d "'C")

  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1 -m "$disk"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_2 -m "$mem"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_3 -m "$cpu_load"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_4 -m "$cpu_temp"
done
