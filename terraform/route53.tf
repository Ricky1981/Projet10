# # Ajout de la zone de route53
# resource "aws_route53_zone" "wordpress" {
#   name = "projet07.tk"
# }

# # Puis les records 
# resource "aws_route53_record" "projet07tk" {
#   zone_id = aws_route53_zone.wordpress.zone_id
#   name    = "projet07.tk"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.route53.public_ip]
# }

# resource "aws_route53_record" "wwwprojet07tk" {
#   zone_id = aws_route53_zone.wordpress.zone_id
#   name    = "www.projet07.tk"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.route53.public_ip]
# }

# resource "aws_route53_record" "route53-zone" {
#   allow_overwrite = true
#   name            = "projet07.tk"
#   ttl             = 30
#   type            = "NS"
#   zone_id         = aws_route53_zone.wordpress.zone_id

#   records = [
#     aws_route53_zone.wordpress.name_servers[0],
#     aws_route53_zone.wordpress.name_servers[1],
#     aws_route53_zone.wordpress.name_servers[2],
#     aws_route53_zone.wordpress.name_servers[3],
#   ]
# }