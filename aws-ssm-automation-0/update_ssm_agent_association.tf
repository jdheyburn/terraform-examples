data "aws_ssm_document" "update_ssm_agent" {
  name            = "AWS-UpdateSSMAgent"
  document_format = "YAML"
}

resource "aws_ssm_association" "update_ssm_agent" {
  name = data.aws_ssm_document.update_ssm_agent.name

  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}
