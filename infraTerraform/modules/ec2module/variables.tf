
variable "instancetype" {
 type = string
 description = "aws instance type"
 default= null
 }

 variable "sg_name" {
 type = string
 description = "ec2 security group name"
 default= null
 }

variable "ssh_key_file" {}

 variable "env_tag" {
   type = map
   description = "instance tag"
   default = null
   }

 





