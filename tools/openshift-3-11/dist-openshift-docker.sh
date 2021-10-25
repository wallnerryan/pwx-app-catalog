#!/bin/bash

for host in 10.21.243.112 10.21.243.113 10.21.243.114 10.21.243.115 10.21.243.116 10.21.243.117 
do 
  ssh $host systemctl enable docker
  ssh $host systemctl start docker
  ssh $host systemctl is-active docker
  ssh $host docker version
  ssh $host cat /etc/sysconfig/docker
done

