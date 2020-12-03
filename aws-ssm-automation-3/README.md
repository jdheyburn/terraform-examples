# aws-ssm-automation-2

This example follows the [Maintenance Window post](https://jdheyburn.co.uk/blog/automate-instance-hygiene-with-aws-ssm-2/) on my blog. It focuses on creating SSM Automation documents and attaching them to a maintenance window.

## Setup

In order to use this, you need to have [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your machine.

Within this directory you'll need a file named `secret.tf`, which will contain:

```hcl
locals {
  ip_address = "YOUR_IP_ADDRESS/32"
}
```

Ensuring that you replace `YOUR_IP_ADDRESS` with the IP address of your machine, so that you can connect to it and administrate it - however it is not required for the exercise.

You'll need a key pair for being able to log onto the EC2 machines created.

```bash
ssh-keygen -t rsa -b 4096 -m PEM -f vm_base
mv vm_base vm_base.pem
```

## Deploy

Use Terraform to deploy to your account.

```bash
terraform init
terraform apply
```
