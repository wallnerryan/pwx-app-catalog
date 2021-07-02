import pandas as pd
import numpy as np 
from datetime import datetime
import csv
import os
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import yaml


CB91_Blue = '#2CBDFE'
CB91_Green = '#47DBCD'
CB91_Pink = '#F3A0F2'
CB91_Purple = '#9D2EC5'
CB91_Violet = '#661D98'
CB91_Amber = '#F5B14C'

headers = ['Temperature', 'Humidity', 'Date']

settings = yaml.safe_load(open("config.yaml"))
settings = settings['config']

def strip_datetime_ignore(str_x):
    try:
        return datetime.strptime(str_x, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError:
        # on the off chance we landed square on the second.
        return  datetime.strptime(str_x, '%Y-%m-%d %H:%M:%S')

#Data
df = pd.read_csv(settings['data_path'],names=headers)

df['Date'] = df['Date'].map(lambda x: strip_datetime_ignore(str(x)))
df = df.set_index('Date')
# resample data to hourly to smooth, and look at last 1 week
df = df.resample('H').fillna("nearest").tail(settings['plot_lookback_hours'])
x = df.index
y = df['Temperature']
z = df['Humidity']

print(df['Temperature'].skew())
print(df['Humidity'].skew())

t_ten = df['Temperature'].quantile(0.10)
t_nintey = df['Temperature'].quantile(0.90)

df["Temperature"] = np.where(df["Temperature"] < t_ten, t_ten,df['Temperature'])
df["Temperature"] = np.where(df["Temperature"] > t_nintey, t_nintey,df['Temperature'])

h_ten = df['Humidity'].quantile(0.10)
h_ninety = df['Humidity'].quantile(0.90)

df["Humidity"] = np.where(df["Humidity"] < h_ten, h_ten,df['Humidity'])
df["Humidity"] = np.where(df["Humidity"] > h_ninety, h_ninety,df['Humidity'])

print(df['Temperature'].skew())
print(df['Humidity'].skew())

# plot
plt.gcf().autofmt_xdate()


plt.figure(2, figsize=(settings['plot_figsize_x'], settings['plot_figsize_y']))
axes = plt.gca()
axes.set_ylim([settings['plot_ylimit_hum_low'],settings['plot_ylimit_hum_high']])
color_list = [CB91_Green, CB91_Amber,
              CB91_Purple, CB91_Violet]
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=color_list)
plt.plot(x, z, linewidth=4)
plt.xlabel("Date / Time")
plt.ylabel("Humidity")
plt.grid()
plt.fill_between(x, z, alpha=.5)

plt.savefig('static/humid_over_time.png')

plt.figure(3, figsize=(settings['plot_figsize_x'], settings['plot_figsize_y']))
axes = plt.gca()
axes.set_ylim([settings['plot_ylimit_temp_low'],settings['plot_ylimit_temp_high']])
color_list = [CB91_Blue, CB91_Pink, CB91_Green, CB91_Amber,
              CB91_Purple, CB91_Violet]
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=color_list)
plt.plot(x, y, linewidth=4)
plt.xlabel("Date / Time")
plt.ylabel("Temperature")
plt.grid()
plt.fill_between(x, y, alpha=.5)

plt.savefig('static/temp_over_time.png')

