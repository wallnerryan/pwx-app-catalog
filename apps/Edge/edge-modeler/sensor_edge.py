# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

import time
import board
import csv 
import datetime
import adafruit_dht
import RPi.GPIO as GPIO


# Initial the dht device, with data pin connected to:
#dhtDevice = adafruit_dht.DHT22(board.D4)

# you can pass DHT22 use_pulseio=False if you wouldn't like to use pulseio.
# This may be necessary on a Linux single board computer like the Raspberry Pi,
# but it will not work in CircuitPython.
dhtDevice = adafruit_dht.DHT22(board.D4, use_pulseio=False)

#leds for sensor readings
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18,GPIO.OUT)
GPIO.setup(25,GPIO.OUT)

#setup tracking output
# field names 
fields = ['Temperature', 'Humidity', 'DateTime'] 
   
# name of csv file 
filename = "edge_sensor_records.csv"
path = "/opt/iot/thermostat/sensor_data/"

while True:
    try:
        # Print the values to the serial port
        temperature_c = dhtDevice.temperature
        if temperature_c == None:
        	  GPIO.output(25,GPIO.HIGH)
        	  time.sleep(.5)
        	  GPIO.output(25,GPIO.LOW)
        	  continue
        temperature_f = temperature_c * (9 / 5) + 32
        humidity = dhtDevice.humidity
        GPIO.output(18,GPIO.HIGH)
        print(
            "Temp: {:.1f} F / {:.1f} C    Humidity: {}% ".format(
                temperature_f, temperature_c, humidity
            )
        )
        with open(path+filename, 'a', newline='') as file:
	        writer = csv.writer(file)
	        writer.writerow([temperature_f, humidity, datetime.datetime.now()])
        time.sleep(.5)
        GPIO.output(18,GPIO.LOW)

    except RuntimeError as error:
        # Errors happen fairly often, DHT's are hard to read, just keep going
        #print(error.args[0])
        GPIO.output(25,GPIO.HIGH)
        time.sleep(.5)
        GPIO.output(25,GPIO.LOW)
        continue
    except Exception as error:
        dhtDevice.exit()
        raise error

    time.sleep(.5)
