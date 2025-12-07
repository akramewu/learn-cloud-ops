terraform {
  backend "s3" {
    bucket = "akramul-terraform-state-eu-west-2" # <-- your S3 bucket name
    key    = "week4-iam/terraform.tfstate"       # path inside the bucket
    region = "eu-west-2"                         # same as bucket region
  }
}