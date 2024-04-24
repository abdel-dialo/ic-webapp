variable  "AWS_REGION" {
type = string
default = "us-east-1"

}

 variable "env_tag" {
   type = map
   description = "instance tag"
   default = {
    Name= "env"
   }

 }

 variable "ssh_key_file" {}

variable "instancetype" {
 type = string
 description = "aws instance type"
 default= "t2.nano"
 }

 variable "sg_name" {
 type = string
 description = "ec2 security group name"
 default= null
 }

 

