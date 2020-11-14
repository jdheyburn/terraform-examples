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

# data "aws_iam_policy_document" "patch_mw" {
#   statement {
#     sid     = "AllowIAM"
#     effect  = "Allow"
#     actions = ["iam:PassRole"]

#     resources = [aws_iam_role.patch_mw_role.arn]

#     condition {
#       test     = "StringEquals"
#       variable = "iam:PassedToService"
#       values   = ["ssm.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_policy" "patch_mw" {
#   name   = "PatchingMaintWindowPolicy"
#   policy = data.aws_iam_policy_document.patch_mw.json
# }

# resource "aws_iam_role_policy_attachment" "patch_mw_role_attach_policy" {
#   role       = aws_iam_role.patch_mw_role.name
#   policy_arn = aws_iam_policy.patch_mw.arn
# }