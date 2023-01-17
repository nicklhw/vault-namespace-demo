terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.7.0"
    }
  }
}

provider "vault" {
  address = "http://localhost:8200"
}

resource "vault_ldap_auth_backend" "ldap" {
  path       = "ldap"
  url        = "ldap://ldap"
  userdn     = "ou=People,dc=example,dc=com"
  binddn     = "cn=admin,dc=example,dc=com"
  bindpass   = "admin"
  userattr   = "uid"
  discoverdn = false
}