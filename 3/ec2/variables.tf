variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "bucket-name" {
  default = ""
  type = string
}
variable "bucket-key" {
  default = ""
  type = string
}
variable "dynamodb-lock-table" {
  default = ""
  type = string
}
variable "sshIPs" {
  default = ["0.0.0.0/0"]
  type = list(string)
}
variable "instance-type" {
  default = "t3.xlarge"
  type = string
}
variable "amiID" {
  default = "ami-0ab1a82de7ca5889c"
  type = string
}
