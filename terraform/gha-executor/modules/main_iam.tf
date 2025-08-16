resource "aws_iam_policy" "terraform_executor" {
  name = "${local.prefix}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:*",
          "autoscaling:*",
          "cloudwatch:*",
          "elasticloadbalancing:*",
          "ec2:*",
          "ecr:*",
          "ecs:*",
          "iam:*",
          "logs:*",
          "route53:*",
          "s3:*",
        ]
        Resource = ["*"]
      },
    ]
  })
}

module "terraform_executor_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true

  role_name = "${local.prefix}-terraform"

  provider_url = data.aws_iam_openid_connect_provider.github.url
  role_policy_arns = [
    aws_iam_policy.terraform_executor.arn,
  ]

  oidc_subjects_with_wildcards = [
    "repo:skokado/fullstack-api-service-with-ecs:*",
  ]
}
