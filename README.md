# pwx-app-catalog

A repository to streamline K8s + Portworx + Application stacks

## Prerequisites

### Dependencies
 - `jq`
 - `awscli`
 - `ekscli`
 - Credentials in `~/.aws/credentials`
 - SSH key in `~/.ssh/aws-vm.pub`

## Tools

`pwxeksctl` : Launch EKS + Portworx Environments
```
 ./pwxeksctl.sh --help

-h|--help
-c|--create
-d|--destroy
-z|--region
-n|--cluster-name (OPTIONAL: [default: default-px-cluster-0000])
-r|--pwx-role-name (OPTIONAL [default: default-px-policy-0000])
-s|--stand-alone-command
-j|--install-helm
--macos

Provide a px-spec or edit current one for Portworx Customization
```

## Launch EKS + Portworx 

`$ pwxeksctl.sh -c`

or

`pwxeksctl.sh -c -z us-west-2 -n default-px-cluster-0002 -r default-px-policy-0002`

## Destroy EKS + Portworx 

`$ pwxeksctl.sh -d`

or

`$ pwxeksctl.sh -d -n default-px-cluster-0002`

## Run in Stand-Alone mode.

Use this mode when you have already created a cluster want want to run a command available to add a feature or capability to the cluster. 

#### Example: Add Helm when running from mac.
`./pwxeksctl.sh -s -j --macos`

