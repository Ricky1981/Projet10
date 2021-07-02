# On ajoute notre passerelle internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.wordpress.id

  tags = {
    Name = "WordPress Internet Gateway"
  }
}

# On va ajouter notre NAT Gateway 
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}

# On ajoute une IP Elastic public pour notre NAT
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "IP Public NAT"
  }

}

# resource "aws_eip" "route53" {
#   vpc = true
# }