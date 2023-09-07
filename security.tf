resource "aws_iam_role" "batch_job_role" {
  name               = "${var.name}-${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy" "output_bucket_access" {
  count = length(data.aws_iam_policy_document.s3_output_bucket_rws)

  name   = "${var.name}-${var.app_name}-output-bucket-access-${count.index}"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.s3_output_bucket_rws[count.index].json
}

resource "aws_iam_role_policy" "run_report_bucket_access" {
  name   = "${var.name}-${var.app_name}-run-report-bucket-access"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.s3_run_report_bucket_rw.json
}

resource "aws_iam_role_policy" "additional_read_only_bucket_access" {
    count = length(data.aws_iam_policy_document.s3_additional_bucket_ros)

  name   = "${var.name}-${var.app_name}-read-only-bucket-access-${count.index}"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.s3_additional_bucket_ros[count.index].json
}

resource "aws_iam_role_policy" "instruction_bucket_access" {
  name   = "${var.name}-${var.app_name}-instruction-bucket-access"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.s3_instruction_bucket_ro.json
}

resource "aws_iam_role_policy" "ecr_access" {
  name   = "${var.name}-${var.app_name}-ecr-access-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.ecr_access.json
}

resource "aws_iam_role_policy" "log_access" {
  name   = "${var.name}-${var.app_name}-log-access-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.log_access.json
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_output_bucket_rws" {
  count = length(module.output_buckets)
  version = "2012-10-17"
  statement {
    sid    = "OutputBatchS3BucketAccess${count.index}"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      module.output_buckets[count.index].s3_bucket_arn,
      "${module.output_buckets[count.index].s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_run_report_bucket_rw" {
  version = "2012-10-17"
  statement {
    sid    = "RunReportBatchS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      module.run_report.s3_bucket_arn,
      "${module.run_report.s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_additional_bucket_ros" {
  count = length(var.additional_ro_bucket_arns)
  version = "2012-10-17"
  statement {
    sid    = "ReadOnlyBatchS3BucketAccess${count.index}"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.additional_ro_bucket_arns[count.index],
      "${var.additional_ro_bucket_arns[count.index]}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_instruction_bucket_ro" {
  version = "2012-10-17"
  statement {
    sid    = "BatchS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.instruction_bucket.s3_bucket_arn,
      "${module.instruction_bucket.s3_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "ecr_access" {
  version = "2012-10-17"
  statement {
    sid    = "BatchECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "log_access" {
  version = "2012-10-17"
  statement {
    sid    = "BatchLogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "*"
    ]
  }
}