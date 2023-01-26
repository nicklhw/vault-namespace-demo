#!/bin/bash

HOST_DOCKER_INTERNAL=$(minikube ssh "dig +short host.docker.internal" | tr -d '\r\n')
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_HOST=$(echo ${KUBE_HOST//https:\/\//})
KUBE_HOST=$(echo ${KUBE_HOST//127.0.0.1/$HOST_DOCKER_INTERNAL})

tput setaf 12 && echo "############## Writing config file: ../haproxy/haproxy.cfg ##############"

cat <<EOF > ../haproxy/haproxy.cfg
defaults
  log global
  mode http
  timeout connect 5000ms
  timeout client 5000ms
  timeout server 5000ms

frontend stats
   bind *:1936
   stats uri /
   stats enable
   stats show-legends
   stats show-node
   stats auth admin:password
   stats refresh 5s

frontend http_front
  bind 0.0.0.0:443
  mode tcp
  option tcplog
  default_backend minikube

backend minikube
  mode tcp
  balance leastconn
  option httpchk GET /livez
  server minikube ${KUBE_HOST} check check-ssl verify none
EOF

tput setaf 12 && echo "############## Restarting haproxy ##############"

docker restart haproxy

