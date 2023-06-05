// Embedded Linux (EMLI)
// University of Southern Denmark

// 2022-03-24, Kjeld Jensen, First version

// Configuration
#define WIFI_SSID       "EMLI_TEAM_23"
#define WIFI_PASSWORD    "ronk77qwvt33"

//#define MQTT_SERVER      "io.adafruit.com"
#define MQTT_SERVER "192.168.10.1"
#define MQTT_SERVERPORT  1883 
#define MQTT_USERNAME    "emli23"
#define MQTT_KEY         "bonk22bonk"
#define MQTT_TOPIC_BUTTON "button"
#define MQTT_TOPIC_LED_RED "ledRed"
#define MQTT_TOPIC_LED_YELLOW "ledYellow"
#define MQTT_TOPIC_LED_GREEN "ledGreen"


// wifi
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
ESP8266WiFiMulti WiFiMulti;
const uint32_t conn_tout_ms = 5000;

// Button
#define GPIO_INTERRUPT_PIN 4
#define DEBOUNCE_TIME 100 
bool buttonPush = false;


// Led's
#define PIN_LED_RED     14
#define PIN_LED_YELLOW  13
#define PIN_LED_GREEN   12

// mqtt
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"
WiFiClient wifi_client;
Adafruit_MQTT_Client mqtt(&wifi_client, MQTT_SERVER, MQTT_SERVERPORT, MQTT_USERNAME, MQTT_KEY);
Adafruit_MQTT_Publish button_mqtt_publish = Adafruit_MQTT_Publish(&mqtt, MQTT_TOPIC_BUTTON);
Adafruit_MQTT_Subscribe RED_LED_SUB = Adafruit_MQTT_Subscribe(&mqtt, MQTT_TOPIC_LED_RED);
Adafruit_MQTT_Subscribe YELLOW_LED_SUB = Adafruit_MQTT_Subscribe(&mqtt, MQTT_TOPIC_LED_YELLOW);
Adafruit_MQTT_Subscribe GREEN_LED_SUB = Adafruit_MQTT_Subscribe(&mqtt, MQTT_TOPIC_LED_GREEN);

// publish
#define PUBLISH_INTERVAL 5000
unsigned long prev_post_time;

#define READ_INTERVAL 5000
unsigned long prev_read_time;

// debug
#define DEBUG_INTERVAL 2000
unsigned long prev_debug_time;

ICACHE_RAM_ATTR void button_interupt()
{
  buttonPush = true;
  Serial.print("Button is active");
}

void debug(const char *s)
{
  Serial.print (millis());
  Serial.print (" ");
  Serial.println(s);
}

void mqtt_connect()
{
  int8_t ret;

  // Stop if already connected.
  if (! mqtt.connected())
  {
    debug("Connecting to MQTT... ");
    while ((ret = mqtt.connect()) != 0)
    { // connect will return 0 for connected
         Serial.println(mqtt.connectErrorString(ret));
         debug("Retrying MQTT connection in 5 seconds...");
         mqtt.disconnect();
         delay(5000);  // wait 5 seconds
    }
    debug("MQTT Connected");
  }
}

void print_wifi_status()
{
  Serial.print (millis());
  Serial.print(" WiFi connected: ");
  Serial.print(WiFi.SSID());
  Serial.print(" ");
  Serial.print(WiFi.localIP());
  Serial.print(" RSSI: ");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
}

void setup()
{
  // count
  pinMode(GPIO_INTERRUPT_PIN, INPUT_PULLUP);
  pinMode(PIN_LED_RED, OUTPUT);
  pinMode(PIN_LED_YELLOW, OUTPUT);
  pinMode(PIN_LED_GREEN, OUTPUT);
  attachInterrupt(digitalPinToInterrupt(GPIO_INTERRUPT_PIN), button_interupt, RISING);

  // serial
  Serial.begin(115200);
  delay(10);
  debug("Boot");

  // wifi
  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFiMulti.addAP(WIFI_SSID, WIFI_PASSWORD);
  if(WiFiMulti.run(conn_tout_ms) == WL_CONNECTED)
  {
    print_wifi_status();
  }
  else
  {
    debug("Unable to connect");
  }

  // Setup MQTT subscription for LED_FEED
  mqtt.subscribe(&RED_LED_SUB);
  mqtt.subscribe(&YELLOW_LED_SUB);
  mqtt.subscribe(&GREEN_LED_SUB);
}

void publish_data()
{
  
  Serial.print(millis());
  Serial.print(" Publishing: ");

  Serial.print(millis());
  Serial.println(" Connecting...");
  if (buttonPush){
    if((WiFiMulti.run(conn_tout_ms) == WL_CONNECTED))
    {
      print_wifi_status();

      mqtt_connect();
      if (! button_mqtt_publish.publish('1'))
      {
        debug("MQTT failed");
      }
      else
      {
        debug("MQTT ok");
        buttonPush = false;
      }
    }
  }
}
void subscriber_led(){
  mqtt_connect();
  Serial.print(F("LED: "));
  Adafruit_MQTT_Subscribe *subscription;
  while ((subscription = mqtt.readSubscription(500))) {
    Serial.print(F("Got: "));
    if (subscription == &RED_LED_SUB) {
      Serial.print(F("Red   = "));
      Serial.println(*((char *)RED_LED_SUB.lastread));
      if (*((char *)RED_LED_SUB.lastread) == '1'){
        digitalWrite(PIN_LED_RED, HIGH);
      } else if (*((char *)RED_LED_SUB.lastread) == '0'){
        digitalWrite(PIN_LED_RED, LOW);
      }
    } else if (subscription == &YELLOW_LED_SUB) {
      Serial.print(F("Yellow = "));
      Serial.println(*((char *)YELLOW_LED_SUB.lastread));
      if (*((char *)YELLOW_LED_SUB.lastread) == '1'){
        digitalWrite(PIN_LED_YELLOW, HIGH);
      } else if (*((char *)YELLOW_LED_SUB.lastread) == '0'){
        digitalWrite(PIN_LED_YELLOW, LOW);
      }
    } else if (subscription == &GREEN_LED_SUB) {
      Serial.print(F("Green  = "));
      Serial.println(*((char *)GREEN_LED_SUB.lastread));
      if (*((char *)GREEN_LED_SUB.lastread) == '1'){
        digitalWrite(PIN_LED_GREEN, HIGH);
      } else if (*((char *)GREEN_LED_SUB.lastread) == '0'){ 
        digitalWrite(PIN_LED_GREEN, LOW);
      }
    }
  }
}

void loop()
{
    if (millis() - prev_post_time >= PUBLISH_INTERVAL)
    {
      prev_post_time = millis();
      publish_data();
    }

    if (millis() - prev_read_time >= READ_INTERVAL){
      prev_read_time = millis();
      subscriber_led();      
    }
   
    if (millis() - prev_debug_time >= DEBUG_INTERVAL)
    {
      prev_debug_time = millis();
      Serial.print(millis());
      Serial.print(" ");
      Serial.println(buttonPush);
    }
}

