#!/bin/bash

kubectl -n rabbitmq exec rmq-rabbitmq-ha-0 -- \
  rabbitmqctl set_policy perf-test-with-ha '^perf-test' \
'{
  "ha-mode":"exactly",
  "ha-params":2,
  "ha-sync-mode":"automatic",
  "queue-master-locator":"min-masters",
  "queue-mode":"lazy"
}' --apply-to queues

kubectl patch svc rmq-rabbitmq-ha -n rabbitmq --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
kubectl -n rabbitmq get svc

# create test pod
kubectl -n rabbitmq run perftest \
  --restart=Always \
  --image dummy-required-param \
  --generator=run-pod/v1 \
  --overrides \
'{
  "spec": {
    "affinity": {
      "podAntiAffinity": {
        "requiredDuringSchedulingIgnoredDuringExecution": [{
          "labelSelector": {
            "matchExpressions": [{
              "key": "app",
              "operator": "In",
              "values": ["rabbitmq-ha"]
            }]
          },
          "topologyKey": "kubernetes.io/hostname"
        }]
      }
    },
    "containers": [{
      "command": ["sh"],
      "image": "pivotalrabbitmq/perf-test:latest",
      "name": "perftest",
      "args": ["-c", "sleep 3600"]
    }],
    "securityContext": {
      "runAsUser": 1000
    }
  }
}'
