data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_file" "privatekey" {
  template = file("${path.module}/templates/key")

  vars = {
    key = tls_private_key.ssh.private_key_pem
  }
}

data "template_file" "publickey" {
  template = file("${path.module}/templates/key")

  vars = {
    key = tls_private_key.ssh.public_key_pem
  }
}

data "template_file" "hosts" {
  template = file("${path.module}/templates/hosts")

  vars = {
    ip_bastion = aws_eip.bastion.public_ip
    ip_ec2     = aws_instance.wordpress.private_ip
  }
}

data "template_file" "bastionhosts" {
  template = file("${path.module}/templates/bastionhosts")

  vars = {
    ip_ec2 = aws_instance.wordpress.private_ip
  }
}

data "template_file" "ansible" {
  template = file("${path.module}/templates/ansible")

  vars = {
    mysql_host = aws_db_instance.wordpress.address
    cloudfont_domain_name = aws_cloudfront_distribution.wordpress.domain_name
  }
}

resource "null_resource" "privatekey" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.privatekey.rendered}\" > ${var.PrivateKey}"
  }
}

resource "null_resource" "publickey" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.publickey.rendered}\" > ${var.PublicKey}"
  }
}

resource "null_resource" "hosts" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.hosts.rendered}\" > ${var.hosts}"
  }
}

resource "null_resource" "hostsreplace" {
  depends_on = [
    aws_instance.wordpress,
    aws_eip.bastion,
    null_resource.hosts,
    null_resource.privatekey
  ]
  provisioner "local-exec" {
    command     = "sudo cp -f ${var.hosts} /etc/hosts; chmod 700 ${var.PrivateKey}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "bastionhosts" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.bastionhosts.rendered}\" > ${var.bastionhosts}"
  }
}

resource "null_resource" "ansible" {
  depends_on = [
    aws_db_instance.wordpress
  ]
  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible.rendered}\" > ${var.ansible}"
  }
}

resource "null_resource" "ansible2" {
  depends_on = [
    null_resource.ansible
  ]

  provisioner "local-exec" {
    command = "sudo cp -f ${var.ansible} /home/vagrant/ansible/roles/wordpress/commun/defaults/main.yml; chmod 777 /home/vagrant/ansible/roles/wordpress/commun/defaults/main.yml"
  }
}

data "template_file" "metricbeat" {
  template = file("${path.module}/templates/metricbeat")

  vars = {
    elastic = aws_elasticsearch_domain.elk.endpoint
    kibana = aws_elasticsearch_domain.elk.kibana_endpoint
  }
}

resource "null_resource" "metricbeat" {
  depends_on = [
    null_resource.ansible2
  ]
  provisioner "local-exec" {
    command = "echo \"${data.template_file.metricbeat.rendered}\" > ${var.metricbeat}"
  }
}

resource "null_resource" "copy_metricbeat_ansible" {
  depends_on = [
    null_resource.metricbeat
  ]
  provisioner "local-exec" {
    command = "sudo cp -f ${var.metricbeat} /home/vagrant/ansible/templates/metricbeat-config.yml; sudo chmod 777 /home/vagrant/ansible/templates/metricbeat-config.yml"
  }
}

data "template_file" "filebeat" {
  template = file("${path.module}/templates/filebeat")

  vars = {
    elastic = aws_elasticsearch_domain.elk.endpoint
    kibana = aws_elasticsearch_domain.elk.kibana_endpoint
  }
}

resource "null_resource" "filebeat" {
  depends_on = [
    null_resource.ansible2
  ]
  provisioner "local-exec" {
    command = "echo \"${data.template_file.filebeat.rendered}\" > ${var.filebeat}"
  }
}

resource "null_resource" "copy_filebeat_ansible" {
  depends_on = [
    null_resource.filebeat
  ]
  provisioner "local-exec" {
    command = "sudo cp -f ${var.filebeat} /home/vagrant/ansible/templates/filebeat-config.yml; sudo chmod 777 /home/vagrant/ansible/templates/filebeat-config.yml"
  }
}

# Permet de lancer notre playbook ansible une fois que toutes les dépendances ont été respectées
resource "null_resource" "launchansible" {
  depends_on = [
    data.aws_ami.ubuntu,
    data.template_file.bastionhosts,
    data.template_file.hosts,
    data.template_file.privatekey,
    data.template_file.publickey,
    data.template_file.ansible,
    aws_cloudfront_distribution.wordpress,
    aws_db_instance.wordpress,
    aws_db_option_group.wordpress,
    aws_db_subnet_group.default,
    aws_eip.bastion,
    aws_eip.nat,
    # aws_eip.route53,
    aws_elasticache_cluster.wordpress,
    aws_elasticache_subnet_group.wordpress,
    aws_elb.wordpress,
    aws_elb_attachment.wordpress,
    aws_instance.bastion,
    aws_instance.wordpress,
    aws_internet_gateway.gw,
    aws_key_pair.ssh,
    aws_nat_gateway.nat-gw,
    aws_route.private,
    aws_route.public,
    # aws_route53_record.projet07tk,
    # aws_route53_record.route53-zone,
    # aws_route53_record.wwwprojet07tk,
    # aws_route53_zone.wordpress,
    aws_route_table.private,
    aws_route_table.public,
    aws_route_table_association.private,
    aws_route_table_association.public,
    aws_security_group.bastion,
    aws_security_group.wordpress,
    aws_subnet.prive,
    aws_subnet.public,
    aws_vpc.wordpress,
    aws_elasticsearch_domain.elk,
    null_resource.bastionhosts,
    null_resource.hosts,
    null_resource.hostsreplace,
    null_resource.privatekey,
    null_resource.publickey,
    null_resource.ansible,
    null_resource.ansible2,
    null_resource.copy_filebeat_ansible,
    null_resource.copy_metricbeat_ansible,
    tls_private_key.ssh
  ]

  # Nous lançons notre playbook ansible en utilisant notre clé privé générée via Terraform
  provisioner "local-exec" {
    command = "ansible-playbook --private-key /home/vagrant/terraform/files/key -i /home/vagrant/ansible/inventaire.ini --become --vault-password-file /home/vagrant/ansible/.vault_pass.txt /home/vagrant/ansible/launch.yml"
  }
}

