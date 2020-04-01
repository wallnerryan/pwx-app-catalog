
Create Secret
```
echo -n mariadb123 > password.txt
kubectl create secret generic mariadb-pass --from-file=password.txt
```

Deploy
```
kubectl create -f mariadb.yaml
```
