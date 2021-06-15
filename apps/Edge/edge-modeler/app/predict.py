import pandas as pd
import numpy as np
from datetime import datetime
from datetime import timedelta
import matplotlib.pyplot as plt
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM,Dropout,Dense
from sklearn.preprocessing import MinMaxScaler
import csv
import os

CB91_Blue = '#2CBDFE'
CB91_Green = '#47DBCD'
CB91_Pink = '#F3A0F2'
CB91_Purple = '#9D2EC5'
CB91_Violet = '#661D98'
CB91_Amber = '#F5B14C'


headers = ['Temperature', 'Humidity', 'Date']

# Test Data
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, 'example-data/sensor_data.csv')
df = pd.read_csv(filename, names=headers)

# Production Data
#df = pd.read_csv('/opt/iot/thermostat/sensor_data/edge_sensor_records.csv',names=headers)

def strip_datetime_ignore(str_x):
    try:
        return datetime.strptime(str_x, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError:
        # on the off chance we landed square on the second.
        return  datetime.strptime(str_x, '%Y-%m-%d %H:%M:%S')

df['Date'] = df['Date'].map(lambda x: strip_datetime_ignore(str(x)))
df = df.astype({"Temperature": float})

#subset to just temp prediction
df = df[['Date', 'Temperature']]
#print(df.dtypes)
df.index = df['Date']

# Divide 60,000 by step
# tonum is your 80 in 80/20 train/test
# fromnum is your 20 in 80/20 train/test
step=5
tonum=9000
fromnum=9000
forcastfrom=4000

# Reduce size to 50,000
df = df.tail(60000)
#every 10th row = 5,000 sampled records
df = df.iloc[::step, :]

t_ten = df['Temperature'].quantile(0.10)
t_nintey = df['Temperature'].quantile(0.90)

df["Temperature"] = np.where(df["Temperature"] < t_ten, t_ten,df['Temperature'])
df["Temperature"] = np.where(df["Temperature"] > t_nintey, t_nintey,df['Temperature'])

plt.figure(2, figsize=(12, 4))
color_list = [CB91_Blue, CB91_Green]
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=color_list)
plt.plot(df["Temperature"],label='Temp History')
plt.grid()
axes = plt.gca()
axes.set_ylim([60,80])
plt.fill_between(df.index, df["Temperature"], alpha=.5)
plt.savefig('static/temp_over_time_pre_prediction.png')

# As a neural network model, we will use LSTM(Long Short-Term Memory) model.  
# LSTM models work great when making predictions based on time-series datasets.

# Manipulate the data
df = df.sort_index(ascending=True,axis=0)
data = pd.DataFrame(index=range(0,len(df)),columns=['Date','Temperature'])
for i in range(0,len(data)):
    data["Date"][i]=df['Date'][i]
    data["Temperature"][i]=df["Temperature"][i]

scaler=MinMaxScaler(feature_range=(0,1))
data.index=data.Date
data.drop("Date",axis=1,inplace=True)
final_data = data.values
print(len(final_data))
# 60/40
train_data=final_data[0:tonum,:]
valid_data=final_data[fromnum:,:]
scaler=MinMaxScaler(feature_range=(0,1))
scaled_data=scaler.fit_transform(final_data)
x_train_data,y_train_data=[],[]
for i in range(60,len(train_data)):
    x_train_data.append(scaled_data[i-60:i,0])
    y_train_data.append(scaled_data[i,0])

#print(x_train_data[1])
x_train_data,y_train_data=np.array(x_train_data),np.array(y_train_data)
x_train_data=np.reshape(x_train_data,(x_train_data.shape[0],x_train_data.shape[1],1))

# Train into LSTM Model
lstm_model=Sequential()
lstm_model.add(LSTM(units=50,activation='relu',return_sequences=True,input_shape=(np.shape(x_train_data)[1],1)))
lstm_model.add(LSTM(units=50, activation='relu'))
lstm_model.add(Dense(1))
model_data=data[len(data)-len(valid_data)-60:].values
model_data=model_data.reshape(-1,1)
model_data=scaler.transform(model_data)


# Train and Test Data
lstm_model.compile(loss='mean_squared_error',optimizer='adam', metrics=['accuracy'])
lstm_model.fit(x_train_data,y_train_data,epochs=1,batch_size=1,verbose=2)
X_test=[]
for i in range(60,model_data.shape[0]):
    X_test.append(model_data[i-60:i,0])
X_test=np.array(X_test)
X_test=np.reshape(X_test,(X_test.shape[0],X_test.shape[1],1))

# Run prediction
#print(X_test)
predicted_temperature=lstm_model.predict(X_test)
predicted_temperature=scaler.inverse_transform(predicted_temperature)
scores = lstm_model.evaluate(x_train_data,y_train_data, verbose=0)
acc = "%s: %.2f%%" % (lstm_model.metrics_names[1], scores[1]*100)
f = open("static/acc.txt", "w")
f.write(acc)
f.close()
lstm_model.save("static/saved_model.h5")

#70/30
train_data=data[:tonum]
valid_data=data[fromnum:]

valid_data['Predictions']=predicted_temperature
plt.figure(3, figsize=(12, 4))
color_list = [CB91_Purple, CB91_Violet]
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=color_list)
plt.grid()
plt.plot(train_data["Temperature"],linewidth=1)
axes = plt.gca()
axes.set_ylim([60,80])
plt.fill_between(df.index, df["Temperature"], alpha=.5)
plt.plot(valid_data["Predictions"], '--r', linewidth=3)
#plt.fill_between(df.index, valid_data["Predictions"], alpha=.5)
plt.savefig('static/temp_over_time_post_prediction.png')

# multiply by timedelta below
X_FUTURE = 3000

# forcast_data=final_data[forcastfrom:,:]

# scaler=MinMaxScaler(feature_range=(0,1))
# scaled_forcast_data=scaler.fit_transform(final_data)
# x_forcast_data=[]
# for i in range(60,len(forcast_data)):
#     x_forcast_data.append(scaled_forcast_data[i-60:i,0])

# x_forcast_data=np.array(x_forcast_data)
# x_forcast_data=np.reshape(x_forcast_data,(x_forcast_data.shape[0],x_forcast_data.shape[1],1))

predictions = np.array([])
# last = x_forcast_data[-1]
last = x_train_data[-1]
for i in range(X_FUTURE):
  curr_prediction = lstm_model.predict(np.array([last]))
  last = np.concatenate([last[1:], curr_prediction])
  predictions = np.concatenate([predictions, curr_prediction[0]])
predictions = scaler.inverse_transform([predictions])[0]
print(predictions)

dicts = []
curr_date = data.index[-1]
for i in range(X_FUTURE):
  curr_date = curr_date + timedelta(seconds=1)
  dicts.append({'Predictions':predictions[i], "Date": curr_date})

new_data = pd.DataFrame(dicts).set_index("Date")

plt.figure(4, figsize=(12, 4))
color_list = [CB91_Amber]
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=color_list)
plt.plot(df["Temperature"][fromnum:],label='Temp History')
# show 15 minutes of forcast data
plt.plot(new_data['Predictions'][:900],'--b', label='Temp prediction')
plt.grid()
axes = plt.gca()
axes.set_ylim([60,80])
plt.fill_between(df.index[fromnum:], df["Temperature"][fromnum:], alpha=.5)
plt.savefig('static/temp_over_time_future_prediction.png')
