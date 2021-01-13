resource "aws_ssm_document" "graceful_reboot_instance" {
  name            = "RebootInstanceGraceful"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/graceful_patch_instance.yml",
    {
      reboot_with_healthcheck_document_arn = aws_ssm_document.reboot_with_healthcheck.arn,
    }
  )
}
