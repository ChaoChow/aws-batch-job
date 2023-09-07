module "output_buckets" {
  count = length(var.output_bucket_names)
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${var.name}-${var.output_bucket_names[count.index]}"
}

module "instruction_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${var.name}-${var.app_name}-instructions"

  tags = {
    "batch_job_name" : var.app_name
    "bucket_triggers" : true
  }
}

module "run_report" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${var.name}-${var.app_name}-run-reports"
}