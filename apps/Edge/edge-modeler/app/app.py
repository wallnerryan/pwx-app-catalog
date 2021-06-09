from flask import Flask,  redirect, url_for
from flask import render_template
import subprocess
import os

app = Flask(__name__)

@app.route("/")
def serve_data():
    message = "PX-Edge-App"
    return render_template('index.html', message=message)

@app.route("/graph")
def run_graph():
    subprocess.call(["python3", "plot.py"])
    return render_template('graph.html')

@app.route("/predict")
def run_predict():
    subprocess.call(["python3", "predict.py"])
    f = open("static/acc.txt", "r")
    accuracy = f.read()
    return render_template('predict.html', accuracy=accuracy)

@app.route("/truncate")
def run_truncate():
    filename = "/opt/iot/thermostat/sensor_data/edge_sensor_records.csv"
    data = open(filename, "r")
    # Test Data
    #data = open("example-data/sensor_data.csv", "r")
    lines = data.readlines()
    last_lines = lines[-65000:]
    data.close()
    filename = "/opt/iot/thermostat/sensor_data/edge_sensor_records.csv"
    data = open(filename, "r")
    # Test Data
    #data = open("example-data/sensor_data.csv", "r")
    data.writelines(last_lines)
    data.close()
    message = "data truncated"
    return redirect(url_for('serve_data', message=message))

# run the application
if __name__ == "__main__":
    app.run(debug=True)
