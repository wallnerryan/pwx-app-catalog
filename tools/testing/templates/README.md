# Examples

Privileged deployment for fio drop caches pre-exec
```
config:
  # supports openshift storage, Rook/Ceph, OpenEBS, Rancher Longhorn, StorageOS
  # set to openshift, rook-ceph, openebs, longhorn, sos
  platform: "openshift"
  namespace: "stress"
  # supports any SC exists within namespace
  storage_class: "ocs-storagecluster-ceph-rbd"
  volumes: 1
  create_interval: 0
  # supported values: \"ReadOnlyMany\", \"ReadWriteMany\", \"ReadWriteOnce\"",
  access_mode: "ReadWriteOnce"
  # Must be in format supported by PVC
  gb_for_vol: "20Gi"
  # uses volume.beta.kubernetes.io/storage-class
  use_sc_annotation: False
  # The app that adds load per pvc (in templates/)
  # NOTE: some load apps may rely on other resources
  # please create them before running the test
  load_app: "fio-kubernetes-priv.yaml"

oc apply -f templates/fio-randrw.configmap

python add_volumes_over_time_with_load.py 
```

Non-privileged container with random write
```
config:
  # supports openshift storage, Rook/Ceph, OpenEBS, Rancher Longhorn, StorageOS
  # set to openshift, rook-ceph, openebs, longhorn, sos
  platform: "openshift"
  namespace: "stress"
  # supports any SC exists within namespace
  storage_class: "ocs-storagecluster-ceph-rbd"
  volumes: 1
  create_interval: 0
  # supported values: \"ReadOnlyMany\", \"ReadWriteMany\", \"ReadWriteOnce\"",
  access_mode: "ReadWriteOnce"
  # Must be in format supported by PVC
  gb_for_vol: "20Gi"
  # uses volume.beta.kubernetes.io/storage-class
  use_sc_annotation: False
  # The app that adds load per pvc (in templates/)
  # NOTE: some load apps may rely on other resources
  # please create them before running the test
  load_app: "fio-kubernetes.yaml"

oc apply -f templates/fio-randwrite.configmap

python add_volumes_over_time_with_load.py 
```

7,500 deployments running busybox with 1 second interval between creation
```
config:
  # supports openshift storage, Rook/Ceph, OpenEBS, Rancher Longhorn, StorageOS
  # set to openshift, rook-ceph, openebs, longhorn, sos
  platform: "openshift"
  namespace: "stress"
  # supports any SC exists within namespace
  storage_class: "ocs-storagecluster-ceph-rbd"
  volumes: 7500
  create_interval: 1
  # supported values: \"ReadOnlyMany\", \"ReadWriteMany\", \"ReadWriteOnce\"",
  access_mode: "ReadWriteOnce"
  # Must be in format supported by PVC
  gb_for_vol: "20Gi"
  # uses volume.beta.kubernetes.io/storage-class
  use_sc_annotation: False
  # The app that adds load per pvc (in templates/)
  # NOTE: some load apps may rely on other resources
  # please create them before running the test
  load_app: "busybox.yaml"

python add_volumes_over_time_with_load.py 
```

Run 50 deployments, using ZONE topologySpreadConstraints (k8s 1.19+)
```
config:
  # supports openshift storage, Rook/Ceph, OpenEBS, Rancher Longhorn, StorageOS
  # set to openshift, rook-ceph, openebs, longhorn, sos
  platform: "openshift"
  namespace: "stress"
  # supports any SC exists within namespace
  storage_class: "ocs-storagecluster-ceph-rbd"
  volumes: 50
  create_interval: 0
  # supported values: \"ReadOnlyMany\", \"ReadWriteMany\", \"ReadWriteOnce\"",
  access_mode: "ReadWriteOnce"
  # Must be in format supported by PVC
  gb_for_vol: "20Gi"
  # uses volume.beta.kubernetes.io/storage-class
  use_sc_annotation: False
  # The app that adds load per pvc (in templates/)
  # NOTE: some load apps may rely on other resources
  # please create them before running the test
  load_app: "fio-kubernetes-topo.yaml"
  
#edit topologySpreadonstraints accordingly
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: failure-domain.beta.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
        matchLabels:
          purpose: testing

python add_volumes_over_time_with_load.py 
```

Run 100 deployments, 2 per OCS node, using cluster.ocs.openshift.io/openshift-storage topologySpreadConstraints (k8s 1.19+)
```
config:
  # supports openshift storage, Rook/Ceph, OpenEBS, Rancher Longhorn, StorageOS
  # set to openshift, rook-ceph, openebs, longhorn, sos
  platform: "openshift"
  namespace: "stress"
  # supports any SC exists within namespace
  storage_class: "ocs-storagecluster-ceph-rbd"
  volumes: 100
  create_interval: 0
  # supported values: \"ReadOnlyMany\", \"ReadWriteMany\", \"ReadWriteOnce\"",
  access_mode: "ReadWriteOnce"
  # Must be in format supported by PVC
  gb_for_vol: "20Gi"
  # uses volume.beta.kubernetes.io/storage-class
  use_sc_annotation: False
  # The app that adds load per pvc (in templates/)
  # NOTE: some load apps may rely on other resources
  # please create them before running the test
  load_app: "fio-kubernetes-topo.yaml"
  
#edit topologySpreadonstraints accordingly
    spec:
      topologySpreadConstraints:
      - maxSkew: 2
        topologyKey: cluster.ocs.openshift.io/openshift-storage
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
        matchLabels:
          purpose: testing

python add_volumes_over_time_with_load.py 
```

