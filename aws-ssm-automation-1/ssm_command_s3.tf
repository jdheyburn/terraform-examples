resource "aws_kms_key" "script_bucket_key" {
  description = "This key is used to encrypt bucket objects"
}

resource "aws_s3_bucket" "script_bucket" {
  bucket = "jdheyburn-scripts"

  # Encrypt objects stored in S3
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.script_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

locals {
  perform_healthcheck_script_fname_windows = "PerformHealthcheck.ps1"
  perform_healthcheck_script_fname_linux   = "perform_healthcheck.sh"
}

resource "aws_s3_bucket_object" "perform_healthcheck_windows" {
  bucket  = aws_s3_bucket.script_bucket.id
  key     = "ssm_scripts/${local.perform_healthcheck_script_fname_windows}"
  content = file("scripts/${local.perform_healthcheck_script_fname_windows}")
}

resource "aws_s3_bucket_object" "perform_healthcheck_linux" {
  bucket  = aws_s3_bucket.script_bucket.id
  key     = "ssm_scripts/${local.perform_healthcheck_script_fname_linux}"
  content = file("scripts/${local.perform_healthcheck_script_fname_linux}")
}

resource "aws_ssm_document" "perform_healthcheck_s3" {
  name            = "PerformHealthcheckS3"
  document_type   = "Command"
  document_format = "YAML"

  content = templatefile(
    "documents/perform_healthcheck_s3_template.yml",
    {
      bucket_name = aws_s3_bucket.script_bucket.id,
      linux_fname = local.perform_healthcheck_script_fname_linux,
      linux_key   = aws_s3_bucket_object.perform_healthcheck_linux.id,
      windows_fname = local.perform_healthcheck_script_fname_windows,
      windows_key = aws_s3_bucket_object.perform_healthcheck_windows.id,
    }
  )
}
