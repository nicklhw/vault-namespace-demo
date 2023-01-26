#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'

kubectl create namespace test

cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-cloud
  namespace: test
---
apiVersion: v1
kind: Secret
metadata:
 name: test-cloud
 namespace: test
 annotations:
   kubernetes.io/service-account.name: test-cloud
type: kubernetes.io/service-account-token
EOF

cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth
  annotations:
    kubernetes.io/service-account.name: vault-auth
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: default
  - kind: ServiceAccount
    name: test-cloud
    namespace: test
EOF

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=$(cat ../docker-compose/scripts/vault.json | jq -r .root_token)

vault auth enable -audit-non-hmac-request-keys=jwt -audit-non-hmac-request-keys=role kubernetes

TOKEN_REVIEW_JWT=$(kubectl get secret vault-auth --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_HOST_DOCKER=$(echo "${KUBE_HOST/127.0.0.1/host.docker.internal}")

vault write auth/kubernetes/config \
     disable_local_ca_jwt="true" \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST_DOCKER" \
     kubernetes_ca_cert="$KUBE_CA_CERT"

vault read auth/kubernetes/config

vault write auth/kubernetes/role/app \
    bound_service_account_names=test-cloud \
    bound_service_account_namespaces=test \
    policies=admin \
    ttl=24h