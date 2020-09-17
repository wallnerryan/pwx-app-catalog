from kubernetes import client, config
from kubernetes.client.rest import ApiException
from time import sleep
import urllib3
import yaml

# Configs can be set in Configuration class directly or using helper utility
settings = yaml.safe_load(open("config.yaml"))
settings = settings['config']
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
config.load_kube_config()

v1 = client.CoreV1Api()
print("Creating volumes over time for %s in namespace %s. \
       Amount of vols: %d. Creation Interval: %d seconds" % \
           (settings['storage_class'], settings['namespace'], 
            settings['volumes'], settings['create_interval']))

for vol_num in range(settings['volumes']):
    # create pvc
    pvc_name = "%s-pvc-00%s" % (settings['storage_class'], vol_num)
    print("Creating Persistent Volume Claim: %s" 
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
        api_response = v1.create_namespaced_persistent_volume_claim(settings['namespace'], body, pretty=pretty)
        print(api_response)
    except ApiException as e:
        print("Exception when calling CoreV1Api->create_namespaced_persistent_volume_claim: %s\n" % e)
    
    sleep(settings['create_interval'])
