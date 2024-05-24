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

## test sticky session

```bash
while sleep 1; do curl -c cookie.txt -b cookie.txt http://nginx.sdombi.hu/v1/ ; done                                                                                                                            ─╯
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6
nginx-deployment-6fd7bd956-p7hr6

k get pods -napp                                                                                                                                                                                                ─╯
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-6fd7bd956-mlbbn   1/1     Running   0          5h33m
nginx-deployment-6fd7bd956-p7hr6   1/1     Running   0          119m
```
