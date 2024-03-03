variable "policies" {
  type    = map(string)
  default = {}
}

variable "roles" {
  type = map(object({
    trust_role           = string
    policies_attachments = list(string)
  }))
  default = {}
}

variable "replacement_vars" {
  type    = map(string)
  default = {}
}
