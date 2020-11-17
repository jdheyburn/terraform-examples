data "aws_iam_policy_document" "kms_allow_decrypt" {
  statement {
    sid    = "AllowKMSAdministration"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/jdheyburn"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "AllowEncryptAndDecrypt"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      # TIP: For increased security only give decrypt permissions to roles that need it
      # identifiers = [aws_iam_role.vm_base.arn]
    }

    resources = ["*"]
  }
}

resource "aws_kms_key" "script_bucket_key" {
  description = "This key is used to encrypt bucket objects"
  policy      = data.aws_iam_policy_document.kms_allow_decrypt.json
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

  # Remove old SSM command output logs
  lifecycle_rule {
    id = "RemoveOldSSMOutputLogs"
    enabled = true

    prefix = "ssm_output/"

    expiration {
      days = 90
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_allow_script_download" {
  statement {
    sid    = "AllowAccountS3GetAccess"
    effect = "Allow"

    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      # TIP: For increased security only give decrypt permissions to roles that need it
      # identifiers = [aws_iam_role.vm_base.arn]
    }

    resources = ["${aws_s3_bucket.script_bucket.arn}/ssm_scripts/*"]
  }

  statement {
    sid    = "AllowAccountS3PutAccess"
    effect = "Allow"

    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      # TIP: For increased security only give decrypt permissions to roles that need it
      # identifiers = [aws_iam_role.vm_base.arn]
    }

    resources = ["${aws_s3_bucket.script_bucket.arn}/ssm_output/*"]
  }
}

resource "aws_s3_bucket_policy" "script_bucket_policy" {
  bucket = aws_s3_bucket.script_bucket.id
  policy = data.aws_iam_policy_document.s3_allow_script_download.json
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
      bucket_name   = aws_s3_bucket.script_bucket.id,
      linux_fname   = local.perform_healthcheck_script_fname_linux,
      linux_key     = aws_s3_bucket_object.perform_healthcheck_linux.id,
      windows_fname = local.perform_healthcheck_script_fname_windows,
      windows_key   = aws_s3_bucket_object.perform_healthcheck_windows.id,
    }
  )
}
