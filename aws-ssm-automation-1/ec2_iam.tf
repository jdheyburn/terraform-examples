data "aws_iam_policy_document" "vm_base_assume" {
  statement {
    sid     = "AllowEC2Assume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vm_base" {
  name = "vm-base"

  assume_role_policy = data.aws_iam_policy_document.vm_base_assume.json
}

data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "vm_base_ssm" {
  role       = aws_iam_role.vm_base.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "vm_base" {
  name = "vm-base"
  role = aws_iam_role.vm_base.name
}

data "aws_iam_policy_document" "ssm_scripts" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.script_bucket.arn}/ssm_scripts/*",
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"

    actions = ["kms:Decrypt"]

    resources = [aws_kms_key.script_bucket_key.arn]
  }
}

resource "aws_iam_policy" "ssm_scripts" {
  name        = "PullSSMScripts"
  description = "Enables instances to download SSM scripts from S3"

  policy = data.aws_iam_policy_document.ssm_scripts.json
}

resource "aws_iam_role_policy_attachment" "instance_download_scripts" {
  role       = aws_iam_role.vm_base.name
  policy_arn = aws_iam_policy.ssm_scripts.arn
}
