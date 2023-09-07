resource "aws_batch_job_definition" "batch_job_definition" {
  name = "${var.name}-${var.app_name}-job-definition"
  type = "container"

  platform_capabilities = [
    "FARGATE"
  ]

  timeout {
    attempt_duration_seconds = 7200
  }

  container_properties = jsonencode({
    command = ["Ref::instruction_file"]
    image   = var.app_image

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = var.vcpu
      },
      {
        type  = "MEMORY"
        value = var.memory
      }
    ]

    runtimePlatform = {
      operatingSystemFamily = "LINUX",
      cpuArchitecture = var.cpu_architecture
    }

    logConfiguration = {
      logDriver = "awslogs"
    }

    ENVIRONMENT = [{
      name = "ENVIRONMENT",
      value = "prod"
      }, {
      name = "AWS_DEFAULT_REGION",
      value = var.aws_region
    }]

    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }

    executionRoleArn = aws_iam_role.batch_job_role.arn
    jobRoleArn = aws_iam_role.batch_job_role.arn
  })
}