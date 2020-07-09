#!/bin/bash

command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo >&2 "I require aws but it's not installed.  Aborting."; exit 1; }
command -v eksctl >/dev/null 2>&1 || { echo >&2 "I require eksctl but it's not installed.  Aborting."; exit 1; }

PWX_ROLE_ARN=""
REGION="us-east-1"
CLUSTER_NAME="default-px-cluster-0000"
PWX_ROLE_NAME="default-px-policy-0000"

function create_aws_pwx_role() {
    PWX_ROLE_ARN=$(aws iam create-policy --region $REGION --policy-name $PWX_ROLE_NAME --policy-document  file://pwx-node-role.json | jq '.Policy.Arn' | tr -d '"')
}

function get_aws_pwx_role() {
    # get policy arn based on $PWX_ROLE_NAME
    PWX_ROLE_ARN=$(aws iam list-policies --region $REGION |  jq --arg PWX_ROLE_NAME "$PWX_ROLE_NAME" '.Policies[] |  select(.PolicyName? ==  ($PWX_ROLE_NAME)) | .Arn' | tr -d '"')
}

function delete_aws_pwx_role() {
    get_aws_pwx_role
    if [[ ! -z $PWX_ROLE_ARN ]]; then
       aws iam delete-policy --region $REGION --policy-arn $PWX_ROLE_ARN
    fi
}

function make_cluster_copy() {
    cp cluster.yml cluster-${CLUSTER_NAME}.yml
}

function set_aws_pwx_role() {
    get_aws_pwx_role
    sed -i'.original' -e 's@REPLACE_PORTWORX_IAM_POLICY_ARN@'"$PWX_ROLE_ARN"'@' cluster-${CLUSTER_NAME}.yml
}

function set_cluster_name() {
    sed -i'.original' -e 's/SET_CLUSTER_NAME/'"$CLUSTER_NAME"'/' cluster-${CLUSTER_NAME}.yml
}

function set_cluster_region() {
    get_aws_pwx_role
    sed -i'.original' -e 's@REPLACE_REGION@'"$REGION"'@' cluster-${CLUSTER_NAME}.yml
}

function create_eks_cluster() {
    make_cluster_copy
    set_aws_pwx_role
    set_cluster_name
    set_cluster_region
    eksctl create cluster -f cluster-${CLUSTER_NAME}.yml || { echo 'eksctl create cluster....failed' ; exit 1; }
}

function verify_eks_ready() {
    eksctl utils wait-nodes --verbose 5 --kubeconfig "$HOME/.kube/config"
}

function delete_eks_cluster() {
    eksctl delete cluster --name=${CLUSTER_NAME} --region ${REGION} --wait
}

function install_pwx_prometheus() {
    kubectl apply -f https://2.0.docs.portworx.com/samples/k8s/portworx-pxc-operator.yaml
    kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system
}

function install_portworx() {
    install_pwx_prometheus
    until kubectl get pods -n kube-system -l k8s-app=prometheus-operator | grep Running | grep 1/1 
    do
      echo "waiting for prometheus...."
      sleep 5
    done
    kubectl apply -f px-spec.yaml
}

function install_nopx_stork() {
    echo "Deplpoying stork...."
    kubectl apply -f stork-spec.yaml
}

function get_pwx_status() {
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    until kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status | grep "PX is operational"
    do
      echo "waiting for Portworx to be operational...."
      sleep 30
    done
}

function expose_lighthouse(){
    kubectl expose deployment px-lighthouse --name=lighthouse-lb-service \
     --type=LoadBalancer -n kube-system
    #until kubectl get svc lighthouse-lb-service -n kube-system | grep "${REGION}.elb.amazonaws.com"
    #do
    #  echo "waiting for Lighthouse LoadBalancer...."
    #  sleep 10
    #done
}

function expose_prometheus(){
    kubectl expose service prometheus  --port=9090 --target-port=9090 \
     --name=prometheus-lb-service --type=LoadBalancer -n kube-system
    #until kubectl get svc prometheus-lb-service -n kube-system | grep "${REGION}.elb.amazonaws.com"
    #do
    #  echo "waiting for Prometheus LoadBalancer...."
    #  sleep 10
    #done
}

function expose_grafana(){
    kubectl expose svc grafana --port=3000 --target-port=3000 \
     --name=grafana-lb-service --type=LoadBalancer -n kube-system
    #until kubectl get svc grafana-lb-service -n kube-system | grep "${REGION}.elb.amazonaws.com"
    #do
    #  echo "waiting for Grafana LoadBalancer...."
    #  sleep 10
    #done
}

function delete_loadbalancers() {
    kubectl delete svc lighthouse-lb-service -n kube-system
    kubectl delete svc grafana-lb-service -n kube-system
    kubectl delete svc prometheus-lb-service -n kube-system
}

function install_helm() {
    if [[ $MACOSX == "true" ]]; then
        wget https://get.helm.sh/helm-v3.1.0-darwin-amd64.tar.gz
        tar -zxvf helm-v3.1.0-darwin-amd64.tar.gz
        mv darwin-amd64/helm /usr/local/bin/helm
        rm -rf darwin-amd64 helm-v3.1.0-darwin-amd64.tar.gz
        helm version
    fi
    if [[ $MACOSX == "false" ]]; then
        #else get amd64
        wget https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz
        tar -zxvf helm-v3.1.0-linux-amd64.tar.gz
        mv linux-amd64/helm /usr/local/bin/helm
        rm -rf linux-amd64 helm-v3.1.0-linux-amd64.tar.gz
        helm version
    fi
}

function install_pxcentral() {
    PXC_VERSION="1.0.3"
    read -p "Enter AWS AccessKey: " -s -e -r accessKey;
    read -p "Enter AWS SecretKey: " -s -e -r secretKey;
    read -p "Enter Admin Password: (Provide a proper strong password, containing .. One upper case, One lower case, One number, One special character ?#%$, Minimum 8 characters)" -s -e -r secretKey;

    echo -e "${YELLOW}Setting password and installing...${NC}\n"
    bash <(curl -s https://raw.githubusercontent.com/portworx/px-central-onprem/${PXC_VERSION}/install.sh) \
      --px-store \
      --px-backup \
      --admin-password ${adminPass} \
      --oidc \
      --managed \
      --cloud aws \
      --cloudstorage \
      --disk-type gp2 \
      --disk-size 100 \
      --pxcentral-namespace portworx \
      --px-metrics-store \
      --px-backup-organization myorg \
      --cluster-name mycluster \
      --admin-email admin@example.com\
      --admin-user admin \
      --aws-access-key ${accessKey} \
      --aws-secret-key ${secretKey}
}

function get_help() {
    echo
    echo "-h|--help"
    echo "-c|--create               (Create EKS+PWX)"
    echo "-d|--destroy              (Destroy EKS+PWX)"
    echo "-z|--region               (AWS Region)"
    echo "-n|--cluster-name         (OPTIONAL: [default: $CLUSTER_NAME])"
    echo "-r|--pwx-role-name        (OPTIONAL: [default: $PWX_ROLE_NAME])"
    echo "-s|--stand-alone-command  (OPTIONAL: Run command that doesnt Install/Destroy EKS/PWX)"
    echo "-j|--install-helm         (OPTIONAL: Install Helm CLI tools"
    echo "--nopx                    (OPTIONAL: Do not install Portworx, just setup EKS)"
    echo "--installpxc              (OPTIONAL: Install Portworx Central. [includes PX])"
    echo "--install-stork           (OPTIONAL: Install Stork on Non-PX clusters for PX-Backup)"
    echo "--macos                   (OPTIONAL: Running on macosx, not linux.)"
    echo 
    echo "Provide a px-spec or edit current one at px-spec.yaml for Portworx Customization"
    echo
    echo "To change EKS cluster, edit cluster.yml"
    echo
    exit 0
}

function cleanup_files() {
    if test -f "cluster-${CLUSTER_NAME}.yml"; then
        rm *.original > /dev/null 2>&1
        rm "cluster-${CLUSTER_NAME}.yml" > /dev/null 2>&1
    else
        echo -e "${YELLOW}skipping...${NC}\n"
    fi  
}

GREEN='\033[0;32m'
YELLOW='\033[1;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color
POSITIONAL=()
CREATE="false"
DESTROY="false"
NO_CREATE_OR_DESTROY="false"
INSTALL_HELM="false"
MACOSX="false"
PWX="true"
PWX_CENTRAL="false"
INSTALL_STORK="false"
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    get_help
    ;;
    -s|--stand-alone-command)
    NO_CREATE_OR_DESTROY="true"
    shift # past argument
    ;;
    --install-stork)
    INSTALL_STORK="true"
    shift # past argument
    ;;
    -c|--create)
    CREATE="true"
    shift # past argument
    ;;
    -z|--region)
    REGION="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--destroy)
    DESTROY="true"
    shift # past argument
    ;;
    -n|--cluster-name)
    CLUSTER_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--pwx-role-name)
    PWX_ROLE_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -j|--install-helm)
    INSTALL_HELM="true"
    shift # past argument
    ;;
    --macos)
    MACOSX="true"
    shift # past argument
    ;;
    --nopx)
    PWX="false"
    shift # past argument
    ;;
    --installpxc)
    PWX_CENTRAL="true"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ ! -z $DESTROY ]] && [[ $DESTROY == "true" ]]; then
    echo -e "\n${YELLOW}Setting PWX Install to False, since we're destroying things${NC}\n"
    PWX="false"
