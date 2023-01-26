#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'
VAULT_CS_NAMESPACE='customer-success'
export EXTERNAL_VAULT_ADDR="$(minikube ssh "dig +short host.docker.internal")"

${DIR?}/cleanup.sh

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl create namespace vault
kubectl create namespace us-east
kubectl create namespace us-west

envsubst < ${DIR}/external-vault.yaml | kubectl apply -n us-east -f -
envsubst < ${DIR}/external-vault.yaml | kubectl apply -n us-west -f -

helm install vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault

VAULT_HELM_SECRET_NAME=$(kubectl get secrets -n ${NAMESPACE?} --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME -n ${NAMESPACE?} --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_HOST_DOCKER=$(echo "${KUBE_HOST/127.0.0.1/host.docker.internal}")

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=$(cat ../docker-compose/scripts/vault.json | jq -r .root_token)

vault auth enable -audit-non-hmac-request-keys=jwt -audit-non-hmac-request-keys=role -namespace=$VAULT_CS_NAMESPACE kubernetes

vault write -namespace=$VAULT_CS_NAMESPACE  auth/kubernetes/config \
     disable_iss_validation="true" \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="https://kubernetes" \
     kubernetes_ca_cert="$KUBE_CA_CERT"

vault write -namespace=$VAULT_CS_NAMESPACE auth/kubernetes/role/us-east \
    bound_service_account_names=app \
    bound_service_account_namespaces=us-east \
    policies=cs-us-east-app \
    token_max_ttl=20m \
    ttl=10m

vault write -namespace=$VAULT_CS_NAMESPACE auth/kubernetes/role/us-west \
    bound_service_account_names=app \
    bound_service_account_namespaces=us-west \
    policies=cs-us-west-app \
    token_max_ttl=20m \
    ttl=10m

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault-agent-injector -n vault

./app_deploy.sh
