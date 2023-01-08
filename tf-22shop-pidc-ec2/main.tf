# 인스턴스
# Create a instance cgw
resource "aws_instance" "IDC_Gec_CGW" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.instance_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("${var.instance_file_cgw}")
  tags = {
    Name = "${var.instance_name}-CGW"
  }
}

resource "aws_instance" "IDC_Gec_DB" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.instance_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("${var.instance_file_db}")
  tags = {
    Name = "${var.instance_name}-DB"
  }
}

resource "aws_instance" "IDC_Gec_DNS" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.instance_key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("${var.instance_file_dns}")
  tags = {
    Name = "${var.instance_name}-DNS"
  }
}
