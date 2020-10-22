#!/bin/bash

## Run and repeate volumes over time tasks over time.
## Run in background nohup long-term-create-delete-load.sh &

TIME_IN_SECONDS=10800
WAIT_FOR_DELETE_IN_SECONDS=300
NAMESPACE=stress

touch output.log
END=$((SECONDS+TIME_IN_SECONDS))
while [ $SECONDS -lt $END ]; do
    echo "Running load overtime"
    python add_volumes_over_time_with_load.py
    sleep $WAIT_FOR_DELETE_IN_SECONDS

    # Report
    echo "Bound Vols" >> output.log
    kubectl get pvc -n $NAMESPACE | grep Bound | wc -l >> output.log 
    echo "Running Containers" >> output.log
    kubectl get po -n $NAMESPACE | grep 1/1 | wc -l >> output.log

    echo "Deleteing Pods and PVCs"
    kubectl delete deployment,pvc -n $NAMESPACE --all
done

echo "long-term-create-delete-load.sh TEST COMPLETE" >> output.log
