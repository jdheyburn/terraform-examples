data "aws_ami" "windows" {
  owners           = ["amazon"]
  executable_users = ["self"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "amazon_linux_2" {
  owners           = ["amazon"]
  executable_users = ["self"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "windows_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  instance_count = 1

  name                        = "windows-ec2"
  ami                         = data.aws_ami.windows.id
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

module "linux_ec2" {
  source         = "terraform-aws-modules/ec2-instance/aws"
  version        = "~> 2.0"
  instance_count = 1

  name                        = "linux-ec2"
  ami                         = data.aws_ami.amazon_linux_2.id
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
