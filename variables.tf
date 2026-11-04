variable "compartment_id" {
  description = "OCID of the compartment that holds the vault, the key and the EKMS private endpoint"
  type        = string
}
variable "vault" {
  description = "Vault to create. Null creates none; secrets then need vault_id."
  type = object({
    display_name  = string
    vault_type    = optional(string, "DEFAULT")
    defined_tags  = optional(map(string))
    freeform_tags = optional(map(string))

    external_key_manager_metadata = optional(object({
      external_vault_endpoint_url = string
      private_endpoint_id         = optional(string)
      oauth_metadata = object({
        client_app_id         = string
        client_app_secret     = string
        idcs_account_name_url = string
      })
    }))
  })
  default = null
}
variable "kms_key" {
  description = "Master encryption key to create, in the vault from this call or in the vault whose management_endpoint is set. Null creates none; secrets then need key_id."
  type = object({
    display_name        = string
    management_endpoint = optional(string)
    key_shape = object({
      algorithm = string
      length    = number
      curve_id  = optional(string)
    })
    external_key_reference = optional(object({
      external_key_id = string
    }))
    restore_from_file = optional(object({
      content_length                = string
      content_md5                   = optional(string)
      restore_key_from_file_details = string
    }))
    auto_key_rotation_details = optional(object({
      last_rotation_message     = optional(string)
      last_rotation_status      = optional(string)
      rotation_interval_in_days = optional(number)
      time_of_last_rotation     = optional(string)
      time_of_next_rotation     = optional(string)
      time_of_schedule_start    = optional(string)
    }))
    restore_from_object_store = optional(object({
      bucket      = optional(string)
      destination = string
      namespace   = optional(string)
      object      = optional(string)
      uri         = optional(string)
    }))
    enable_auto_key_rotation = optional(bool, false)
    protection_mode          = optional(string)
    desired_state            = optional(string)
    time_of_deletion         = optional(string)
    restore_trigger          = optional(string)
    defined_tags             = optional(map(string))
    freeform_tags            = optional(map(string))
  })
  default = null
}
variable "vault_secrets" {
  description = "Secrets to create, keyed by secret name. Each sets exactly one of secret_content.content, random_password, random_bytes or tls_private_key."
  type = map(object({
    name                = optional(string)
    compartment_id      = string
    vault_id            = optional(string)
    key_id              = optional(string)
    use_random_suffix   = optional(bool, false)
    vault_suffix_lenght = optional(number, 4)
    secret_name         = optional(string)
    description         = optional(string)

    defined_tags  = optional(map(string))
    freeform_tags = optional(map(string))
    metadata      = optional(map(string))

    enable_auto_generation = optional(bool, false)

    secret_content = optional(object({
      content_type = optional(string, "BASE64")
      content      = optional(string)
      random_password = optional(object({
        length           = optional(number, 16)
        special          = optional(bool, true)
        override_special = optional(string, "!_-.~")
      }))
      random_bytes = optional(object({
        length   = optional(number, 32)
        keepers  = optional(map(string))
        encoding = optional(string, "hex")
      }))
      tls_private_key = optional(object({
        ecdsa_curve = optional(string)
        algorithm   = optional(string, "ED25519")
        rsa_bits    = optional(number)
      }))
      name  = optional(string)
      stage = optional(string)
    }))

    secret_generation_context = optional(object({
      generation_template = optional(string, "DBAAS_DEFAULT_PASSWORD")
      generation_type     = optional(string, "PASSPHRASE")
      passphrase_length   = optional(number, 14)
      secret_template     = optional(any)
    }))

    replication_config = optional(object({
      is_write_forward_enabled = optional(bool)

      replication_targets = optional(list(object({
        target_region   = string
        target_vault_id = string
        target_key_id   = string
      })))
    }))

    rotation_config = optional(object({
      is_scheduled_rotation_enabled = optional(bool)
      rotation_interval             = optional(string)

      target_system_details = object({
        target_system_type = string
        adb_id             = optional(string)
        function_id        = optional(string)
      })
    }))

    secret_rules = optional(list(object({
      rule_type = string

      is_enforced_on_deleted_secret_versions        = optional(bool)
      is_secret_content_retrieval_blocked_on_expiry = optional(bool)
      secret_version_expiry_interval                = optional(string)
      time_of_absolute_expiry                       = optional(string)
    })))
  }))
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.vault_secrets : (
        (try(v.secret_content.content != null, false) ? 1 : 0) +
        (try(v.secret_content.random_password != null, false) ? 1 : 0) +
        (try(v.secret_content.tls_private_key != null, false) ? 1 : 0) +
        (try(v.secret_content.random_bytes != null, false) ? 1 : 0)
      ) == 1
    ])
    error_message = "Each secret must define exactly one of: content, random_password, tls_private_key or random_bytes."
  }
  validation {
    condition = alltrue([
      for k, v in var.vault_secrets :
      contains(["hex", "base64"], try(v.secret_content.random_bytes.encoding, "hex"))
    ])
    error_message = "random_bytes.encoding must be either \"hex\" or \"base64\"."
  }
}
variable "ekms_private_endpoint" {
  description = "Private endpoint to an external key manager. Null creates none."
  type = object({
    ca_bundle               = string
    compartment_id          = string
    display_name            = string
    external_key_manager_ip = string
    subnet_id               = string
    port                    = string
    defined_tags            = optional(map(string))
    freeform_tags           = optional(map(string))
  })
  default = null
}
