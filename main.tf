provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_security_group" "instance" {

  name = "tarraform-group"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Name" {
  ami           = "ami-0d19691dd2d866cb6"  
  instance_type = "t2.micro"
  key_name = "sol"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  
  tags = {
    Name = "terraform"
 }
}