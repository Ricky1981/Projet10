# Creation du VPC 
resource "aws_vpc" "wordpress" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "wordpressVPC"
  }
}

# Creation du subnet public
resource "aws_subnet" "public" {
  # On pointe sur le VPC que nous avons créée
  vpc_id     = aws_vpc.wordpress.id
  cidr_block = "10.0.1.0/24"

  # Optionnelle
  availability_zone = "eu-west-3a"
  # On active automatiquement une IP publique qui est affecté à l'instance lors de lancement
  map_public_ip_on_launch = true

  tags = {
    Name = "wordpress-subnet-public"
  }
}

resource "aws_subnet" "prive" {
  # On pointe sur le VPC que nous avons créée
  vpc_id     = aws_vpc.wordpress.id
  cidr_block = "10.0.2.0/24"

  # Optionnelle
  availability_zone       = "eu-west-3b"

  tags = {
    Name = "wordpress-subnet-private"
  }
}

resource "aws_subnet" "priveelb" {
  vpc_id     = aws_vpc.wordpress.id
  cidr_block = "10.0.3.0/24"

  # Optionnelle
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true
  tags = {
    Name = "wordpress-subnet-private-elb"
  }
}

#2. Creation du Group de Securité pour autoriser les ports 22, 80 et 3306 
resource "aws_security_group" "wordpress" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    # -1 Indique tous les protocole
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow_web_SecurityGroup"
    Description = "allow_web_SecurityGroup"
  }
}

#2. Creation du Group de Securité pour notre bastion 
resource "aws_security_group" "bastion" {
  name        = "bastion_allow_traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description = "Bastion SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port   = 0
    # -1 Indique tous les protocole
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bastion_SecurityGroup"
    Description = "bastion_SecurityGroup"
  }
}