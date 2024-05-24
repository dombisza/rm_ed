# nginx ingress example

```bash
helmfile sync
```

```bash
cd resources
kubectl ns create app
kubectl apply -f nginx.yaml
kubectl apply -f svc.yaml
kubectl apply -f ingress.yaml
```
