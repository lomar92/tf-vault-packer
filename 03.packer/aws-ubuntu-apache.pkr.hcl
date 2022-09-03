packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "webapp-frontend"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

#Variable for your AMI-Name -> AMI-Name are unique!
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "eu-central-1" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      #name = "ubuntu/images/*ubuntu-*-18.04-amd64-server-*""
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

  tags = {
    Name = "packer-webapp"
  }
  snapshot_tags = {
    Name = "packer-webapp"
  }
}

build {
  name = "ubuntu-image"
  sources = [
    "source.amazon-ebs.eu-central-1"
  ]

  hcp_packer_registry {
    bucket_name = "webapp-frontend"
    description = <<EOT
    This image is a Apache Web Service running on ubuntu
        EOT

    bucket_labels = {
      "tier"    = "frontend",
      "app"     = "webapp",
      "service" = "apache"
    }

    build_labels = {
      "os"      = "ubuntu xenial1"
      #os = "ubuntu focal"
      "version" = "16.04"
      #version = "18.04"
      "app"     = "webapp"
    }
  }

  provisioner "shell" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "sudo apt -y update",
      "sudo apt -y install apache2",
      "sudo systemctl start apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo apt -y install cowsay",
      "cowsay -f tux Look after your Apache version!",
      "apache2 -v"
    ]
  }

  provisioner "file" {
    #change source for GitOps Workflow
    source      = "03.packer/file/"
    destination = "/var/www/html"

#    #Source file from local
#    source      = "file/"
#    destination = "/var/www/html"
  }
}