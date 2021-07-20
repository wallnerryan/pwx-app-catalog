
# Demo Magic Demo
https://github.com/paxtonhare/demo-magic

## View, Fail, GroupSnap, AutoPilot PVC

This demo will setup postgres and cassandra, view pvc info, failover the app, snapshot and restore and auto-grow pvc.

## setup

1. Install the "autopilot" template from https://github.com/andrewh1978/px-deploy
2. connect to your environment `px-deploy -n my-ap-template`
3. `yum --enablerepo=extras install epel-release -y && yum install pv -y`
4. `cleanup.sh`

## Run the Demo

If you are not familiar with demo-magic. Just press enter. The demo will type everything for you. 
 - For commands that use `watch` you will *ctrl-c* out, then continue pressing enter.

`sh demo.sh`