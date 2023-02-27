variable "DOCKERHUB_USER" {}
variable "DOCKERHUB_PASS_BASE64" {}

# smm
resource "aws_ssm_parameter" "DOCKERHUB_USER" {
    name        = "DOCKERHUB_USER"
    description = "DOCKERHUB_USER"
    type        = "SecureString"
    value       = var.DOCKERHUB_USER
}
resource "aws_ssm_parameter" "DOCKERHUB_PASS" {
    name        = "DOCKERHUB_PASS"
    description = "DOCKERHUB_PASS"
    type        = "SecureString"
    value       = base64decode(var.DOCKERHUB_PASS_BASE64)
}
