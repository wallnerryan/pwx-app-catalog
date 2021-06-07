
## Portworx at Edge: Deep Machine Learning with Keras (on Tensorflow 2.0)

### PX-Edge-App

This application uses Keras for deep machine learning of IoT data. Keras is a high-level API that is built on top of TensorFlow. It is extremely user-friendly and comparatively easier than TensorFlow. 

### What is a LSTM Model

This app uses a LSTM recurrent neural networks for time series prediction in Python with the Keras deep learning network.

The Long Short-Term Memory network, or LSTM network, is a recurrent neural network that is trained using Backpropagation Through Time and overcomes the vanishing gradient problem.

### Build

`docker build . -t repo/image:tag`

### Run

`docker run -p 127.0.0.1:5000:5000/tcp repo/image:tag`

### Kubernetes + Sensor Edge

#### Setup

Create Shareedv4 Volume + Service with dummy pod.
```
kubectl create -f k8s/pvc-allow-all.yaml
kubectl create -f k8s/dummy.yaml
```

#### Sensor Edge

1. Create a sensor edge that collects Temperature + Humidity.
2. Write TEMPERATURE(FLOAT), HUMIDITY(FLOAT), DATE(DATETIME) to a csv called `edge_sensor_records.csv` to file
3. Sharedv4 used at the Edge where `edge_sensor_records.csv` resides

Example of mounting PX Sharedv4 Service at the edge on Raspberry Pi 2
```
apt-get install -y nfs-common 
mkdir /mnt/sensor_data/
mount -t nfs -o mountport=XXX,port=XXX,timeo=600,vers=3.0,actimeo=60,proto=tcp,retrans=8,soft XXXX:/var/lib/osd/pxns/XXX /mnt/sensor_data/
```

#### Kubernetes Core

Start Kubernetes Edge-App which reads, processes, graphs and models thermostat data
```
kubectl create -f k8s/edge-app.yaml
```

### Credits

- https://data-flair.training/blogs/stock-price-prediction-machine-learning-project-in-python/ 
- https://machinelearningmastery.com/standardscaler-and-minmaxscaler-transforms-in-python/ 
- https://towardsdatascience.com/step-by-step-guide-building-a-prediction-model-in-python-ac441e8b9e8b
- https://machinelearningmastery.com/save-load-keras-deep-learning-models/
- https://machinelearningmastery.com/time-series-prediction-lstm-recurrent-neural-networks-python-keras/
- https://stackoverflow.com/questions/65237843/predicting-stock-price-x-days-into-the-future-using-python-machine-learning
- https://keras.io/