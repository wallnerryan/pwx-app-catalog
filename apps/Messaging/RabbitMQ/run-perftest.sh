#!/bin/bash

kubectl -n rabbitmq exec -it perftest -- \
    bin/runjava com.rabbitmq.perf.PerfTest \
      --time 900 \
      --queue-pattern 'perf-test-%d' \
      --queue-pattern-from 1 \
      --queue-pattern-to 2 \
      --producers 2 \
      --consumers 4 \
      --queue-args x-cancel-on-ha-failover=true \
      --flag persistent \
      --uri amqp://admin:secretpassword@rmq-rabbitmq-ha:5672?failover=failover_exchange
