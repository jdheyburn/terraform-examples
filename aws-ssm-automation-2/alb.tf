# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 2.0"

#   domain_name = local.domain_name # trimsuffix(data.aws_route53_zone.this.name, ".") # Terraform >= 0.12.17
#   zone_id     = data.aws_route53_zone.this.id
# }

module "hello_world_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "HelloWorldALB"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.default.id
  subnets         = tolist(data.aws_subnet_ids.all.ids)
  security_groups = [aws_security_group.hello_world_alb.id]

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 6
      }
    }
  ]

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}

# TODO create cert for alb
# TODO have ALB sit in public subnet
# TODO have ec2 sit in private subnet

resource "aws_security_group" "hello_world_alb" {
  name   = "HelloWorldALB"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "alb_ingress_user" {
  security_group_id = aws_security_group.hello_world_alb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.ip_address]
}

resource "aws_security_group_rule" "alb_egress_ec2" {
  security_group_id        = aws_security_group.hello_world_alb.id
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vm_base.id
}

resource "aws_security_group_rule" "ec2_ingress_alb" {
  security_group_id        = aws_security_group.vm_base.id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.hello_world_alb.id
}
