#!/bin/bash

for host in 10.21.243.112 10.21.243.113 10.21.243.114 10.21.243.115 10.21.243.116 10.21.243.117 
do 
  echo $host;
  ssh $host yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct;
  ssh $host yum -y update;
  ssh $host '{ sleep 1; reboot -f; } >/dev/null &'; 
done

