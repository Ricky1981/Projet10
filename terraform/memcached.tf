#
# ElastiCache Resources
#
resource "aws_elasticache_subnet_group" "wordpress" {
  name       = "wordpress"
  subnet_ids = [aws_subnet.prive.id]
}


resource "aws_elasticache_cluster" "wordpress" {
  cluster_id           = "cluster-wordpress"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  subnet_group_name    = aws_elasticache_subnet_group.wordpress.id
  security_group_ids   = [aws_security_group.wordpress.id]
  port                 = 11211
}

# Configuration d'une option Group qui est necessaire pour MemCached
resource "aws_db_option_group" "wordpress" {
  name                     = "wordpress-option-group"
  option_group_description = "WordPress Option Group"
  engine_name              = "mysql"
  major_engine_version     = "5.7"

  #Puis on ajoute l'option "MemCached"
  option {
    option_name                    = "MEMCACHED"
    port                           = 11211
    vpc_security_group_memberships = [aws_security_group.wordpress.id]

    option_settings {
      name  = "BACKLOG_QUEUE_LIMIT"
      value = 1024
    }

    option_settings {
      name  = "BINDING_PROTOCOL"
      value = "auto"
    }

    option_settings {
      name  = "CAS_DISABLED"
      value = 0
    }

    option_settings {
      name  = "CHUNK_SIZE"
      value = 48
    }

    option_settings {
      name  = "CHUNK_SIZE_GROWTH_FACTOR"
      value = 1.25
    }
  }
}
