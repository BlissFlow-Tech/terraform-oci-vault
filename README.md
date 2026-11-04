# terraform-oci-vault

Terraform module that manages an OCI Vault, a master encryption key and secrets whose content is supplied or generated.

## Usage

```hcl
module "vault" {
  source  = "blissflow-tech/vault/oci"
  version = "~> 1.0"

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
    api-token = {
      compartment_id = var.compartment_id
      vault_id       = var.existing_vault_id
      key_id         = var.existing_key_id
      secret_content = {
        content = var.api_token
      }
    }
  }
}
```

## Notes

* Each secret sets exactly one content source: `content` (plain text, base64-encoded by the module), `random_password`, `random_bytes` (`hex` or `base64`) or `tls_private_key` (stored as PEM).
* Secrets use the vault and key created by this call unless `vault_id` and `key_id` are set. A key is created in the vault from the same call, or in an existing vault when `kms_key.management_endpoint` is set.
* The secret name is the map key; `use_random_suffix = true` appends a random hex suffix.
* The `random_passwords` and `tls_private_key` outputs are not marked sensitive. Treat the state and plan output as secret.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.3 |
| oci | >= 8.0, < 10.0 |
| random | >= 3.0, < 4.0 |
| tls | >= 4.0, < 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| oci | >= 8.0, < 10.0 |
| random | >= 3.0, < 4.0 |
| tls | >= 4.0, < 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [oci_kms_ekms_private_endpoint.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_ekms_private_endpoint) | resource |
| [oci_kms_key.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_vault) | resource |
| [oci_vault_secret.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |
| [random_bytes.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/bytes) | resource |
| [random_id.vault_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| compartment\_id | OCID of the compartment that holds the vault, the key and the EKMS private endpoint | `string` | n/a | yes |
| ekms\_private\_endpoint | Private endpoint to an external key manager. Null creates none. | <pre>object({<br/>    ca_bundle               = string<br/>    compartment_id          = string<br/>    display_name            = string<br/>    external_key_manager_ip = string<br/>    subnet_id               = string<br/>    port                    = string<br/>    defined_tags            = optional(map(string))<br/>    freeform_tags           = optional(map(string))<br/>  })</pre> | `null` | no |
| kms\_key | Master encryption key to create, in the vault from this call or in the vault whose management\_endpoint is set. Null creates none; secrets then need key\_id. | <pre>object({<br/>    display_name        = string<br/>    management_endpoint = optional(string)<br/>    key_shape = object({<br/>      algorithm = string<br/>      length    = number<br/>      curve_id  = optional(string)<br/>    })<br/>    external_key_reference = optional(object({<br/>      external_key_id = string<br/>    }))<br/>    restore_from_file = optional(object({<br/>      content_length                = string<br/>      content_md5                   = optional(string)<br/>      restore_key_from_file_details = string<br/>    }))<br/>    auto_key_rotation_details = optional(object({<br/>      last_rotation_message     = optional(string)<br/>      last_rotation_status      = optional(string)<br/>      rotation_interval_in_days = optional(number)<br/>      time_of_last_rotation     = optional(string)<br/>      time_of_next_rotation     = optional(string)<br/>      time_of_schedule_start    = optional(string)<br/>    }))<br/>    restore_from_object_store = optional(object({<br/>      bucket      = optional(string)<br/>      destination = string<br/>      namespace   = optional(string)<br/>      object      = optional(string)<br/>      uri         = optional(string)<br/>    }))<br/>    enable_auto_key_rotation = optional(bool, false)<br/>    protection_mode          = optional(string)<br/>    desired_state            = optional(string)<br/>    time_of_deletion         = optional(string)<br/>    restore_trigger          = optional(string)<br/>    defined_tags             = optional(map(string))<br/>    freeform_tags            = optional(map(string))<br/>  })</pre> | `null` | no |
| vault | Vault to create. Null creates none; secrets then need vault\_id. | <pre>object({<br/>    display_name  = string<br/>    vault_type    = optional(string, "DEFAULT")<br/>    defined_tags  = optional(map(string))<br/>    freeform_tags = optional(map(string))<br/><br/>    external_key_manager_metadata = optional(object({<br/>      external_vault_endpoint_url = string<br/>      private_endpoint_id         = optional(string)<br/>      oauth_metadata = object({<br/>        client_app_id         = string<br/>        client_app_secret     = string<br/>        idcs_account_name_url = string<br/>      })<br/>    }))<br/>  })</pre> | `null` | no |
| vault\_secrets | Secrets to create, keyed by secret name. Each sets exactly one of secret\_content.content, random\_password, random\_bytes or tls\_private\_key. | <pre>map(object({<br/>    name                = optional(string)<br/>    compartment_id      = string<br/>    vault_id            = optional(string)<br/>    key_id              = optional(string)<br/>    use_random_suffix   = optional(bool, false)<br/>    vault_suffix_lenght = optional(number, 4)<br/>    secret_name         = optional(string)<br/>    description         = optional(string)<br/><br/>    defined_tags  = optional(map(string))<br/>    freeform_tags = optional(map(string))<br/>    metadata      = optional(map(string))<br/><br/>    enable_auto_generation = optional(bool, false)<br/><br/>    secret_content = optional(object({<br/>      content_type = optional(string, "BASE64")<br/>      content      = optional(string)<br/>      random_password = optional(object({<br/>        length           = optional(number, 16)<br/>        special          = optional(bool, true)<br/>        override_special = optional(string, "!_-.~")<br/>      }))<br/>      random_bytes = optional(object({<br/>        length   = optional(number, 32)<br/>        keepers  = optional(map(string))<br/>        encoding = optional(string, "hex")<br/>      }))<br/>      tls_private_key = optional(object({<br/>        ecdsa_curve = optional(string)<br/>        algorithm   = optional(string, "ED25519")<br/>        rsa_bits    = optional(number)<br/>      }))<br/>      name  = optional(string)<br/>      stage = optional(string)<br/>    }))<br/><br/>    secret_generation_context = optional(object({<br/>      generation_template = optional(string, "DBAAS_DEFAULT_PASSWORD")<br/>      generation_type     = optional(string, "PASSPHRASE")<br/>      passphrase_length   = optional(number, 14)<br/>      secret_template     = optional(any)<br/>    }))<br/><br/>    replication_config = optional(object({<br/>      is_write_forward_enabled = optional(bool)<br/><br/>      replication_targets = optional(list(object({<br/>        target_region   = string<br/>        target_vault_id = string<br/>        target_key_id   = string<br/>      })))<br/>    }))<br/><br/>    rotation_config = optional(object({<br/>      is_scheduled_rotation_enabled = optional(bool)<br/>      rotation_interval             = optional(string)<br/><br/>      target_system_details = object({<br/>        target_system_type = string<br/>        adb_id             = optional(string)<br/>        function_id        = optional(string)<br/>      })<br/>    }))<br/><br/>    secret_rules = optional(list(object({<br/>      rule_type = string<br/><br/>      is_enforced_on_deleted_secret_versions        = optional(bool)<br/>      is_secret_content_retrieval_blocked_on_expiry = optional(bool)<br/>      secret_version_expiry_interval                = optional(string)<br/>      time_of_absolute_expiry                       = optional(string)<br/>    })))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| ekms\_private\_endpoint | The EKMS private endpoint created, or null |
| kms\_key | The master encryption key created, or null |
| random\_passwords | Generated random passwords, keyed like vault\_secrets |
| tls\_private\_key | Generated TLS key pairs, keyed like vault\_secrets |
| vault\_kms | The vault created, or null when no key is created |
| vault\_secrets | Secrets created, keyed like vault\_secrets |
<!-- END_TF_DOCS -->

## License

Apache 2.0. See [LICENSE](LICENSE).
