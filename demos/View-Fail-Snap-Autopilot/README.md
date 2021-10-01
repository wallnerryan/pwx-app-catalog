
# Demo Magic Demo
https://github.com/paxtonhare/demo-magic

## View, Fail, GroupSnap, AutoPilot PVC

This demo will setup postgres and cassandra, view pvc info, failover the app, snapshot and restore and auto-grow pvc.

## setup

1. Install the "autopilot" template from https://github.com/andrewh1978/px-deploy
   `px-deploy create -n autopilot-demo-01 -t autopilot`
3. connect to your environment `px-deploy connect -n my-ap-template`
4. `yum --enablerepo=extras install epel-release -y && yum install pv -y`
5. `cleanup.sh`

## Run the Demo

If you are not familiar with demo-magic. Just press enter. The demo will type everything for you. 
 - For commands that use `watch` you will *ctrl-c* out, then continue pressing enter.

`sh demo.sh`
