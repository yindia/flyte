
  module "userflyterole"  {
    allowed_iams = [
      
    ]
    iam_policy  {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "iam:GetContextKeysForCustomPolicy",
            "iam:GetContextKeysForPrincipalPolicy",
            "iam:SimulateCustomPolicy",
            "iam:SimulatePrincipalPolicy"
          ]
          Effect = "Allow"
          Resource = "*"
          Sid = "PolicySimulatorAPI"
        },
        {
          Sid = "PolicySimulatorConsole"
          Action = [
            "iam:GetGroup",
            "iam:GetGroupPolicy",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:GetUser",
            "iam:GetUserPolicy",
            "iam:ListAttachedGroupPolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListAttachedUserPolicies",
            "iam:ListGroups",
            "iam:ListGroupPolicies",
            "iam:ListGroupsForUser",
            "iam:ListRolePolicies",
            "iam:ListRoles",
            "iam:ListUserPolicies",
            "iam:ListUsers"
          ]
          Effect = "Allow"
          Resource = "*"
        },
        {
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::nil-flyte",
            "arn:aws:s3:::nil-flyte/*"
          ]
          Sid = "WriteBuckets"
          Action = [
            "s3:GetObject*",
            "s3:PutObject*",
            "s3:DeleteObject*",
            "s3:ListBucket"
          ]
        }
      ]
    }
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    kubernetes_trusts = [
      {
        service_name = "*"
        namespace = "*"
        open_id_url = "${module.k8scluster.k8s_openid_provider_url}"
        open_id_arn = "${module.k8scluster.k8s_openid_provider_arn}"
      }
    ]
    source = "tqindia/cops/cloud/module/aws_iam_role"
    allowed_k8s_services = [
      {
        service_name = "*"
        namespace = "*"
      }
    ]
    extra_iam_policies = [
      "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
    ]
    links = [
      {
        s3 = [
          "write"
        ]
      }
    ]
    version = "0.0.1"
  }
