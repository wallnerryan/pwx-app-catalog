#!/bin/bash

for host in 10.21.243.112 10.21.243.113 10.21.243.114 10.21.243.115 10.21.243.116 10.21.243.117 
do 
  ssh $host subscription-manager register --username=<USER> --password=<PASS>; 
  ssh $host subscription-manager refresh;
  ssh $host subscription-manager list --available --matches '*OpenShift*';
  ssh $host subscription-manager attach --pool=<POOL_ID>;
  ssh $host subscription-manager repos --disable="*";
  ssh $host subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.11-rpms" --enable="rhel-7-server-ansible-2.9-rpms";
done

