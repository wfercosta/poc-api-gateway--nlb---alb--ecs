locals {
  attachments = flatten([
    for role, role_info in var.roles : [
      for policy in role_info.policies_attachments : {
        role   = role
        policy = policy
      }
    ]
  ])
}
