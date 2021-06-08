from kubernetes import client, config
from kubernetes.client.rest import ApiException
from time import sleep
import yaml
import urllib3
import os

# Configs can be set in Configuration class directly or using helper utilities
settings = yaml.safe_load(open("config.yaml"))
settings = settings['config']
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
config.load_kube_config()

v1 = client.CoreV1Api()
print("Creating volumes over time for %s in namesspace %s. \
       Amount of vols: %d. Creation Interval: %d seconds" % \
           (settings['storage_class'], settings['namespace'], 
            settings['volumes'], settings['create_interval']))

def deploy_load_pod(pod_name, pvc_name, file_name):
    with open(file_name) as f:
        dep = yaml.safe_load(f)
        # Edit dep
        dep['metadata']['name'] = pod_name
        dep['spec']['template']['metadata']['labels']['app'] = pod_name
        dep['spec']['template']['spec']['volumes'][0]['persistentVolumeClaim']['claimName'] = pvc_name
        print(yaml.dump(dep))
        # deploy
        k8s_beta = client.ExtensionsV1beta1Api()
        resp = k8s_beta.create_namespaced_deployment(
            body=yaml.load(yaml.dump(dep)), namespace=settings['namespace'])
        print("Deployment created. status='%s'" % str(resp.status))

for vol_num in range(settings['volumes']):
    # create pvc
    pvc_name = "%s-pvc-00%s" % (settings['storage_class'], vol_num)
    print("Working on Persistent Volume Claim: %s"
     % pvc_name)

    # Create Storage Requests
    storage_resource = {
       "storage": settings['gb_for_vol']
    }

    storage_resources=client.V1ResourceRequirements(
        requests=storage_resource
    )

    # Private spec for storage class and name.
    pvc_spec = client.V1PersistentVolumeClaimSpec(
        storage_class_name=settings['storage_class'],
        access_modes=[settings['access_mode']],
        resources=storage_resources
    )

    # Create Metadata
    pvc_labels = {
       "testing": "maxvolovertime",
       "platform": settings['platform'],
       "pvc_name": pvc_name
    }

    if settings['use_sc_annotation']:
        pvc_meta = client.V1ObjectMeta(
            labels=pvc_labels,
            name=pvc_name,
            namespace=settings['namespace'],
            annotations={"volume.beta.kubernetes.io/storage-class": settings['storage_class']}
        )
    else:
        pvc_meta = client.V1ObjectMeta(
            labels=pvc_labels,
            name=pvc_name,
            namespace=settings['namespace']        )

    body = client.V1PersistentVolumeClaim(
        spec=pvc_spec,
        metadata=pvc_meta
    )
    pretty = 'true'

    # try to create volume via pvc.
    try:
        print("Trying to Create PVC %s" % pvc_name)
        api_response = v1.create_namespaced_persistent_volume_claim(settings['namespace'], body, pretty=pretty)
        print(api_response)
    except ApiException as e:
        print("Exception when calling CoreV1Api->create_namespaced_persistent_volume_claim: %s\n" % e)

    try:
        pod_name = "app-load-%s-pvc-00%s" % (settings['storage_class'], vol_num)
        print("Trying to Create Load App Pod %s" % pod_name)
        file_name = "%s/templates/%s" % (os.path.dirname(os.path.realpath(__file__)), settings['load_app'])
        deploy_load_pod(pod_name, pvc_name, file_name)
    except ApiException as e:
        print("Exception when calling CoreV1Api->create_namespaced_deployment: %s\n" % e)

    sleep(settings['create_interval'])
