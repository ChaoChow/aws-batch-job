resource "aws_batch_job_definition" "batch_job_definition" {
  name = "${local.full_app_name}-job-definition"
  type = "container"

  platform_capabilities = [
    "FARGATE"
  ]

  timeout {
    attempt_duration_seconds = var.container_properties.job_timeout
  }

  container_properties = jsonencode({
    command = ["Ref::instruction_file"]
    image   = var.container_properties.app_image

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = var.hardware_details.vcpu
      },
      {
        type  = "MEMORY"
        value = var.hardware_details.memory
      }
    ]

    runtimePlatform = {
      operatingSystemFamily = "LINUX",
      cpuArchitecture = var.hardware_details.cpu_architecture
    }

    logConfiguration = {
      logDriver = "awslogs"
    }

    environment: var.env_vars
    secrets: var.secrets.secret_values

    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }

    executionRoleArn = aws_iam_role.batch_job_role.arn
    jobRoleArn = aws_iam_role.batch_job_role.arn
  })
}