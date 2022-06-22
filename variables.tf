variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region for the S3 bucket"
}

variable "s3-bucket-name" {
  type        = string
  description = "Name of the S3 bucket"
}
variable "s3-bucket-acl" {
  type        = string
  description = "ACL for the S3 bucket"
}
variable "s3-bucket-versioning" {
  type        = string
  description = "Versioning state for the S3 bucket"
  default     = "Disabled"
}
variable "s3-bucket-allow_access_list" {
  type    = list(string)
  default = ["arn:aws:iam::719798204634:user/michael.taquia"]
}

#acl: Valid values are private, public-read, public-read-write, 
#aws-exec-read, authenticated-read, and log-delivery-write. Defaults to private

variable "s3-bucket-encrypt" {
  type        = bool
  description = "Encrypt bucket at rest"
  default     = false
}

variable "s3-bucket-keyid" {
  type        = string
  description = "KMS key id for encrypting S3"
  default     = null #to not require as mandatory 
}

# locals {
#   bucketName = "${var.s3-bucket-name}-${terraform.workspace}"
# }