.DEFAULT_GOAL := all
.PHONY: clean up-detach init show-members ui token

export VAULT_TOKEN := $(shell cat docker-compose/scripts/vault_c1.json | jq -r '.root_token')
export VAULT_ADDR := http://localhost:8200

all: clean up-detach

up-detach:
	cd docker-compose \
	  && docker-compose up --detach --remove-orphans

init:
	cd docker-compose/scripts \
	  && ./init_c1.sh

clean:
	cd docker-compose \
	&& docker-compose down --volumes \
	&& rm -f ./vault/audit_logs/*

show-members:
	vault operator raft list-peers

logs:
	cd docker-compose \
    && docker-compose logs -f

ui:
	open http://localhost:18201

ldap-ui:
	open http://localhost:8081

token:
	cat docker-compose/scripts/vault_c1.json | jq -r '.root_token' | pbcopy

create-secrets:
	cd terraform \
	&& terraform init \
	&& terraform apply --auto-approve

destroy-secrets:
	cd terraform \
	&& terraform destroy --auto-approve

create-kv:
	docker run \
      --rm \
      --name=benchmark-vault \
      --hostname=benchmark-vault \
      --network=docker-compose_vault_c1 \
      hashicorp/benchmark-vault:0.0.0-dev \
      benchmark-vault -vault_addr=http://vault_c1_s1:8200 -vault_token=${VAULT_TOKEN} -pct_kvv1_read=90 -pct_kvv1_write=10 -duration=300s -rps=5

create-pki:
	docker run \
      --rm \
      --name=benchmark-vault \
      --hostname=benchmark-vault \
      --network=docker-compose_vault_c1 \
      hashicorp/benchmark-vault:0.0.0-dev \
      benchmark-vault -vault_addr=http://vault_c1_s1:8200 -vault_token=${VAULT_TOKEN} -pct_pki_issue=100 -duration=300s -rps=5

create-approle-login:
	docker run \
      --rm \
      --name=benchmark-vault \
      --hostname=benchmark-vault \
      --network=docker-compose_vault_c1 \
      hashicorp/benchmark-vault:0.0.0-dev \
      benchmark-vault -vault_addr=http://vault_c1_s1:8200 -vault_token=${VAULT_TOKEN} -pct_approle_login=100 -duration=120s -rps=5

create-cert-login:
	docker run \
      --rm \
      --name=benchmark-vault \
      --hostname=benchmark-vault \
      --network=docker-compose_vault_c1 \
      hashicorp/benchmark-vault:0.0.0-dev \
      benchmark-vault -vault_addr=http://vault_c1_s1:8200 -vault_token=${VAULT_TOKEN} -pct_cert_login=100 -duration=120s -rps=5
