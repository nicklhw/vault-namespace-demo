#!/bin/bash

export NAMESPACE=us-east

POD_NAME=$(kubectl get pods -n us-east --output='jsonpath={.items[].metadata.name}')

kubectl delete serviceaccount app -n us-east
kubectl delete deployment app -n us-east
kubectl delete pod $POD_NAME -n us-east

envsubst < app.yaml| kubectl apply -n us-east -f -

POD_NAME=$(kubectl get pods -n us-east --output='jsonpath={.items[].metadata.name}')

echo "Scheduling pod $POD_NAME ..."

sleep 5

kubectl logs $POD_NAME -n us-east -c vault-agent-init