
  module "adminflyterole"  {
    source = "tqindia/cops/cloud/module/aws_iam_role"
    version = "0.0.1"
    extra_iam_policies = [
      "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
    ]
    iam_policy  {
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "PolicySimulatorAPI"
          Action = [
            "iam:GetContextKeysForCustomPolicy",
            "iam:GetContextKeysForPrincipalPolicy",
            "iam:SimulateCustomPolicy",
            "iam:SimulatePrincipalPolicy"
          ]
          Effect = "Allow"
          Resource = "*"
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
        },
        {
          Effect = "Allow"
          Resource = [
            "${module.topic.topic_arn}"
          ]
          Sid = "PublishSnstopic"
          Action = [
            "sns:Publish"
          ]
        },
        {
          Resource = [
            "${module.topic.kms_arn}"
          ]
          Sid = "KMSWritetopic"
          Action = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
          ]
          Effect = "Allow"
        },
        {
          Resource = [
            "${module.schedulesQueue.queue_arn}"
          ]
          Sid = "PublishQueuesschedulesQueue"
          Action = [
            "sqs:SendMessage",
            "sqs:SendMessageBatch",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes",
            "sqs:DeleteMessageBatch",
            "sqs:DeleteMessage"
          ]
          Effect = "Allow"
        },
        {
          Sid = "SubscribeQueuesschedulesQueue"
          Action = [
            "sqs:ReceiveMessage",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes"
          ]
          Effect = "Allow"
          Resource = [
            "${module.schedulesQueue.queue_arn}"
          ]
        },
        {
          Sid = "KMSWriteschedulesQueue"
          Action = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
          ]
          Effect = "Allow"
          Resource = [
            "${module.schedulesQueue.kms_arn}"
          ]
        },
        {
          Sid = "PublishQueuesnotifcationsQueue"
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
            "${module.notifcationsQueue.queue_arn}"
          ]
        },
        {
          Resource = [
            "${module.notifcationsQueue.queue_arn}"
          ]
          Sid = "SubscribeQueuesnotifcationsQueue"
          Action = [
            "sqs:ReceiveMessage",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes"
          ]
          Effect = "Allow"
        },
        {
          Sid = "KMSWritenotifcationsQueue"
          Action = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
          ]
          Effect = "Allow"
          Resource = [
            "${module.notifcationsQueue.kms_arn}"
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
    allowed_k8s_services = [
      {
        namespace = "*"
        service_name = "*"
      }
    ]
    allowed_iams = [
      "undefined"
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
  }
