FROM python:3.9.5-buster

ADD app/ /app
WORKDIR /app

RUN pip3 install -r requirements.txt

# Sensor data (sensor_data.csv) should be found here
VOLUME ["/opt/iot/thermostat/sensor_data"]

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]