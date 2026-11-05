output "vault_kms" {
  description = "The vault created, or null"
  value = length(oci_kms_vault.this) > 0 ? {
    id                                    = one(oci_kms_vault.this[*].id)
    name                                  = one(oci_kms_vault.this[*].display_name)
    type                                  = one(oci_kms_vault.this[*].vault_type)
    endpoint                              = one(oci_kms_vault.this[*].management_endpoint)
    crypto_endpoint                       = one(oci_kms_vault.this[*].crypto_endpoint)
    defined_tags                          = one(oci_kms_vault.this[*].defined_tags)
    freeform_tags                         = one(oci_kms_vault.this[*].freeform_tags)
    external_key_manager_metadata_summary = one(oci_kms_vault.this[*].external_key_manager_metadata_summary)
    is_primary                            = one(oci_kms_vault.this[*].is_primary)
    is_vault_replicable                   = one(oci_kms_vault.this[*].is_vault_replicable)
    replica_details                       = one(oci_kms_vault.this[*].replica_details)
    restored_from_vault_id                = one(oci_kms_vault.this[*].restored_from_vault_id)
    state                                 = one(oci_kms_vault.this[*].state)
    time_created                          = one(oci_kms_vault.this[*].time_created)
    time_of_deletion                      = one(oci_kms_vault.this[*].time_of_deletion)
  } : null
}

output "kms_key" {
  description = "The master encryption key created, or null"
  value = length(oci_kms_key.this) > 0 ? {
    auto_key_rotation_details      = one(oci_kms_key.this[*].auto_key_rotation_details)
    compartment_id                 = one(oci_kms_key.this[*].compartment_id)
    current_key_version            = one(oci_kms_key.this[*].current_key_version)
    defined_tags                   = one(oci_kms_key.this[*].defined_tags)
    freeform_tags                  = one(oci_kms_key.this[*].freeform_tags)
    display_name                   = one(oci_kms_key.this[*].display_name)
    external_key_reference_details = one(oci_kms_key.this[*].external_key_reference_details)
    id                             = one(oci_kms_key.this[*].id)
    is_auto_rotation_enabled       = one(oci_kms_key.this[*].is_auto_rotation_enabled)
    is_primary                     = one(oci_kms_key.this[*].is_primary)
    key_shape                      = one(oci_kms_key.this[*].key_shape)
    protection_mode                = one(oci_kms_key.this[*].protection_mode)
    replica_details                = one(oci_kms_key.this[*].replica_details)
    restored_from_key_id           = one(oci_kms_key.this[*].restored_from_key_id)
    state                          = one(oci_kms_key.this[*].state)
    time_created                   = one(oci_kms_key.this[*].time_created)
    time_of_deletion               = one(oci_kms_key.this[*].time_of_deletion)
    vault_id                       = one(oci_kms_key.this[*].vault_id)
  } : null
}

output "vault_secrets" {
  description = "Secrets created, keyed like vault_secrets"
  value = {
    for k, s in oci_vault_secret.this :
    k => {
      id                             = s.id
      name                           = s.secret_name
      secret_rules                   = s.secret_rules
      description                    = s.description
      compartment_id                 = s.compartment_id
      is_auto_generation_enabled     = s.is_auto_generation_enabled
      is_replica                     = s.is_replica
      vault_id                       = s.vault_id
      key_id                         = s.key_id
      current_version                = s.current_version_number
      defined_tags                   = s.defined_tags
      freeform_tags                  = s.freeform_tags
      metadata                       = s.metadata
      rotation_config                = s.rotation_config
      rotation_status                = s.rotation_status
      last_rotation_time             = s.last_rotation_time
      next_rotation_time             = s.next_rotation_time
      lifecycle_details              = s.lifecycle_details
      replication_config             = s.replication_config
      secret_generation_context      = s.secret_generation_context
      source_region_information      = s.source_region_information
      state                          = s.state
      time_created                   = s.time_created
      time_of_current_version_expiry = s.time_of_current_version_expiry
      time_of_deletion               = s.time_of_deletion
    }
  }
}

output "ekms_private_endpoint" {
  description = "The EKMS private endpoint created, or null"
  value = length(oci_kms_ekms_private_endpoint.this) > 0 ? {
    ca_bundle               = one(oci_kms_ekms_private_endpoint.this[*].ca_bundle)
    compartment_id          = one(oci_kms_ekms_private_endpoint.this[*].compartment_id)
    display_name            = one(oci_kms_ekms_private_endpoint.this[*].display_name)
    external_key_manager_ip = one(oci_kms_ekms_private_endpoint.this[*].external_key_manager_ip)
    subnet_id               = one(oci_kms_ekms_private_endpoint.this[*].subnet_id)
    defined_tags            = one(oci_kms_ekms_private_endpoint.this[*].defined_tags)
    freeform_tags           = one(oci_kms_ekms_private_endpoint.this[*].freeform_tags)
  } : null
}

output "random_passwords" {
  description = "Generated random passwords, keyed like vault_secrets"
  value       = { for k, v in random_password.this : k => v.result }
}

output "tls_private_key" {
  description = "Generated TLS key pairs, keyed like vault_secrets"
  value = { for k, v in tls_private_key.this : k => {
    id                            = v.id
    algorithm                     = v.algorithm
    ecdsa_curve                   = v.ecdsa_curve
    private_key_openssh           = v.private_key_openssh
    public_key_openssh            = v.public_key_openssh
    private_key_pem               = v.private_key_pem
    private_key_pem_pkcs8         = v.private_key_pem_pkcs8
    public_key_fingerprint_md5    = v.public_key_fingerprint_md5
    public_key_fingerprint_sha256 = v.public_key_fingerprint_sha256
    public_key_pem                = v.public_key_pem
    rsa_bits                      = v.rsa_bits
    }
  }
}