## Example Output
```
pwx-app-catalog/tools/eks  master ✗                                                                                                 6d ⚑ ◒
▶ ./pwxeksctl.sh -c -n default-px-cluster-0004

CREATE        = true
DESTROY       = false
CLUSTER_NAME  = default-px-cluster-0004
REGION        = us-east-1
AWS ROLE NAME = default-px-policy-0000

Continue.. y/n?y
Continuing.....

Creating Portworx EKS policy......
Done
Creating EKS cluster......
[ℹ]  eksctl version 0.13.0
[ℹ]  using region us-east-1
[ℹ]  subnets for us-east-1a - public:192.168.0.0/19 private:192.168.96.0/19
[ℹ]  subnets for us-east-1b - public:192.168.32.0/19 private:192.168.128.0/19
[ℹ]  subnets for us-east-1c - public:192.168.64.0/19 private:192.168.160.0/19
[ℹ]  using SSH public key "/Users/ryanwallner/.ssh/aws-vm.pub" as "eksctl-default-px-cluster-0004-nodegroup-storage-nodes-f1:34:ec:d6:2d:8d:c8:5d:b5:38:92:e5:b1:62:27:aa"
[ℹ]  using Kubernetes version 1.14
[ℹ]  creating EKS cluster "default-px-cluster-0004" in "us-east-1" region with managed nodes
[ℹ]  1 nodegroup (storage-nodes) was included (based on the include/exclude rules)
[ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
[ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
[ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-1 --cluster=default-px-cluster-0004'
[ℹ]  CloudWatch logging will not be enabled for cluster "default-px-cluster-0004" in "us-east-1"
[ℹ]  you can enable it with 'eksctl utils update-cluster-logging --region=us-east-1 --cluster=default-px-cluster-0004'
[ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "default-px-cluster-0004" in "us-east-1"
[ℹ]  2 sequential tasks: { create cluster control plane "default-px-cluster-0004", create managed nodegroup "storage-nodes" }
[ℹ]  building cluster stack "eksctl-default-px-cluster-0004-cluster"
[ℹ]  deploying stack "eksctl-default-px-cluster-0004-cluster"
[ℹ]  building managed nodegroup stack "eksctl-default-px-cluster-0004-nodegroup-storage-nodes"
[ℹ]  deploying stack "eksctl-default-px-cluster-0004-nodegroup-storage-nodes"
[✔]  all EKS cluster resources for "default-px-cluster-0004" have been created
[✔]  saved kubeconfig as "/Users/ryanwallner/.kube/config"
[ℹ]  nodegroup "storage-nodes" has 3 node(s)
[ℹ]  node "ip-192-168-31-176.ec2.internal" is ready
[ℹ]  node "ip-192-168-61-101.ec2.internal" is ready
[ℹ]  node "ip-192-168-78-229.ec2.internal" is ready
[ℹ]  waiting for at least 3 node(s) to become ready in "storage-nodes"
[ℹ]  nodegroup "storage-nodes" has 3 node(s)
[ℹ]  node "ip-192-168-31-176.ec2.internal" is ready
[ℹ]  node "ip-192-168-61-101.ec2.internal" is ready
[ℹ]  node "ip-192-168-78-229.ec2.internal" is ready
[ℹ]  kubectl command should work with "/Users/ryanwallner/.kube/config", try 'kubectl get nodes'
[✔]  EKS cluster "default-px-cluster-0004" in "us-east-1" region is ready
Done
Waiting for EKS Cluster......
Done
Installing Portworx on the EKS cluster......
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
serviceaccount/prometheus-operator created
deployment.apps/prometheus-operator created
secret/alertmanager-portworx created
waiting for prometheus....
prometheus-operator-6b7649f764-86gkp   1/1     Running   0          6s
service/portworx-service created
customresourcedefinition.apiextensions.k8s.io/volumeplacementstrategies.portworx.io created
serviceaccount/px-account created
clusterrole.rbac.authorization.k8s.io/node-get-put-list-role created
clusterrolebinding.rbac.authorization.k8s.io/node-role-binding created
namespace/portworx created
role.rbac.authorization.k8s.io/px-role created
rolebinding.rbac.authorization.k8s.io/px-role-binding created
daemonset.apps/portworx created
serviceaccount/px-csi-account created
clusterrole.rbac.authorization.k8s.io/px-csi-role created
clusterrolebinding.rbac.authorization.k8s.io/px-csi-role-binding created
service/px-csi-service created
deployment.apps/px-csi-ext created
service/portworx-api created
daemonset.apps/portworx-api created
csidriver.storage.k8s.io/pxd.portworx.com created
configmap/stork-config created
serviceaccount/stork-account created
clusterrole.rbac.authorization.k8s.io/stork-role created
clusterrolebinding.rbac.authorization.k8s.io/stork-role-binding created
service/stork-service created
deployment.apps/stork created
storageclass.storage.k8s.io/stork-snapshot-sc created
serviceaccount/stork-scheduler-account created
clusterrole.rbac.authorization.k8s.io/stork-scheduler-role created
clusterrolebinding.rbac.authorization.k8s.io/stork-scheduler-role-binding created
deployment.apps/stork-scheduler created
serviceaccount/portworx-pvc-controller-account created
clusterrole.rbac.authorization.k8s.io/portworx-pvc-controller-role created
clusterrolebinding.rbac.authorization.k8s.io/portworx-pvc-controller-role-binding created
deployment.apps/portworx-pvc-controller created
servicemonitor.monitoring.coreos.com/portworx-prometheus-sm created
alertmanager.monitoring.coreos.com/portworx created
service/alertmanager-portworx created
prometheusrule.monitoring.coreos.com/prometheus-portworx-rules-portworx.rules.yaml created
serviceaccount/prometheus created
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
prometheus.monitoring.coreos.com/prometheus created
service/prometheus created
configmap/grafana-dashboards created
configmap/grafana-source-config created
configmap/grafana-dashboard-config created
service/grafana created
deployment.apps/grafana created
serviceaccount/px-lh-account created
clusterrole.rbac.authorization.k8s.io/px-lh-role created
clusterrolebinding.rbac.authorization.k8s.io/px-lh-role-binding created
service/px-lighthouse created
deployment.apps/px-lighthouse created
Done
Waiting until Portworx is Operational......
Defaulting container name to portworx.
Use 'kubectl describe pod/portworx-nfj5c -n kube-system' to see all of the containers in this pod.
error: unable to upgrade connection: container not found ("portworx")
waiting for portworx....
Defaulting container name to portworx.
Use 'kubectl describe pod/portworx-nfj5c -n kube-system' to see all of the containers in this pod.
command terminated with exit code 126
waiting for portworx....
Defaulting container name to portworx.
Use 'kubectl describe pod/portworx-nfj5c -n kube-system' to see all of the containers in this pod.
Status: PX is operational
Done
Exposing Ports......
service/grafana-lb-service exposed
waiting for Grafana LoadBalancer....
grafana-lb-service   LoadBalancer   10.100.187.241   aacfe5703532411eaa60912fb1f77a08-733026044.us-east-1.elb.amazonaws.com   3000:31113/TCP   10s
service/prometheus-lb-service exposed
waiting for Prometheus LoadBalancer....
prometheus-lb-service   LoadBalancer   10.100.213.107   ab3635bb4532411eaa60912fb1f77a08-617821811.us-east-1.elb.amazonaws.com   9090:31073/TCP   10s
service/lighthouse-lb-service exposed
waiting for Lighthouse LoadBalancer....
lighthouse-lb-service   LoadBalancer   10.100.106.245   ab9c2ad7d532411eaa60912fb1f77a08-1936271332.us-east-1.elb.amazonaws.com   80:31733/TCP,443:30541/TCP   11s
Done

$ kubectl get no
NAME                             STATUS   ROLES    AGE     VERSION
ip-192-168-31-176.ec2.internal   Ready    <none>   5h35m   v1.14.7-eks-1861c5
ip-192-168-61-101.ec2.internal   Ready    <none>   5h35m   v1.14.7-eks-1861c5
ip-192-168-78-229.ec2.internal   Ready    <none>   5h36m   v1.14.7-eks-1861c5

$ kubectl get po -n kube-system -l name=portworx
NAME             READY   STATUS    RESTARTS   AGE
portworx-nfj5c   2/2     Running   0          5h35m
portworx-p9bjs   2/2     Running   0          5h35m
portworx-wstrt   2/2     Running   0          5h35m
```