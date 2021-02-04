#!/usr/bin/env python
import pika
import sys

def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)

credentials = pika.PlainCredentials('admin', 'secretpassword')
connection = pika.BlockingConnection(pika.ConnectionParameters('10.233.47.44',5672, '/',credentials))
channel = connection.channel()
channel.queue_declare(queue='hello', durable=True)
channel.basic_consume(queue='hello',
                      auto_ack=True,
                      on_message_callback=callback)
channel.start_consuming()
