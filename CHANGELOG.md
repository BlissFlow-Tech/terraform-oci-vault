# Changelog

## [2.0.1](https://github.com/BlissFlow-Tech/terraform-oci-vault/compare/v2.0.0...v2.0.1) (2026-11-06)


### Bug Fixes

* drop the misleading sensitive = false on secret outputs ([#11](https://github.com/BlissFlow-Tech/terraform-oci-vault/issues/11)) ([d392a58](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/d392a581e2f6fd146518b1a4e998a3ad2541f532))

## [2.0.0](https://github.com/BlissFlow-Tech/terraform-oci-vault/compare/v1.0.0...v2.0.0) (2026-11-04)


### ⚠ BREAKING CHANGES

* rename vault_suffix_lenght to vault_suffix_length and drop unused name and secret_name

### Bug Fixes

* allow kms_key in an existing vault through management_endpoint ([439c93f](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/439c93f9b77b2b912ea3a566ad2e59df47187fbb))
* allow kms_key in an existing vault through management_endpoint ([f611c64](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/f611c64eb51c9919dca9540cb80d352fc6597c38))
* read restore_from_object_store attributes from the block value ([8e6d14f](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/8e6d14fb7cabc17bbd2c0f4d482856fa91a4a499))
* read restore_from_object_store attributes from the block value ([fbd2d88](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/fbd2d884317322702740ce122ffd67182cfe7445))
* rename vault_suffix_lenght to vault_suffix_length and drop unused name and secret_name ([b823f82](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/b823f820aa2d866ce30fe1fbcc614b979bd9adfe))
* set vault_kms whenever a vault is created ([c2b1cae](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/c2b1cae245b43942dfdaae7f32e3df3e08200b62))
* set vault_kms whenever a vault is created ([963ddd8](https://github.com/BlissFlow-Tech/terraform-oci-vault/commit/963ddd8091dfdf2b5385d882582a6ceeb88e29f0))
