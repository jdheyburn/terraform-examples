
resource "aws_security_group" "vm_base" {
  name   = "vm_base"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.ip_address]
  security_group_id = aws_security_group.vm_base.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vm_base.id
}