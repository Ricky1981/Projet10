# Configuration de notre instance RDS
resource "aws_db_instance" "wordpress" {
  identifier        = "wordpress"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"

  # On respecte les prérequis à WordPress à savoir MySQL >= 5.6
  engine_version = "5.7"
  instance_class = "db.t2.micro"

  # On va appeler la BDD "wordpress"
  name                 = "wordpress"
  username             = "admin"
  password             = "adminadmin"
  parameter_group_name = "default.mysql5.7"

  # On rajoute notre option Group crée dans le fichier memcached.tf
  option_group_name = aws_db_option_group.wordpress.id

  # Permet de pouvoir supprimer l'instance sans faire de SnapShot --> pratique lorsqu'on fait un "terraform destroy"
  skip_final_snapshot = true

  # Optionnelle mais on le met quand meme
  availability_zone = "eu-west-3a"

  # On lie notre instance avec notre groupe de securité crée dans le fichier vpc.tf
  vpc_security_group_ids = [aws_security_group.wordpress.id]

  # Ajout du groupe du sous-réseau qui contient les 2 sous réseaux public et privé
  db_subnet_group_name = aws_db_subnet_group.default.id
}

# Création d'un Groupe de sous-réseau 
resource "aws_db_subnet_group" "default" {
  name        = "wordpress-subnet-group"
  description = "RDS subnet group"
  
  # Il est necessaire d'avoir un minimum de 2 sous-réseau
  subnet_ids = [aws_subnet.public.id, aws_subnet.prive.id]
}




