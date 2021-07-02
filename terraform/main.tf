terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configuration du provider AWS
provider "aws" {
  # On utilise une connection par variable d'environnement ce qui nous permet de ne pas diffuser des informations critiques (--> ne pas diffuser le fichier variables.tf)
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}