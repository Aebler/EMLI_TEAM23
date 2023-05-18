#!/bin/bash

# MQTT broker details

TOPIC1="plantsWaterAlarm"
TOPIC2="pumpWaterAlarm"
RESULT_TOPIC="ledRed"


# MQTT Broker details
MQTT_HOST="localhost"
MQTT_PORT=1883
MQTT_USER="emli23"
MQTT_PASS="bonk22bonk"


# Function to publish message to MQTT topic
publish_to_mqtt() {
    mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $RESULT_TOPIC $1
}

# Function to monitor MQTT topics and publish result
monitor_topics() {
    while true; do
        # Read messages from topics
        output1=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_1)
        output2=$(mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -t $TOPIC_2)
                  

        # Check conditions and publish result
        if [[ $output1 == "1" || $output2 == "1" ]]; then
            publish_to_mqtt "1"
        else
            publish_to_mqtt "0"
        fi
    done
}

# Start monitoring topics
monitor_topics







