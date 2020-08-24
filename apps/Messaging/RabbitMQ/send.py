#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('admin', 'secretpassword')
connection = pika.BlockingConnection(pika.ConnectionParameters('70.0.86.158',30785, '/',credentials))
channel = connection.channel()
channel.queue_declare(queue='hello', durable=True)
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!',
                      properties=pika.BasicProperties(
                        delivery_mode = 2 #persistent
                      ))
print(" [x] Sent 'Hello World!'")
connection.close()

