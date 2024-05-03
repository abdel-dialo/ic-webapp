provider "aws" {
  region = var.AWS_REGION
}

module "ec2_staging" {
  count        = 2
  source       = "../modules/ec2module"
  instancetype = var.instancetype
  env_tag      = var.server_staging[count.index]
  sg_name      = var.sg_staging[count.index]
  url          = var.url_staging[count.index]

}

terraform {
  backend "s3" {
    bucket = "terraform-backend-abdoul"
    key    = "./env_staging.tfstate"
    region = "us-east-1"

  }
}