fi

echo 
echo "CREATE                     = ${CREATE}"
echo "DESTROY                    = ${DESTROY}"
echo "RUN COMMAND                = ${NO_CREATE_OR_DESTROY}"
echo "CLUSTER_NAME               = ${CLUSTER_NAME}"
echo "REGION                     = ${REGION}"
echo "AWS ROLE NAME              = ${PWX_ROLE_NAME}"
echo "INSTALL HELM               = ${INSTALL_HELM}"
echo "MACOSX                     = ${MACOSX} (only needed for helm install, otherwise ignored)"
echo "INSTALL PWX?               = ${PWX}"
echo "INSTALL PWX CENTRAL?       = ${PWX_CENTRAL}"
echo "INSTALL STORK for NON-PX?  = ${INSTALL_STORK}"
echo 
read -p "Continue.. y/n?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo -e "${GREEN}Continuing.....${NC}\n"
    else
        echo
        echo -e "${RED}Exiting.....${NC}\n"
        exit 0
    fi

if [[ ! -z $DESTROY ]] && [[ $DESTROY == "true" ]]; then
    read -p "Do you want to destroy EKS + Portworx cluster completely?.. y/n?" -n 1 -r
    echo -e "\n${YELLOW}Done${NC}\n"
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo -n "Deleting LoadBalancers......"
        echo
        delete_loadbalancers
        echo -n "Deleting EKS cluster......"
        echo
        delete_eks_cluster
        echo -n "Deleting PWX Policy......"
        echo
        delete_aws_pwx_role
        echo -n "Cleaning files......"
        echo
        cleanup_files
        echo -e "${GREEN}Done${NC}"
        exit 0
    else
        echo -e "${RED}Exiting.....${NC}\n"
        exit 0
    fi
