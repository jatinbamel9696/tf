
variable "rotation_lambda_arn" {
  type = string
}

variable "pb" {
  type = string
}


variable "tags" {
  type = map(any)
  description = "Lists of tags to be added to the resources"
}