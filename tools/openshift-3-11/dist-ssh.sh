#!/bin/bash

for host in 10.21.243.112 10.21.243.113 10.21.243.114 10.21.243.115 10.21.243.116 10.21.243.117 
do 
  ssh-copy-id -i ~/.ssh/id_rsa.pub $host; 
done

