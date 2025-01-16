terraform {
  backend "s3" {
    bucket         = "react-jenkins-tf-state-bucket"
    key            = "terraform/state/terraform.tfstate" # Path to state file
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock" # Optional, for state locking
    encrypt        = true            # Encrypt state file at rest using AWS KMS
  }
}
