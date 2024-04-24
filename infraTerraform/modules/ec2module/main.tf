
data "aws_ami" "my_aws_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami             = data.aws_ami.my_aws_ami.id
  instance_type   = var.instancetype
  key_name        = "jenkins"
  tags            = var.env_tag
  security_groups = ["${aws_security_group.ssh_http_https.name}"]

  connection {
    type        = "ssh"
    user = "ubuntu"
    private_key = file(var.ssh_key_file)
    host        = self.public_ip
    timeout = "1m"
  }

 

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo service docker start",
      "sudo chkconfig docker on",
      "sudo usermod -aG docker ubuntu",
      "sudo docker --version",
      "exit"
    ]
  }

}

resource "aws_security_group" "ssh_http_https" {
  name        = var.sg_name
  description = "Allow HTTPS and HTTP inbound traffic"

  ingress {
    description = "HTTP trafic"
    from_port   = 443
    to_port     = 443
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
    description = "HTTPS trafic"
    from_port   = 80
    to_port     = 80
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
    command = "echo PUBLIC_IP: ${self.public_ip}  > infos_ec2.txt"
  }
}



