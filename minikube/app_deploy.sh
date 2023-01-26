#!/bin/bash

for ns in us-east us-west
do
    tput setaf 12 && echo "Deploying app in namespace ${ns} ..." && tput sgr0

    export NAMESPACE=${ns}
    POD_NAME=$(kubectl get pods -n ${NAMESPACE} --output='jsonpath={.items[].metadata.name}')

    kubectl delete serviceaccount app -n ${NAMESPACE}
    kubectl delete deployment app -n ${NAMESPACE}
    kubectl delete pod ${POD_NAME} -n ${NAMESPACE}

    envsubst < app.yaml| kubectl apply -n ${NAMESPACE} -f -

    POD_NAME=$(kubectl get pods -n ${NAMESPACE} --output='jsonpath={.items[].metadata.name}')

    tput setaf 12 && echo "Scheduling pod ${POD_NAME} ..." && tput sgr0

    sleep 5

    kubectl logs ${POD_NAME} -n ${NAMESPACE} -c vault-agent-init
done
