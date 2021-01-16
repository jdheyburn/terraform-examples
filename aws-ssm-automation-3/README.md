# aws-ssm-automation-3

This example follows the [Maintenance Window post](https://jdheyburn.co.uk/blog/automate-instance-hygiene-with-aws-ssm-3/) on my blog. It looks at improvements from the previous post by adding a load balancer to the architecture to allow us control over what instances receive traffic while maintenance is being performed via an automation document.

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
