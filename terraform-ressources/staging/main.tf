provider "aws" {
  region     = var.AWS_REGION
}

module "ec2_staging" {
    source = "../modules/ec2module"
    instancetype = var.instancetype
    env_tag = var.env_tag
    ssh_key_file= var.ssh_key_file
    sg_name= var.sg_name

}

terraform {
  backend "s3" {
    bucket = "terraform-backend-abdoul"
    key = "./env_staging.tfstate"
    region = "us-east-1"
    
  }
}