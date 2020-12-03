resource "aws_ssm_document" "graceful_patch_instance" {
  name            = "PatchInstanceGraceful"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/graceful_patch_instance.yml",
    {
      patch_with_healthcheck_document_arn = aws_ssm_document.patch_with_healthcheck.arn,
    }
  )
}