fi

# Quick safety/validation check
if [[ $PWX_CENTRAL == "true" ]] && [[ $PWX == "true" ]]; then
    echo -e "${RED}....Cannot install PX Central and PX${NC}\n"
    echo -e "${YELLOW}....Use --nopx to turn off px install${NC}\n"
    echo -e "${RED}Exiting.....${NC}\n"
    exit 0
fi

if [[ ! -z $CREATE ]] && [[ $CREATE == "true" ]]; then
    echo -n "Creating Portworx EKS policy......"
    echo
    create_aws_pwx_role
    echo -e "${GREEN}Done${NC}"
    echo -n "Creating EKS cluster......"
    echo
    create_eks_cluster
    echo -e "${GREEN}Done${NC}"
    echo -n "Waiting for EKS Cluster......"
    echo
    verify_eks_ready
    echo -e "${GREEN}Done${NC}"
    if [[ $PWX == "true" ]]; then
        echo -n "Installing Portworx on the EKS cluster......"
        echo
        install_portworx
        echo -e "${GREEN}Done${NC}"
        echo -n "Waiting until Portworx is Operational......"
        echo
        get_pwx_status
        echo -e "${GREEN}Done${NC}"
        echo -n "Exposing Ports......"
        echo
        expose_grafana
        expose_prometheus
        expose_lighthouse
        echo -e "${GREEN}Done${NC}"
    else
        echo -e "${YELLOW}Skipping Portworx Install......${NC}"
        if [[ $INSTALL_STORK == "true" ]]; then
            echo -n "Installing Stork on non-PX EKS cluster......"
            echo
            install_nopx_stork
            echo -e "${GREEN}Done${NC}"
        fi
    fi
    if [[ $PWX_CENTRAL == "true" ]]; then
        echo -n "Installing Portworx Central on the EKS cluster......"
        echo
        install_pxcentral
        echo -e "${GREEN}Done${NC}"
        echo -n "Waiting until Portworx is Operational......"
        echo
        get_pwx_status
        echo -e "${GREEN}Done${NC}"
    else
        echo -e "${YELLOW}Skipping Portworx Central Install......${NC}"
    fi
    if [[ $INSTALL_HELM == "true" ]]; then
        echo -e "${YELLOW}Installing Helm......${NC}"
        echo
        install_helm
        echo -e "${GREEN}Done${NC}"
    fi
    exit 0
