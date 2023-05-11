# EMLI_TEAM23
Project/Exam for embedded linux.

TASKLIST:

a) The water pump must be controllable ✅

b) The described sensors must be readable 

c) The wireless remote functionality must be accessible

d) The water pump must run once at an interval of 12 hours
.
e) The water pump must additionally run maximum once per hour if the soil moisture falls below a certain threshold

f) The water pump must run once if the farmer presses the button once within a period of two seconds.

g) In case of an active pump water alarm or a plant water alarm the water pump may not run under any circumstances.

h) The wireless remote must light the red LED in case of a pump water alarm or plant water alarm.

i) The wireless remote must light the yellow LED in case the soil moisture is below a certain threshold

j) The wireless remote must light the green LED otherwise

k) The RPi must provide web access to historical information about soil moisture, ambient light, pump activations and water alarms. The data should be available as both graphs and downloadable data

l) The RPi must be able to function both with and without an active internet connection via the RPi ethernet port

m) The RPi must become fully operational after at power failure without requiring user interaction

n) The RPi system and internet performance and health must be monitored and logged
