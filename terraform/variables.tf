# aws provider region for the project
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "default region for the project"
}

variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "deafult_vpc_id" {
  type        = string
  default     = "vpc-08dc24ade02456138"
  description = "id of default vpc"
}

variable "aws_ami_id"{
  type        = string
  default     = "ami-09115b7bffbe3c5e4"
  description = "id of amazon linux in us-east-1"
}

variable project_name {
  type        = string
  default     = "react-jenkins-project"
  description = "description"
}
