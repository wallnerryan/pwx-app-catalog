# Usage

2. These tests are one off and designed to be run one-off.

# How to use

Centos7
```
yum install -y wget git
git clone https://github.com/wallnerryan/pwx-app-catalog.git
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python get-pip.py
pip install setuptools --upgrade
pip install --ignore-installed -r requirements.txt
```

## config.yaml

This file contains the setting you want to use for running the tests.

### Test Parameters

- **platform**:  used to identify in tags
- **namespace**: the namespace in which to run the test
- **storage_class**: storage class to use within the namespace
- **volumes**: the number of volumes to run
- **create_interval**: the time between PVC creation requests to Kubernetes
- **access_mode**: the access mode of the PV
- **gb_for_vol**: the size of the PVC request
- **use_sc_annotation**: should the test use the old annotation
- **load_app**: what deployment/app to run attached to each PVC for load. in `templates/`

## Tests

### add_volumes_over_time

Runs # of PVC creation requests to bind with a certain interval.

### add_volumes_over_time_with_load

Runs # of PVC creation requests to bind with a certain interval with load attached to each pvc.
