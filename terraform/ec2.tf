# Nous générons une paire de clé qui nous servira à nous connecter sur notre bastion ainsi que notre instance EC2 du réseau privé
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "aws_key_pair" "ssh" {
  key_name   = "key"
  public_key = tls_private_key.ssh.public_key_openssh
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  # Canonical
  owners = ["099720109477"] 
}

# Configuration de notre instance EC2
resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.prive.id

  # On ajoute note "key-Pair" généré précédemment
  key_name = aws_key_pair.ssh.key_name

  security_groups = [aws_security_group.wordpress.id]

  # On ajoute un tag pour notre instance
  tags = {
    Name = "ubuntu"
  }
}

# Creation de notre bastion qui sera joignable dans notre réseau public
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  # On ajoute note "key-Pair" généré précédemment
  key_name = aws_key_pair.ssh.key_name
  security_groups = [aws_security_group.bastion.id]

  # On fait juste l'update pour avoir une instance "propre" dès le départ
  user_data = <<-EOF
		#! /bin/bash
    sudo apt-get update
	EOF

  tags = {
    Name = "Bastion"
  }
}

# On rajoute une IP Elastic pour notre Bastion
resource "aws_eip" "bastion" {
  vpc = true
  
  instance = aws_instance.bastion.id
  tags = {
    Name = "IP Public bastion"
  }
}




