resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0aedf6b1cb669b4c7"
  instance_type = var.instancetype
  key_name      = "jenkins"
  tags = {
    Name = var.env_tag
  }
  security_groups = ["${aws_security_group.ic_ssh_http_traffic.name}"]

}

resource "aws_security_group" "ic_ssh_http_traffic" {
  name        = var.sg_name
  description = "Allow ic_webapp odoo and pgadmin inbound traffic"

  ingress {
    description = "ODOO traffic"
    from_port   = 8069
    to_port     = 8069
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ic-webapp traffic"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh trafic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PGADMIN traffic"
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_ec2_instance.id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo ${var.url}: ${self.public_ip}  >> server_ip.txt"
  }

}
