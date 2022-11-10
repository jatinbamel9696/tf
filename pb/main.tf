data "aws_iam_policy_document" "pbtestpolicydoc" {
  statement {
    sid = "Visualeditor1"
    effect = "Allow"
    not_actions = [
       "iam:CreateUser",
       "iam:CreateRole",
       "iam:DeletePolicy",
       "iam:DeletePolicyVersion",
       "iam:CreatePolicyVersion",
       "iam:SetDefaultPolicyVersion",
       "iam:DeleteUserPermissionsBoundary",
       "iam:DeleteRolePermissionsBoundary"]

    resources = [
      "arn:aws:iam::359828150465:user/test-user"
    ]
  }
}

resource "aws_iam_policy" "testpb" {
  name        = "Test-user-pb"
  description = "Defines maximum permission"
  policy      = data.aws_iam_policy_document.pbtestpolicydoc.json
  tags = var.tags
}
