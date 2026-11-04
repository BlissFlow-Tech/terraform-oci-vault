module "vault" {
  source = "../.."

  compartment_id = var.compartment_id

  vault = {
    display_name = "app-vault"
  }

  kms_key = {
    display_name = "app-key"
    key_shape = {
      algorithm = "AES"
      length    = 32
    }
  }

  vault_secrets = {
    db-password = {
      compartment_id = var.compartment_id
      secret_content = {
        random_password = {
          length = 24
        }
      }
    }
    session-key = {
      compartment_id    = var.compartment_id
      use_random_suffix = true
      secret_content = {
        random_bytes = {
          length = 32
        }
      }
    }
  }
}

output "secret_ids" {
  value = { for k, s in module.vault.vault_secrets : k => s.id }
}
