variable "region" {
 description = "aws region"
 type       = string
 default    = "eu-west-1"
}

variable "instance_type_micro" {
 description = "instance for baston and webserver"
 type        = string
 default     = "t3.micro"
}

variable "instance_type_small" {
 description = "instance for database-server"
 type       = string
 default    = "t3.small"
}

variable "keypair_name" {
 description = "name of AWS keypair" 
 type        = string
}

variable "my_ipaddress" {
 description = "my ip addresss for baston host"
 type        = string 
}

