# Vault Namespace Demo

# TODO
- stand up LDAP server, MiniKube, and Vault in docker
- Setup LDAP auth, Kube Auth, and Vault Namespace structure

# Run

```shell
# Start all containers
make all

# Bring up php LDAP admin UI
# Login with cn=admin,dc=example,dc=com / admin
make ldap-ui
```