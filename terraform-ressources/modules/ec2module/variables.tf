
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


 variable "env_tag" {
   type = string
   description = "instance tag"
   default = null
   }

  variable "url" {
  type    = string
  default = null
}

 





