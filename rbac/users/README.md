# Example Users/RBAC Roles/Bindings

## How to use

```
# Generate openssl info
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr -subj "/CN=jane/O=myorg"

# Copy CA.crt and CA.key from master
openssl x509 -req -in jane.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out jane.crt -days 500

# Create credential and context
kubectl config set-credentials jane --client-certificate=/full/path/to/jane.crt  --client-key=/full/path/to/jane.key
kubectl config set-context jane-context --cluster=cluster.local --namespace=middleware --user=jane

# (needed for PX-Backup)
kubectl create -f deployment-cluster-role-binding-namespace-reader.yaml
kubectl create -f  deployment-cluster-role-namespace-reader.yaml

# Create role and binding
kubectl create -f deployment-role-middleware.yaml
kubectl create -f role-binding-jane.yaml

# Try access
kubectl --context=jane-context get pods
```
