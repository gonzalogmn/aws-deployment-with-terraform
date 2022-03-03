source "amazon-ebs" "demo-api" {
  profile         = "admin-ecs-deployment-demo"
  ssh_timeout     = "30s"
  region          = "eu-central-1"
  source_ami      = "ami-0db9040eb3ab74509" // amazon linux 2
  ssh_username    = "ec2-user"
  ami_name        = "demo api"
  instance_type   = "t2.micro"
  skip_create_ami = false

}

build {
  sources = [
    "source.amazon-ebs.demo-api"
  ]
  provisioner "ansible" {
    playbook_file = "playbook.yml"
  }
}
