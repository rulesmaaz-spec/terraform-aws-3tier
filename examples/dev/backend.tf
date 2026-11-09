# Requires Terraform >= 1.10 for use_lockfile (native S3 locking).
# On older versions: remove use_lockfile and add dynamodb_table = "<your-lock-table>".

terraform {
  backend "s3" {
    bucket       = "REPLACE-WITH-YOUR-STATE-BUCKET"
    key          = "three-tier/dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
