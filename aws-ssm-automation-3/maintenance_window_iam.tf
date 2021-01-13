data "aws_iam_policy_document" "patch_mw_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "patch_mw_role" {
  name               = "PatchingMaintWindow"
  assume_role_policy = data.aws_iam_policy_document.patch_mw_role_assume.json
}

data "aws_iam_policy" "ssm_maintenance_window" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

resource "aws_iam_role_policy_attachment" "patch_mw_role_attach" {
  role       = aws_iam_role.patch_mw_role.name
  policy_arn = data.aws_iam_policy.ssm_maintenance_window.arn
}

data "aws_iam_policy_document" "mw_role_additional" {
  statement {
    sid    = "AllowSSM"
    effect = "Allow"

    actions = [
      "ssm:DescribeInstanceInformation",
      "ssm:ListCommandInvocations",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowElBRead"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DescribeTargetHealth",
    ]

    resources = ["*"]

  }

  statement {
    sid = "AllowELBWrite"
    effect = "Allow"
  
    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets",
    ]

    resources = [module.hello_world_alb.target_group_arns[0]]
  }
}

resource "aws_iam_policy" "mw_role_add" {
  name        = "MwRoleAdd"
  description = "Additonal permissions needed for MW"

  policy = data.aws_iam_policy_document.mw_role_additional.json
}

resource "aws_iam_role_policy_attachment" "mw_role_add" {
  role       = aws_iam_role.patch_mw_role.name
  policy_arn = aws_iam_policy.mw_role_add.arn
}
