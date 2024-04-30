
variable  "AWS_REGION" {
type = string
default = "us-east-1"

}


variable "server_prod" {
  type    = list(string)
  default = null
}

variable "sg_prod" {
  type    = list(string)
  default = null
}

variable "url_prod" {
  type    = list(string)
  default = null
}



 variable "ssh_key_file" {}

variable "instancetype" {
 type = string
 description = "aws instance type"
 default= "t2.nano"
 }


 

