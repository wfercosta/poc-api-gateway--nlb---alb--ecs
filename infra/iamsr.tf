module "iamsr" {
  source = "./_modules/aws-iamsr"

  replacement_vars = {
    account_id = local.account_id
    region     = local.region
  }

  policies = {
    policy-ecs-task-execution-role = "./_iamsr/policies/policy-ecs-task-execution-role.tftpl",
  }

  roles = {
    ecs-task-execution-role = {
      trust_role = "./_iamsr/assume_roles/trust-ecs.tftpl"
      policies_attachments = [
        "arn:aws:iam::${local.account_id}:policy/policy-ecs-task-execution-role"
      ]
    }
  }
}
