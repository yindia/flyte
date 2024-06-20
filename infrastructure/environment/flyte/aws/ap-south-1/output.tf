
  output = [
    {
      role_arn = {
        value = "${module.adminflyterole.role_arn}"
      }
    },
    {
      role_arn = {
        value = "${module.userflyterole.role_arn}"
      }
    },
    {
      bucket_arn = {
        value = "${module.s3.bucket_arn}"
      }
    },
    {
      bucket_id = {
        value = "${module.s3.bucket_id}"
      }
    },
    {
      cloudfront_read_path = {
        value = "${module.s3.cloudfront_read_path}"
      }
    },
    {
      global_database_id = {
        value = "${module.postgres.global_database_id}"
      }
    },
    {
      db_user = {
        value = "${module.postgres.db_user}"
      }
    },
    {
      db_password = {
        value = "${module.postgres.db_password}"
      }
    },
    {
      db_host = {
        value = "${module.postgres.db_host}"
      }
    },
    {
      db_name = {
        value = "${module.postgres.db_name}"
      }
    },
    {
      topic_arn = {
        value = "${module.topic.topic_arn}"
      }
    },
    {
      kms_arn = {
        value = "${module.topic.kms_arn}"
      }
    },
    {
      queue_arn = {
        value = "${module.schedulesQueue.queue_arn}"
      }
    },
    {
      queue_name = {
        value = "${module.schedulesQueue.queue_name}"
      }
    },
    {
      queue_id = {
        value = "${module.schedulesQueue.queue_id}"
      }
    },
    {
      kms_arn = {
        value = "${module.schedulesQueue.kms_arn}"
      }
    },
    {
      queue_arn = {
        value = "${module.notifcationsQueue.queue_arn}"
      }
    },
    {
      queue_name = {
        value = "${module.notifcationsQueue.queue_name}"
      }
    },
    {
      queue_id = {
        value = "${module.notifcationsQueue.queue_id}"
      }
    },
    {
      kms_arn = {
        value = "${module.notifcationsQueue.kms_arn}"
      }
    },
    {
      k8s_endpoint = {
        value = "${module.k8scluster.k8s_endpoint}"
      }
    },
    {
      k8s_ca_data = {
        value = "${module.k8scluster.k8s_ca_data}"
      }
    },
    {
      k8s_cluster_name = {
        value = "${module.k8scluster.k8s_cluster_name}"
      }
    },
    {
      k8s_openid_provider_url = {
        value = "${module.k8scluster.k8s_openid_provider_url}"
      }
    },
    {
      k8s_openid_provider_arn = {
        value = "${module.k8scluster.k8s_openid_provider_arn}"
      }
    },
    {
      k8s_node_group_security_id = {
        value = "${module.k8scluster.k8s_node_group_security_id}"
      }
    },
    {
      k8s_version = {
        value = "${module.k8scluster.k8s_version}"
      }
    },
    {
      vpc_id = {
        value = "${module.base.vpc_id}"
      }
    },
    {
      kms_account_key_arn = {
        value = "${module.base.kms_account_key_arn}"
      }
    },
    {
      private_subnet_ids = {
        value = "${module.base.private_subnet_ids}"
      }
    }
  ]
