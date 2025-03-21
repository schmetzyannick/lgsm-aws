data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "gameserver_sg" {
  name        = "gameserver_sg"
  description = "Security group for game server allowing SSH traffic from anywhere"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gameserver_sg"
  }
}