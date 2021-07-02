# Creation du load balancer
resource "aws_elb" "wordpress" {
  name = "wordpress-elb"
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.wordpress.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [
    aws_security_group.wordpress.id
  ]

  subnets = [
    aws_subnet.priveelb.id,
    aws_subnet.public.id
  ]

  tags = {
    Name = "wordpress-elb"
  }
}

# Create a new load balancer attachment
resource "aws_elb_attachment" "wordpress" {
  elb      = aws_elb.wordpress.id
  instance = aws_instance.wordpress.id
}