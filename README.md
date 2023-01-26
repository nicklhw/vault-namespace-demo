# Vault Namespace Demo

# Run

```shell
# export Vault license
export VAULT_LICENSE=$(cat ~/Downloads/vault.hclic)     

# Start all containers and minikube
make all

# Port forward and open web page to view secret
kubectl port-forward <name of app pod> -n us-east 8080:8080

open http://127.0.0.1:8080
```

# Vault Users
```shell
# Userpass
admin/passw0rd

# LDAP
nwong/passw0rd
```

# Reference
- [LDAP container reference](https://github.com/Crivaledaz/Mattermost-LDAP)
- [Integrate a K8s cluster with an external Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-external-vault)
- [Active Directory management tip](https://activedirectorypro.com/active-directory-management-tips/)
- [Debugging Kubernetes Auth](https://support.hashicorp.com/hc/en-us/articles/4404389946387-Kubernetes-auth-method-Permission-Denied-error#:~:text=This%20error%20message%20is%20usually,auth%20is%20not%20configured%20properly)
- [Kubernetes Token Review And Authentication](https://medium.com/@hajsanad/kubernetes-token-review-and-authentication-56e06cc55ed3)