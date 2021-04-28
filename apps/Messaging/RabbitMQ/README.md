# RabbitMQ on Portworx

![Alt](https://i.imgur.com/MwB6ZmK.png)

## Pre-reqs

- Helm CLI
- Python pika-1.2.0

## Install

```
install-rabbit.sh
```

## Test

```
setup-test-env.sh

run-perftest.sh
```

## Backup

Pre
```
rabbitmqctl export_definitions /var/lib/rabbitmq/definitions.file.json
rabbitmqctl stop_app
```

Post
```
rabbitmqctl start_app
```

