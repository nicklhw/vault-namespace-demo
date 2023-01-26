# Manage policies
path "${namespace}/sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "${namespace}/sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "${namespace}/sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "${namespace}/sys/mounts" {
  capabilities = [ "read" ]
}

# Introspect capabilities
path "${namespace}/sys/capabilities-self" {
   capabilities = ["update"]
}

# Create and manage entities and groups
path "${namespace}/identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "${namespace}/auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets at 'secret'
path "${namespace}/secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
