
module "hello_world_ec2" {
  source         = "terraform-aws-modules/ec2-instance/aws"
  version        = "~> 2.0"
  instance_count = 3

  name                        = "linux-ec2"
  ami                         = "ami-0bb3fad3c0286ebd5"
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [aws_security_group.vm_base.id]
  associate_public_ip_address = true
  key_name                    = module.key_pair.this_key_pair_key_name
  iam_instance_profile        = aws_iam_instance_profile.vm_base.name

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 30
    },
  ]

  tags = {
    "Terraform" = "true"
  }
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "vm-base"
  public_key = file("vm-base.pub")
}

resource "aws_lb_target_group_attachment" "hello_world_tg_att" {
  count = length(module.hello_world_ec2.ids)
  target_group_arn = module.hello_world_alb.target_group_arns.arn
  target_id        = element(module.hello_world_ec2.ids, count.index)
  port             = 8080
}