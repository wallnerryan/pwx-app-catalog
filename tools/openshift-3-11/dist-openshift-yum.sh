#!/bin/bash

for host in 10.21.243.112 10.21.243.113 10.21.243.114 10.21.243.115 10.21.243.116 10.21.243.117 
do 
  ssh $host yum -y install openshift-ansible;
  ssh $host yum -y install docker-1.13.1;
  ssh $host rpm -V docker-1.13.1;
done

