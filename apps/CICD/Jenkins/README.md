# Jenkins on PX

kubectl create -f secrets.yaml
kubectl create -f jenkins.yaml

## Autopilot

kubectl create -f jenkins-ap-rule.yaml

## Backup

Copy cli
```
kubectl exec <jenkins-deployment-pod> -n jenkins -- /bin/sh -c "wget http://jenkins:8080/jnlpJars/jenkins-cli.jar -O /var/jenkins_home/cli.jar"
```


pre
```
java -jar /var/jenkins_home/cli.jar -s http://jenkins:8080 -webSocket -auth username:password stop-builds job-1
```

post
```
java -jar /var/jenkins_home/cli.jar -s http://jenkins:8080 -webSocket -auth username:password build job-1
```
