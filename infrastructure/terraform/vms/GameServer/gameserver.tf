data "aws_ami" "debian-image" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["debian-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "GameServerKey"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_instance" "gameserver" {
  ami                         = data.aws_ami.debian-image.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    Name = var.vm-name
  }

  dynamic "instance_market_options" {
    for_each = var.spot ? [1] : []
    content {
      market_type = "spot"
    }
  }

  //storage 20gb ssd
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

output "public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.gameserver.public_ip
}
