resource "aws_ssm_document" "patch_with_healthcheck" {
  name            = "PatchWithHealthcheck"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/patch_with_healthcheck_template.yml",
    {
      healthcheck_document_arn   = aws_ssm_document.perform_healthcheck_s3.arn,
      output_s3_bucket_name   = aws_s3_bucket.script_bucket.id,
      output_s3_key_prefix     = "ssm_output/",
    }
  )
}

// TODO
// Change doc to allow custom document to be executed once instance is out of rotation
resource "aws_ssm_document" "graceful_patch_instance" {
  name            = "PatchInstanceGraceful"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile(
    "documents/graceful_patch_instance.yml",
    {
      patch_with_healthcheck_document_arn   = aws_ssm_document.patch_with_healthcheck.arn,
    }
  )
}

// TODO dynamic TG lookup needs a diff structure:
// 1. get TGs for instance (use aws:executeScript)
// 2. invoke automations or script to deregister instance from all TGs, confirm it has deregistered
// 3. invoke the patch automation doc, if failed then do step 5 
// 4. invoke automations pr script to register instance back to all TGs, confirm it has registered back
# resource "aws_ssm_document" "graceful_patch_instance_no_tg" {
#   name            = "PatchInstanceGracefulNoTgUNFINISHED"
#   document_type   = "Automation"
#   document_format = "YAML"

#   content = templatefile(
#     "documents/graceful_patch_instance_no_tg.yml",
#     {
#       patch_with_healthcheck_document_arn   = aws_ssm_document.patch_with_healthcheck.arn,
#     }
#   )
# }

