variable "image_filter" {
  type    = string
  default = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
}

variable "ssh_account" {
  type    = string
  default = "ubuntu"
}
