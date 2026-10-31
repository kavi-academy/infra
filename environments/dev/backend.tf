terraform {
  backend "s3" {
    bucket         = "kavi-devops-tf-state-250326384271"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kavi-devops-tf-locks"
    encrypt        = true
  }
}
