# Openshift 3.11 on RHEL 7.5

Example set of installation steps for OpenShift 3.11 with GlusterFS

## Pre-reqs

(EXAMPLE ONLY, CHANGE AS NEEDED)
Nodes

10.21.243.112 - Master - master.ocp311.cluster.test
10.21.243.113 - Worker-1 - worker-1.ocp311.cluster.test
10.21.243.114 - Worker-2 - worker-2.ocp311.cluster.test
10.21.243.115 - Worker-3 - worker-3.ocp311.cluster.test
10.21.243.116 - Worker-4 - worker-4.ocp311.cluster.test
10.21.243.117 - Infra-1  - infra-1.ocp311.cluster.test

*Note: all nodes should be using RHEL 7.5-8*
*Note: all nodes must be reachable via proper DNS*

The scripts here complete host prepraration.
 - https://docs.openshift.com/container-platform/3.11/install/host_preparation.html 

## Run Scripts

`bash dist-ssh.sh`

`bash dist-yum.sh`

`bash dist-opens-reg.sh`

`bash dist-openshift-yum.sh`

`bash dist-openshift-docker.sh`

```
  yum install -y ansible
  bash ansible.sh
```

## Install 3.11

scp openshift-inventory.yaml master.ocp311.cluster.test:/root/openshift-inventory.yaml
scp ~/.ssh/id_rsa master.ocp311.cluster.test:/root/
ssh master.ocp311.cluster.test
cp /root/id_rsa ~/.ssh/
cd /usr/share/ansible/openshift-ansible/
# Edit openshift-inventory.yaml if needed
ansible-playbook -i /root/openshift-inventory.yaml playbooks/prerequisites.yml
ansible-playbook -i /root/openshift-inventory.yaml playbooks/deploy_cluster.yml 

### After succesful install, configure user/pass
 - https://docs.openshift.com/container-platform/3.11/getting_started/configure_openshift.html 

### Login
https://master.ocp311.cluster.test:8443/console 
