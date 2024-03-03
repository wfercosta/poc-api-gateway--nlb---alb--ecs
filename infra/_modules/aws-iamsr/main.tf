resource "aws_iam_policy" "this" {
  for_each = var.policies
  name     = each.key
  policy   = templatefile(each.value, var.replacement_vars)
}

resource "aws_iam_role" "this" {
  for_each           = var.roles
  name               = each.key
  path               = "/iamsr/"
  assume_role_policy = templatefile(each.value.trust_role, var.replacement_vars)
}

resource "aws_iam_role_policy_attachment" "this" {
  depends_on = [aws_iam_role.this, aws_iam_policy.this]

  for_each = {
    for attachment in local.attachments : "${attachment.role}-${attachment.policy}" => attachment
  }

  role       = each.value.role
  policy_arn = each.value.policy
}
