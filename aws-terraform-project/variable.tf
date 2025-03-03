variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
}

variable "ubuntu_ami" {
  description = "AMI ID"
  type        = string
  
}
