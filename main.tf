resource "random_password" "this" {
  for_each = nonsensitive({
    for k, v in var.vault_secrets : k => v
    if try(v.secret_content.random_password != null, false)
  })
  length           = each.value.secret_content.random_password.length
  special          = each.value.secret_content.random_password.special
  override_special = each.value.secret_content.random_password.override_special
}

resource "tls_private_key" "this" {
  for_each = nonsensitive({
    for k, v in var.vault_secrets : k => v
    if try(v.secret_content.tls_private_key != null, false)
  })
  ecdsa_curve = each.value.secret_content.tls_private_key.ecdsa_curve
  algorithm   = each.value.secret_content.tls_private_key.algorithm
  rsa_bits    = each.value.secret_content.tls_private_key.rsa_bits
}

resource "random_bytes" "this" {
  for_each = nonsensitive({
    for k, v in var.vault_secrets : k => v
    if try(v.secret_content.random_bytes != null, false)
  })
  length  = each.value.secret_content.random_bytes.length
  keepers = each.value.secret_content.random_bytes.keepers
}

resource "random_id" "vault_suffix" {
  for_each = nonsensitive({
    for k, v in var.vault_secrets : k => v
    if try(v.use_random_suffix == true, false)
  })
  byte_length = each.value.vault_suffix_lenght
}

resource "oci_kms_vault" "this" {
  count          = var.vault != null ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = var.vault.display_name
  vault_type     = var.vault.vault_type
  defined_tags   = var.vault.defined_tags
  freeform_tags  = var.vault.freeform_tags

  dynamic "external_key_manager_metadata" {
    for_each = var.vault.external_key_manager_metadata != null ? [var.vault.external_key_manager_metadata] : []
    content {
      external_vault_endpoint_url = external_key_manager_metadata.value.external_vault_endpoint_url
      private_endpoint_id         = external_key_manager_metadata.value.private_endpoint_id
      oauth_metadata {
        client_app_id         = external_key_manager_metadata.value.oauth_metadata.client_app_id
        client_app_secret     = external_key_manager_metadata.value.oauth_metadata.client_app_secret
        idcs_account_name_url = external_key_manager_metadata.value.oauth_metadata.idcs_account_name_url
      }
    }
  }
}

resource "oci_kms_key" "this" {
  count          = var.kms_key != null ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = var.kms_key.display_name

  key_shape {
    algorithm = var.kms_key.key_shape.algorithm
    length    = var.kms_key.key_shape.length
    curve_id  = var.kms_key.key_shape.curve_id
  }
  dynamic "external_key_reference" {
    for_each = var.kms_key.external_key_reference != null ? [var.kms_key.external_key_reference] : []
    content {
      external_key_id = external_key_reference.value.external_key_id
    }
  }
  time_of_deletion = var.kms_key.time_of_deletion
  desired_state    = var.kms_key.desired_state
  restore_trigger  = var.kms_key.restore_trigger

  is_auto_rotation_enabled = var.kms_key.enable_auto_key_rotation
  management_endpoint      = oci_kms_vault.this[0].management_endpoint
  dynamic "auto_key_rotation_details" {
    for_each = var.kms_key.auto_key_rotation_details != null ? [var.kms_key.auto_key_rotation_details] : []
    content {
      last_rotation_message     = auto_key_rotation_details.value.last_rotation_message
      last_rotation_status      = auto_key_rotation_details.value.last_rotation_status
      rotation_interval_in_days = auto_key_rotation_details.value.rotation_interval_in_days
      time_of_last_rotation     = auto_key_rotation_details.value.time_of_last_rotation
      time_of_next_rotation     = auto_key_rotation_details.value.time_of_next_rotation
      time_of_schedule_start    = auto_key_rotation_details.value.time_of_schedule_start
    }
  }
  dynamic "restore_from_file" {
    for_each = var.kms_key.restore_from_file != null ? [var.kms_key.restore_from_file] : []
    content {
      content_length                = restore_from_file.value.content_length
      restore_key_from_file_details = restore_from_file.value.restore_key_from_file_details
      content_md5                   = restore_from_file.value.content_md5
    }
  }
  dynamic "restore_from_object_store" {
    for_each = var.kms_key.restore_from_object_store != null ? [var.kms_key.restore_from_object_store] : []
    content {
      destination = restore_from_object_store.value.destination
      bucket      = restore_from_object_store.value.bucket
      namespace   = restore_from_object_store.value.namespace
      object      = restore_from_object_store.value.object
      uri         = restore_from_object_store.value.uri
    }
  }

  protection_mode = var.kms_key.protection_mode
  defined_tags    = var.kms_key.defined_tags
  freeform_tags   = var.kms_key.freeform_tags
}

