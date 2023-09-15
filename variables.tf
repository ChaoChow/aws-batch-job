variable "name" {
  description = "Prefix to add before each resource."
}

# AWS BATCH JOB DEFINITION

variable "container_properties" {
  description = "Collection of properties used by the batch_job_definition container_properties property"
  type = object({
    app_name = string
    app_region = string
    app_image = string
    job_timeout = number
  })
}

variable "hardware_details" {
  description = "Details relating to the physical hardware of the server this job will be running on. CPU must be in increments of 0.5. memory must be power of 2 numbers, cpu_architecture can be can either ARM64 or X86_64"
  type = object({
    vcpu = string
    memory = string
    cpu_architecture = string
  })
  default = {
    vcpu = "0.5"
    memory = "1024"
    cpu_architecture = "ARM64"
  }
}

variable "secrets" {
  description = "Contains values used to configure the adding of secrets to the ecs task"
  type = object({
    secrets_kms_key_id = string
    secret_values     = list(object({
      name      = string
      valueFrom = string
    }))
  })
  default = {
    secrets_kms_key_id = null
    secret_values = []
  }
}

variable "env_vars" {
  description = "Contains any environment variables you would like to inject into the ecs container"
  type = list(object({
    name = string
    value = string
  }))
  default = []
}

# BUCKET ACCESS

variable "read_only_bucket_arns" {
  description = "Arns of s3 buckets batch job will need READ ONLY access to."
  type = list(string)
  default = []
}

variable "read_write_bucket_arns" {
  description = "Arns of s3 buckets batch job will need READ and WRITE access to."
  type = list(string)
  default = []
}
