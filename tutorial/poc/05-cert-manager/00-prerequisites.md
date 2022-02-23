



##### INSTALL CRDs
This will enabled Custom Resources like the ___cert-manager___ ```issuer``` resource to be enabled for interaction via ```kubeapi```
- Option 1: Installing CRDs with ```kubectl```
```
# Kubernetes 1.15+
$ kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml

# Kubernetes <1.15
$ kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager-legacy.crds.yaml

```
- Option 2: Install CRDs as part of HELM Release
```
# Helm v3+
$ helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.16.1 \
  # --set installCRDs=true

# Helm v2
$ helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.16.1 \
  jetstack/cert-manager \
  # --set installCRDs=true

```

