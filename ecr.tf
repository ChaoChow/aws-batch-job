module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  repository_name = var.container_properties.app_name
  #  repository_read_write_access_arns = [var.gitlab_runner_iam_user]
  # comment the above line in when we get gitlab runners

  create_lifecycle_policy = false
}
