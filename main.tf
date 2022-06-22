terraform {
  required_version = ">= 0.14.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6.0" # v4.4.0 has bucket versioning issues
    }
  }
}

provider "aws" {
  region = var.region
}

#S3 Remote Backend 
terraform {
  backend "s3" {
    bucket         = "aws-s3-mtaquia-backend-ch01"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mtaquia-backend-ch01" # for locking
    encrypt        = true
    kms_key_id     = "a5805a87-d915-45b6-b43f-a1a3104ae053"
  }
}

# #Resources creation
resource "aws_s3_bucket" "s3bucket" {
  bucket = "${var.s3-bucket-name}-${terraform.workspace}"
}

resource "aws_s3_bucket_acl" "s3acl" {
  bucket = aws_s3_bucket.s3bucket.id
  acl    = var.s3-bucket-acl
}

resource "aws_s3_bucket_versioning" "s3versioning" {
  bucket = aws_s3_bucket.s3bucket.id
  versioning_configuration {
    status = var.s3-bucket-versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3encryption" {
 count = var.s3-bucket-encrypt == true ? 1 : 0

  bucket = aws_s3_bucket.s3bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3-bucket-keyid  #aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
      # sse_algorithm = "AES256" #valid AES256 or aws:kms
    }
  }
}

resource "aws_s3_bucket_policy" "s3policy" {
  bucket = aws_s3_bucket.s3bucket.id
  policy = data.aws_iam_policy_document.s3allow_access.json
}

data "aws_iam_policy_document" "s3allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.s3-bucket-allow_access_list
    }

    actions = ["s3:ListBucket"]

    resources = ["arn:aws:s3:::${var.s3-bucket-name}-${terraform.workspace}"]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = var.s3-bucket-allow_access_list
    }

    actions = ["s3:GetObject", "s3:PutObject"]

    resources = ["arn:aws:s3:::${var.s3-bucket-name}-${terraform.workspace}/*"]
  }
}
