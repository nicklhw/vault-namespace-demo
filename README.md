# Vault Namespace Demo

# Run

```shell
# Start minikube
minikube start

# export Vault license
export VAULT_LICENSE=$(cat ~/Downloads/vault.hclic)     

# Start all containers
make all

# terraform apply
make tf-apply

# deploy k8s app
make deploy-app

```

# Reference
- [LDAP container reference](https://github.com/Crivaledaz/Mattermost-LDAP)
- [Integrate a K8s cluster with an external Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-external-vault)
- [Active Directory management tip](https://activedirectorypro.com/active-directory-management-tips/)