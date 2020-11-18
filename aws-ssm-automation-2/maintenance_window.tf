# resource "aws_ssm_maintenance_window" "patch_with_healthcheck" {
#   name              = "PatchWithHealthcheck"
#   description       = "Daily patch event with a healthcheck afterward"
#   schedule          = "cron(0 9 ? * * *)" # Everyday at 9am UK time
#   schedule_timezone = "Europe/London"
#   duration          = 3
#   cutoff            = 1
# }

# resource "aws_ssm_maintenance_window_target" "patch_with_healthcheck_target" {
#   window_id     = aws_ssm_maintenance_window.patch_with_healthcheck.id
#   name          = "PatchWithHealthcheckTargets"
#   description   = "All instances that should be patched with a healthcheck after"
#   resource_type = "INSTANCE"

#   targets {
#     key = "InstanceIds"
#     values = concat(
#       module.windows_ec2.id,
#       module.linux_ec2.id
#     )
#   }

#   # Using tags is more scalable
#   #   targets {
#   #     key    = "tag:Terraform"
#   #     values = ["true"]
#   #   }
# }

# resource "aws_ssm_maintenance_window_task" "patch_task" {
#   window_id        = aws_ssm_maintenance_window.patch_with_healthcheck.id
#   task_type        = "RUN_COMMAND"
#   task_arn         = "AWS-RunPatchBaseline"
#   priority         = 10
#   service_role_arn = aws_iam_role.patch_mw_role.arn

#   max_concurrency = "100%"
#   max_errors      = 0

#   targets {
#     key    = "WindowTargetIds"
#     values = [aws_ssm_maintenance_window_target.patch_with_healthcheck_target.id]
#   }

#   task_invocation_parameters {
#     run_command_parameters {
#       timeout_seconds      = 3600
#       output_s3_bucket     = aws_s3_bucket.script_bucket.id
#       output_s3_key_prefix = "ssm_output/"

#       parameter {
#         name   = "Operation"
#         values = ["Scan"]
#       }
#     }
#   }
# }

# resource "aws_ssm_maintenance_window_task" "healthcheck_task" {
#   window_id        = aws_ssm_maintenance_window.patch_with_healthcheck.id
#   task_type        = "RUN_COMMAND"
#   task_arn         = aws_ssm_document.perform_healthcheck_s3.arn
#   priority         = 20
#   service_role_arn = aws_iam_role.patch_mw_role.arn

#   max_concurrency = "100%"
#   max_errors      = 0

#   targets {
#     key    = "WindowTargetIds"
#     values = [aws_ssm_maintenance_window_target.patch_with_healthcheck_target.id]
#   }

#   task_invocation_parameters {
#     run_command_parameters {
#       timeout_seconds      = 600
#       output_s3_bucket     = aws_s3_bucket.script_bucket.id
#       output_s3_key_prefix = "ssm_output/"
#     }
#   }
# }
