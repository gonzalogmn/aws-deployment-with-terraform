# aws-deployment-with-terraform

## Requisites

### Installations required

- [`docker`](https://docs.docker.com/engine/install/)
- [`aws`](https://docs.aws.amazon.com/es_es/cli/latest/userguide/cli-chap-install.html)
- [`tfenv`](https://github.com/tfutils/tfenv)
- [`ansible`]()
- [`packer`]()
- [aws-nuke](https://github.com/rebuy-de/aws-nuke) (to be able to destroy all remaining resources after a `terraform destroy`)


### Create IAM user

- Sign in to the IAM console, and choose "Add User"
- Select the check box for AWS Management Console access, select "Custom Password", and type in your new password.
- On the Permissions page, either directly attach the `AdministratorAccess` policy or add the user to a group that already has this policy.
- Under the "Security Credentials" tab, you can then create access keys to authenticate against AWS service APIs.
- Download access keys.

### Configure aws profile

With downloaded access keys, create a new profile in your `~/.aws/credentials` file:

```
...

[admin-ec2-deployment-demo]
aws_access_key_id = <your_aws_access_key_id>
aws_secret_access_key = <your_aws_secret_access_key>
region = eu-central-1

```

### Execute this **only once**! when creating project from zero

- Create `terraform/remote-state/terraform.tfvars` file with this content:

```
app_name        = "demo-api"
app_environment = "test"
```

- In `terraform/remote-state` folder, run:

```sh
terraform init
terraform apply
```

This will generate the required S3 backend to host Terraform state file. 


### Configure required variables

Create `terraform/terraform.tfvars` file with this content:

```
ami_id = <YOUR_AMI_ID> # to get this you will need to execute make upload-ami in order to generate an AMI
```

### Configure `aws-nuke`

- Create `utils/aws-nuke-config.yml` with this content:

```yml
regions:
- eu-central-1
- global

account-blocklist:
- "999999999999" # fake production

accounts:
  "<YOUR_ACCOUNT_ID>": 
    filters:
      IAMUser:
      - "<YOUR_USER>"
      IAMUserPolicyAttachment:
      - "<YOUR_USER> -> AdministratorAccess"
      IAMUserAccessKey:
      - "<YOUR_USER> -> <YOUR_ACCESS_KEY>"
      IAMLoginProfile:
      - "<YOUR_USER>"
```

## Start

```
make start
```

## Deploy

```
make upload-ami

# Then, copy ami id into terraform/terraform.tfvars variable

make deploy
```

## Cleaning up

```
terraform destroy
aws ec2 deregister-image --image-id <your-ami-id> # Deregister image
aws ec2 describe-snapshots --owner self # Find snapshot id
aws ec2 delete-snapshot --snapshot-id <your-snap-id> # Delete snapshot

# To be able to delete all remaining resources
aws-nuke -c utils/aws-nuke-config.yml --profile admin-ec2-deployment-demo --no-dry-run

# Last command will delete also default VPC. To generate again a new default VPC, execute next command:
aws ec2 create-default-vpc
<!-- linode-cli domains records-delete <main-id> <record-id> # Remove cname record -->
```

## References
- [https://nicobraun.rainbowstack.dev/blog/immutable-cluster/](https://nicobraun.rainbowstack.dev/blog/immutable-cluster/)
- [https://programmerclick.com/article/9237930514/](https://programmerclick.com/article/9237930514/)