fi

if [[ ! -z $NO_CREATE_OR_DESTROY ]] && [[ $NO_CREATE_OR_DESTROY == "true" ]]; then
    echo -e "${GREEN}Running in stand-alone mode (no create/destroy)......${NC}"
    echo
    read -p "Continue.. y/n?" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo
            echo -e "${GREEN}Continuing.....${NC}\n"
        else
            echo
            echo -e "${RED}Exiting.....${NC}\n"
            exit 0
        fi
    echo
    echo -e "${GREEN}Checking options......${NC}"
    echo
    if [[ $INSTALL_HELM == "true" ]]; then
        echo -e "${YELLOW}Installing Helm......${NC}"
        echo
        install_helm
        echo -e "${GREEN}Done${NC}"
    fi
    if [[ $PWX_CENTRAL == "true" ]]; then
        echo -n "Installing Portworx Central on the EKS cluster......"
        echo
        install_pxcentral
        echo -e "${GREEN}Done${NC}"
        echo -n "Waiting until Portworx is Operational......"
        echo
        get_pwx_status
        echo -e "${GREEN}Done${NC}"
    else
        echo -e "${YELLOW}Skipping Portworx Central Install......${NC}"
    fi
    if [[ $PWX == "true" ]]; then
        echo -n "Installing Portworx on the EKS cluster......"
        echo
        install_portworx
        echo -e "${GREEN}Done${NC}"
        echo -n "Waiting until Portworx is Operational......"
        echo
        get_pwx_status
        echo -e "${GREEN}Done${NC}"
        echo -n "Exposing Ports......"
        echo
        # Need to fix if PX spec doesnt add monitoring
        # to timeouot on exposing the service.
        #expose_grafana
        #expose_prometheus
        #expose_lighthouse
        echo -e "${GREEN}Done${NC}"
    else: 
        echo -e "${YELLOW}Skipping Portworx Install......${NC}"
    fi
    exit 0
fi
