
  module "adminflyterole"  {
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
          Effect = "Allow"
          Resource = "*"
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
        },
        {
          Sid = "WriteBuckets"
          Action = [
            "s3:GetObject*",
            "s3:PutObject*",
            "s3:DeleteObject*",
            "s3:ListBucket"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::nil-flyte",
            "arn:aws:s3:::nil-flyte/*"
          ]
        },
        {
          Sid = "PublishQueues"
          Action = [
            "sqs:SendMessage",
            "sqs:SendMessageBatch",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes",
            "sqs:DeleteMessageBatch",
            "sqs:DeleteMessage"
          ]
          Effect = "Allow"
          Resource = [
            "${module.notifcationsQueue.queue_arn}",
            "${module.schedulesQueue.queue_arn}"
          ]
        },
        {
          Sid = "SubscribeQueues"
          Action = [
            "sqs:ReceiveMessage",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes"
          ]
          Effect = "Allow"
          Resource = [
            "${module.notifcationsQueue.queue_arn}",
            "${module.schedulesQueue.queue_arn}"
          ]
        },
        {
          Sid = "PublishSns"
          Action = [
            "sns:Publish"
          ]
          Effect = "Allow"
          Resource = [
            "${module.topic.topic_arn}"
          ]
        },
        {
          Sid = "KMSWrite"
          Action = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
          ]
          Effect = "Allow"
          Resource = [
            "${module.notifcationsQueue.kms_arn}",
            "${module.schedulesQueue.kms_arn}",
            "${module.topic.kms_arn}"
          ]
        },
        {
          Effect = "Allow"
          Resource = [
            "${module.notifcationsQueue.kms_arn}",
            "${module.schedulesQueue.kms_arn}"
          ]
          Sid = "KMSRead"
          Action = [
            "kms:Decrypt"
          ]
        }
      ]
    }
    env_name = "flyte-ap-south-1"
    kubernetes_trusts = [
      {
        open_id_url = "${module.k8scluster.k8s_openid_provider_url}"
        open_id_arn = "${module.k8scluster.k8s_openid_provider_arn}"
        service_name = "*"
        namespace = "*"
      }
    ]
    version = "0.0.1"
    allowed_k8s_services = [
      {
        namespace = "*"
        service_name = "*"
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
      },
      "topic",
      "schedulesQueue",
      "notifcationsQueue"
    ]
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_iam_role"
  }
