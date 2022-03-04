variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "private_subnet" {
  type    = list(string)
  default = ["172.16.1.0/24", "172.16.2.0/24"]
}

variable "public_subnet" {
  type    = list(string)
  default = ["172.16.100.0/24", "172.16.101.0/24"]
}