resource "oci_vault_secret" "this" {
  for_each = var.vault_secrets

  compartment_id = each.value.compartment_id
  vault_id       = each.value.vault_id == null ? oci_kms_vault.this[0].id : each.value.vault_id
  key_id         = each.value.key_id == null ? oci_kms_key.this[0].id : each.value.key_id
  secret_name    = each.value.use_random_suffix ? "${each.key}-${random_id.vault_suffix[each.key].hex}" : each.key

  description            = each.value.description
  enable_auto_generation = each.value.enable_auto_generation
  defined_tags           = each.value.defined_tags
  freeform_tags          = each.value.freeform_tags
  metadata               = each.value.metadata

  dynamic "secret_content" {
    for_each = each.value.enable_auto_generation == false ? [each.value.secret_content] : []
    content {
      content_type = secret_content.value.content_type
      content = secret_content.value.content != null ? base64encode(secret_content.value.content) : try(
        base64encode(
          secret_content.value.random_bytes.encoding == "base64"
          ? random_bytes.this[each.key].base64
          : random_bytes.this[each.key].hex
        ),
        base64encode(tls_private_key.this[each.key].private_key_pem),
        base64encode(random_password.this[each.key].result)
      )
      name  = secret_content.value.name
      stage = secret_content.value.stage
    }
  }

  dynamic "secret_generation_context" {
    for_each = each.value.secret_generation_context != null ? [each.value.secret_generation_context] : []
    content {
      generation_template = secret_generation_context.value.generation_template
      generation_type     = secret_generation_context.value.generation_type
      passphrase_length   = secret_generation_context.value.passphrase_length
      secret_template     = jsonencode(secret_generation_context.value.secret_template)
    }
  }

  dynamic "replication_config" {
    for_each = each.value.replication_config != null ? [each.value.replication_config] : []
    content {
      is_write_forward_enabled = replication_config.value.is_write_forward_enabled

      dynamic "replication_targets" {
        for_each = replication_config.value.replication_targets
        content {
          target_region   = replication_targets.value.target_region
          target_vault_id = replication_targets.value.target_vault_id
          target_key_id   = replication_targets.value.target_key_id
        }
      }
    }
  }

  dynamic "rotation_config" {
    for_each = each.value.rotation_config != null ? [each.value.rotation_config] : []
    content {
      is_scheduled_rotation_enabled = rotation_config.value.is_scheduled_rotation_enabled
      rotation_interval             = rotation_config.value.rotation_interval

      target_system_details {
        target_system_type = rotation_config.value.target_system_details.target_system_type
        adb_id             = rotation_config.value.target_system_details.adb_id
        function_id        = rotation_config.value.target_system_details.function_id
      }
    }
  }

  dynamic "secret_rules" {
    for_each = each.value.secret_rules != null ? each.value.secret_rules : []
    content {
      rule_type = secret_rules.value.rule_type

      is_enforced_on_deleted_secret_versions        = secret_rules.value.is_enforced_on_deleted_secret_versions
      is_secret_content_retrieval_blocked_on_expiry = secret_rules.value.is_secret_content_retrieval_blocked_on_expiry
      secret_version_expiry_interval                = secret_rules.value.secret_version_expiry_interval
      time_of_absolute_expiry                       = secret_rules.value.time_of_absolute_expiry
    }
  }
}

resource "oci_kms_ekms_private_endpoint" "this" {
  count                   = var.ekms_private_endpoint != null ? 1 : 0
  ca_bundle               = var.ekms_private_endpoint.ca_bundle
  compartment_id          = var.compartment_id
  display_name            = var.ekms_private_endpoint.display_name
  external_key_manager_ip = var.ekms_private_endpoint.external_key_manager_ip
  subnet_id               = var.ekms_private_endpoint.subnet_id
  port                    = var.ekms_private_endpoint.port
  defined_tags            = var.ekms_private_endpoint.defined_tags
  freeform_tags           = var.ekms_private_endpoint.freeform_tags
}
