resource "aws_ssm_document" "maintenance_wrapper" {
  name            = "MaintenanceWithHealthcheck"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/maintenance_wrapper_template.yml",
    {
      healthcheck_document_arn = aws_ssm_document.perform_healthcheck_s3.arn,
      output_s3_bucket_name    = aws_s3_bucket.script_bucket.id,
      output_s3_key_prefix     = "ssm_output/",
    }
  )
}
