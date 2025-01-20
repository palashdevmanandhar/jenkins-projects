# aws provider region for the project
variable "region1" {
  type        = string
  default     = "us-east-1"
  description = "virginia region and the default region"
}

variable "region2" {
  type        = string
  default     = "us-west-2"
  description = "oregon region"
}

variable "availability_zone2_region1" {
  type        = string
  default     = "us-east-1b"
  description = "second az region one"
}



variable "availability_zone_region1" {
  type        = string
  default     = "us-east-1a"
  description = "default az region one"
}

variable "availability_zone_region2" {
  type        = string
  default     = "us-west-2a"
  description = "default az region 2"
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

variable "aws_ami_id_region1" {
  type        = string
  default     = "ami-09115b7bffbe3c5e4"
  description = "id of amazon linux in us-east-1"
}

variable "aws_ami_id_region2" {
  type        = string
  default     = "ami-093a4ad9a8cc370f4"
  description = "id of amazon linux in us-east-1"
}

variable "project_name" {
  type        = string
  default     = "react-jenkins-project"
  description = "description"
}
