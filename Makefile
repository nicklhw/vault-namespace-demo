.DEFAULT_GOAL := all
.PHONY: clean up-detach init show-members ui token

export VAULT_TOKEN := $(shell cat docker-compose/scripts/vault.json | jq -r '.root_token')
export VAULT_ADDR := http://localhost:8200

all: clean up-detach init

up-detach:
	cd docker-compose \
	  && docker-compose up --detach --remove-orphans

init:
	cd docker-compose/scripts \
	  && ./init.sh

clean:
	cd docker-compose \
	&& docker-compose down --volumes \
	&& rm -f ./scripts/vault.json \
	&& rm -f ../terraform/terraform.tfstate \
	&& rm -f ../terraform/terraform.tfstate.backup

show-members:
	vault operator raft list-peers

logs:
	cd docker-compose \
    && docker-compose logs -f

ui:
	open http://localhost:8200

ldap-ui:
	open http://localhost:8081

token:
	cat docker-compose/scripts/vault_c1.json | jq -r '.root_token' | pbcopy

tf-apply:
	cd terraform \
	&& terraform init \
	&& terraform apply --auto-approve

tf-destroy:
	cd terraform \
	&& terraform destroy --auto-approve
