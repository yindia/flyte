
  module "userflyterole"  {
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    allowed_iams = [
      
    ]
    extra_iam_policies = [
      "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
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
          Sid = "WriteBucketss3"
          Action = [
            "s3:GetObject*",
            "s3:PutObject*",
            "s3:DeleteObject*",
            "s3:ListBucket"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::flyte-storage",
            "arn:aws:s3:::flyte-storage/*"
          ]
        }
      ]
    }
    links = [
      {
        s3 = [
          "write"
        ]
      }
    ]
    layer_name = "flyte-ap-south-1"
    kubernetes_trusts = [
      {
        open_id_url = "${module.k8scluster.k8s_openid_provider_url}"
        open_id_arn = "${module.k8scluster.k8s_openid_provider_arn}"
        service_name = "*"
        namespace = "*"
      }
    ]
    source = "tqindia/cops/cloud/module/aws_iam_role"
    allowed_k8s_services = [
      {
        namespace = "*"
        service_name = "*"
      }
    ]
  }
