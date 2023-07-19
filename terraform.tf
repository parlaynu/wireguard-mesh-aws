terraform {  
  required_providers {    
    aws = {      
      source  = "hashicorp/aws"      
      version = "~> 3.55"    
    }
  }
  required_version = ">= 1.0.5"
}

provider "aws" {  
  profile = var.aws_profile
  region = var.aws_region
}

