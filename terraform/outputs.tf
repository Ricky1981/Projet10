output "EC2_private_ip" {
  value = aws_instance.wordpress.private_ip
}

output "nat_gateway_ip" {
  value = aws_eip.nat.public_ip
}

output "bastion_ip" {
  value = aws_eip.bastion.public_ip
}

# output "Route53_NameServer" {
#   value = <<EOT
#   ${aws_route53_zone.wordpress.name_servers[0]}
#   ${aws_route53_zone.wordpress.name_servers[1]}
#   ${aws_route53_zone.wordpress.name_servers[2]}
#   ${aws_route53_zone.wordpress.name_servers[3]}
#   EOT
# }

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "cloudFront" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}