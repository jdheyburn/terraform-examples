resource "aws_ssm_maintenance_window" "patch_with_healthcheck" {
  name              = "PatchWithHealthcheck"
  description       = "Daily patch event with a healthcheck afterward"
  schedule          = "cron(0 9 ? * * *)" # Everyday at 9am UK time
  schedule_timezone = "Europe/London"
  duration          = 3
  cutoff            = 1
}

resource "aws_ssm_maintenance_window_target" "patch_with_healthcheck_target" {
  window_id     = aws_ssm_maintenance_window.patch_with_healthcheck.id
  name          = "PatchWithHealthcheckTargets"
  description   = "All instances that should be patched with a healthcheck after"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:App"
    values = ["HelloWorld"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_with_healthcheck" {
  window_id        = aws_ssm_maintenance_window.patch_with_healthcheck.id
  task_type        = "AUTOMATION"
  task_arn         = aws_ssm_document.patch_with_healthcheck.arn
  priority         = 10
  service_role_arn = aws_iam_role.patch_mw_role.arn

  max_concurrency = "1"
  max_errors      = 0

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_with_healthcheck_target.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name = "InstanceIds"
        values = ["{{ TARGET_ID }}"]
      }
    }
  }
}
