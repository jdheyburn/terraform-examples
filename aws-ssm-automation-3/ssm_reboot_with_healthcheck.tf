resource "aws_ssm_document" "reboot_with_healthcheck" {
  name            = "RebootWithHealthcheck"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/reboot_with_healthcheck_template.yml",
    {
      output_s3_bucket_name    = aws_s3_bucket.script_bucket.id,
      output_s3_key_prefix     = "ssm_output/",
    }
  )
}

