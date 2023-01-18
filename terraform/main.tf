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

variable "cs-child-namespaces" {
  default = [
    "us-east",
    "us-west"
  ]
}

locals {
  cs-child-namespaces = toset(var.cs-child-namespaces)
}

resource "vault_namespace" "customer-success" {
  path = "customer-success"
}

resource "vault_namespace" "cs-children" {
  for_each  = local.cs-child-namespaces
  namespace = vault_namespace.customer-success.path
  path      = each.key
}

data "template_file" "cs-us-east-vault-admin-policy" {
  template = "${file("${path.module}/ns_admin_policy.tpl")}"
  vars = {
    namespace = "${vault_namespace.cs-children["us-east"].path_fq}"
  }
}

data "template_file" "cs-us-west-vault-admin-policy" {
  template = "${file("${path.module}/ns_admin_policy.tpl")}"
  vars = {
    namespace = "${vault_namespace.cs-children["us-west"].path_fq}"
  }
}

resource "vault_policy" "cs-us-east-vault-admin" {
  name = "cs-us-east-vault-admin"
  policy = data.template_file.cs-us-east-vault-admin-policy.rendered
}

resource "vault_policy" "cs-us-west-vault-admin" {
  name = "cs-us-west-vault-admin"
  policy = data.template_file.cs-us-west-vault-admin-policy.rendered
}

resource "vault_ldap_auth_backend" "ldap" {
  path       = "ldap"
  url        = "ldap://ldap"
  userdn     = "ou=Users,dc=hashicorp,dc=com"
  groupdn    = "ou=Groups,dc=hashicorp,dc=com"
  binddn     = "cn=admin,dc=hashicorp,dc=com"
  bindpass   = "admin"
  userattr   = "uid"
  discoverdn = false
}

resource "vault_ldap_auth_backend_group" "cs-us-east-vault-admin" {
  groupname = "Customer Success US East Vault Admins"
  policies  = [vault_policy.cs-us-east-vault-admin.name]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_ldap_auth_backend_group" "cs-us-west-vault-admin" {
  groupname = "Customer Success US West Vault Admins"
  policies  = [vault_policy.cs-us-west-vault-admin.name]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_mount" "kvv2" {
  for_each  = local.cs-child-namespaces
  namespace = vault_namespace.cs-children[each.key].path_fq
  path      = "secrets"
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_generic_secret" "secret" {
  for_each  = local.cs-child-namespaces
  namespace = vault_mount.kvv2[each.key].namespace
  path      = "${vault_mount.kvv2[each.key].path}/myapp"
  data_json = jsonencode(
  {
    "ns" = each.key
  }
  )
}