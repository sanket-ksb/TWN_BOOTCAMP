variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "sshIPs" {
  default = ["0.0.0.0/0"]
  type = list(string)
}
variable "instance-type" {
  default = "t2.medium"
  type = string
}
variable "amiID" {
  default = "ami-0ab1a82de7ca5889c"
  type = string
}
