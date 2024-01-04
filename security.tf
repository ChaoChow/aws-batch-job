resource "aws_iam_role" "batch_job_role" {
  name               = "${local.full_app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# S3 Bucket Access

resource "aws_iam_role_policy" "read_only_bucket_access" {
  name   = "${local.full_app_name}-read-only-bucket-access"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.read_only_s3_bucket_policy.json
}

resource "aws_iam_role_policy" "read_write_bucket_access" {
  name   = "${local.full_app_name}-read-write-bucket-access"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.read_write_s3_bucket_policy.json
}

# Other Access

resource "aws_iam_role_policy" "read_task_container_secrets" {
  count  = local.should_add_secrets ? 1 : 0
  name   = "${local.full_app_name}-read-secrets"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.secrets[0].json
}

resource "aws_iam_role_policy" "ecr_access" {
  name   = "${local.full_app_name}-ecr-access-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.ecr_access.json
}

resource "aws_iam_role_policy" "log_access" {
  name   = "${local.full_app_name}-log-access-policy"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.log_access.json
}

# Policies

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

data "aws_iam_policy_document" "read_write_s3_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid    = "OutputBatchS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:CopyObject",
      "s3:DeleteObject",
      "s3:DeleteObjects",
      "s3:DeleteObjectTagging",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:HeadObject",
      "s3:ListBucket",
      "s3:ListObjects",
      "s3:ListObjectsV2",
      "s3:ListObjectVersions",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = concat(
      [for rw_bucket_arn in var.read_write_bucket_arns : rw_bucket_arn],
      [for rw_bucket_arn in var.read_write_bucket_arns : "${rw_bucket_arn}/*"]
    )
  }
}


data "aws_iam_policy_document" "read_only_s3_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid    = "ReadOnlyBatchS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:HeadObject",
      "s3:ListBucket",
      "s3:ListObjects",
      "s3:ListObjectsV2",
    ]
    resources = concat(
      [for ro_bucket_arn in var.read_only_bucket_arns : ro_bucket_arn],
      [for ro_bucket_arn in var.read_only_bucket_arns : "${ro_bucket_arn}/*"]
    )
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

data "aws_iam_policy_document" "secrets" {
  count = local.should_add_secrets ? 1 : 0

  statement {
    effect = "Allow"

    resources = concat(
      [data.aws_kms_key.secrets_key[0].arn],
      [for i in var.secrets.secret_values : replace(i["valueFrom"], "/:[^:]+::$/", "")]
    )
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]
  }
}

data "aws_kms_key" "secrets_key" {
  count  = local.should_add_secrets ? 1 : 0
  key_id = var.secrets.secrets_kms_key_id
}