#!/usr/bin/env python
import pika

credentials = pika.PlainCredentials('admin', 'secretpassword')
connection = pika.BlockingConnection(pika.ConnectionParameters('10.233.47.44',5672, '/',credentials))
channel = connection.channel()
channel.queue_declare(queue='hello', durable=True)

for n in range(5000):
  channel.basic_publish(exchange='',
                        routing_key='hello',
                        body='Hello World! %d ' % (n),
                        properties=pika.BasicProperties(
                          delivery_mode = 2 #persistent
                        ))
  print(" [x] Sent 'Hello World!'")

connection.close()

