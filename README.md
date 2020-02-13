# pwx-app-catalog

## Prerequisites

### Dependencies
 - `jq`
 - `awscli`
 - `ekscli`
 - Credentials in `~/.aws/credentials`
 - SSH key in `~/.ssh/aws-vm.pub`

## Launch EKS + Portworx 

`$ pwxeksctl.sh -c`

or

`pwxeksctl.sh -c -z us-west-2 -n default-px-cluster-0002 -r default-px-policy-0002`

## Destroy EKS + Portworx 

`$ pwxeksctl.sh -d`

or

`$ pwxeksctl.sh -d -n default-px-cluster-0002`