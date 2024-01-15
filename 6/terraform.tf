terraform {
  required_version = "~> 1.3"
}
provider "aws" {
  region = var.region  # Replace with your desired region
}
