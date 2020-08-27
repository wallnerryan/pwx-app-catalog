# simple external etcd

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
docker-compose up -d
```

Point PX at the node 
```
[etcd]$ docker ps
CONTAINER ID        IMAGE                      COMMAND                 CREATED             STATUS              PORTS                              NAMES
e7be281d7fc8        bitnami/etcd:3-debian-10   "/entrypoint.sh etcd"   7 minutes ago       Up 7 minutes        0.0.0.0:2379->2379/tcp, 2380/tcp   etcd_etcd_1
```
