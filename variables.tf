variable "name" {
  description = "Prefix to add before each resource."
}

variable "app_image" {
  description = "The name of the docker image to deploy"
}

variable "aws_region" {
  description = "AWS region to run the batch job in"
}

variable "app_name" {
  description = "Unique name of your application. Batch job name will have '<var.name>' as a prefix and '' as a suffix"
}

# AWS BATCH JOB DEFINITION

variable "job_timeout" {
  description = "The length of time the batch job is allowed to run before timing out and being killed"
}

variable "vcpu" {
  description = "Amount of CPUs to allocate to the fargate container running the job"
}

variable "memory" {
  description = "Amount of memory to allocate to the fargate container running the job"
}

variable "cpu_architecture" {
  description = "CPU instruction set for the container, can either be ARM64 or X86_64"
}

# BUCKET NAMES

variable "instruction_bucket_name" {
  description = "Name of the s3 bucket that will hold the instruction files. Prefix will be '<var.name>' suffix will be '-instructions'"
}

variable "run_report_bucket_name" {
  description = "Name of the s3 bucket that will hold the run report files. Prefix will be '<var.name>' suffix will be '-run-reports'"
}

variable "output_bucket_names" {
  type = list(string)
  description = "Names of the s3 buckets that will hold the output files. Prefix will be '<var.name>' no suffix will be added"
}

variable "additional_ro_bucket_arns" {
  type = list(string)
  description = "ARNs of additional s3 buckets that your batch job will need read only access to."
}