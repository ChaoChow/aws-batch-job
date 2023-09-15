resource "aws_iam_role" "batch_job_role" {
  name               = "${local.full_app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# S3 Bucket Access

resource "aws_iam_role_policy" "read_only_bucket_access" {
  count = length(data.aws_iam_policy_document.read_only_s3_bucket_policies)

  name   = "${local.full_app_name}-output-bucket-access-${count.index}"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.read_only_s3_bucket_policies[count.index].json
}

resource "aws_iam_role_policy" "read_write_bucket_access" {
  count = length(data.aws_iam_policy_document.read_write_s3_bucket_policies)

  name   = "${local.full_app_name}-output-bucket-access-${count.index}"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.read_write_s3_bucket_policies[count.index].json
}

# Other Access

resource "aws_iam_role_policy" "read_task_container_secrets" {
  count = local.should_add_secrets ? 1 : 0
  name   = "${local.full_app_name}-read-secrets"
  role   = aws_iam_role.batch_job_role.id
  policy = data.aws_iam_policy_document.secrets.json
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

data "aws_iam_policy_document" "read_write_s3_bucket_policies" {
  count = length(var.read_write_bucket_arns)
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
      var.read_write_bucket_arns[count.index],
      "${var.read_write_bucket_arns[count.index]}/*"
    ]
  }
}


data "aws_iam_policy_document" "read_only_s3_bucket_policies" {
  count = length(var.read_only_bucket_arns)
  version = "2012-10-17"
  statement {
    sid    = "ReadOnlyBatchS3BucketAccess${count.index}"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.read_only_bucket_arns[count.index],
      "${var.read_only_bucket_arns[count.index]}/*",
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

data "aws_iam_policy_document" "secrets" {
  statement {
    effect = "Allow"

    resources = concat(
      [data.aws_kms_key.secrets_key.arn],
      [for i in var.secrets.secret_values : replace(i["valueFrom"], "/:[^:]+::$/", "")]
    )
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]
  }
}

data "aws_kms_key" "secrets_key" {
  key_id = var.secrets.secrets_kms_key_id
}