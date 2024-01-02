########################################################################################################
# IAM POLICY DATA'S
########################################################################################################
// Lambda Function Role - Assume Role Policy Data
data "aws_iam_policy_document" "aws_nuke_lambda_function_role_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// Allow access to all compute based resources
data "aws_iam_policy_document" "aws_nuke_lambda_function_role_compute_permissions" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeSpotFleetRequests",
      "ec2:DeleteSpotInstanceRequest",
      "ec2:DescribeLaunchTemplates",
      "ec2:DeleteLaunchTemplate",
      "ec2:DescribeSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DeleteVolume",
      "ec2:DescribeKeyPairs",
      "ec2:DeleteKeyPair",
      "ec2:DescribePlacementGroups",
      "ec2:DeletePlacementGroup",
      "ec2:DescribeImages",
      "ec2:DeregisterImage",
      "dlm:GetLifecyclePolicy",
      "dlm:GetLifecyclePolicies",
      "dlm:DeleteLifecyclePolicy",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DeleteLaunchConfiguration",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DeleteTargetGroup",
      "ecr:DescribeRepositories",
      "ecr:DeleteRepository",
      "eks:ListClusters",
      "eks:DescribeCluster",
      "eks:DeleteCluster",
      "elasticbeanstalk:DescribeApplications",
      "elasticbeanstalk:DescribeEnvironments",
      "elasticbeanstalk:DeleteApplication",
      "elasticbeanstalk:TerminateEnvironment"
    ]

    resources = [
      "*",
    ]
  }
}

// Allow access to all storage based resources
data "aws_iam_policy_document" "aws_nuke_lambda_function_role_storage_permissions" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DeleteFileSystem",
      "glacier:ListVaults",
      "glacier:DescribeVault",
      "glacier:DeleteVault"
    ]

    resources = [
      "*",
    ]
  }
}

// Allow access to all database based resources
data "aws_iam_policy_document" "aws_nuke_lambda_function_role_database_permissions" {
  statement {
    actions = [
      "rds:DescribeDBClusters",
      "rds:DeleteDBCluster",
      "rds:DescribeDBInstances",
      "rds:DeleteDBInstance",
      "rds:DescribeDBSubnetGroups",
      "rds:DeleteDBSubnetGroup",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DeleteDBClusterParameterGroup",
      "rds:DescribeDBParameterGroups",
      "rds:DeleteDBParameterGroup",
      "rds:DescribeDBClusterSnapshots",
      "rds:DeleteDBClusterSnapshot",
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteTable",
      "dynamodb:ListBackups",
      "dynamodb:DescribeBackup",
      "dynamodb:DeleteBackup",
      "elasticache:DescribeCacheClusters",
      "elasticache:DeleteCacheCluster",
      "elasticache:DescribeSnapshots",
      "elasticache:DeleteSnapshot",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DeleteCacheSubnetGroup",
      "elasticache:DescribeCacheParameterGroups",
      "elasticache:DeleteCacheParameterGroup",
      "redshift:DescribeClusters",
      "redshift:DeleteCluster",
      "redshift:DescribeClusterSnapshots",
      "redshift:DeleteClusterSnapshot",
      "redshift:DescribeClusterParameterGroups",
      "redshift:DeleteClusterParameterGroup",
      "redshift:DescribeClusterSubnetGroups",
      "redshift:DeleteClusterSubnetGroup"
    ]

    resources = [
      "*",
    ]
  }
}

// Allow access to all network based resources
data "aws_iam_policy_document" "aws_nuke_lambda_function_role_network_permissions" {
  statement {
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeNetworkAcls",
      "ec2:DeleteNetworkAcl",
      "ec2:DescribeVpcEndpoints",
      "ec2:DeleteVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:DescribeNatGateways",
      "ec2:DeleteNatGateway",
      "ec2:DescribeAddresses",
      "ec2:ReleaseAddress",
      "ec2:DescribeRouteTables",
      "ec2:DeleteRouteTable",
      "ec2:DescribeInternetGateways",
      "ec2:DeleteInternetGateway",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DeleteEgressOnlyInternetGateway",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "aws_nuke_lambda_function_role_analytic_and_logging_permissions" {
  statement {
    actions = [
      "elasticmapreduce:ListClusters",
      "elasticmapreduce:TerminateJobFlows",
      "kafka:ListClusters",
      "kafka:DeleteCluster",
      "cloudwatch:ListDashboards",
      "cloudwatch:DeleteDashboards",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]

    resources = [
      "*",
    ]
  }
}

########################################################################################################
# IAM ROLES AND POLICIES
########################################################################################################
// Create IAM role for the Lambda function
resource "aws_iam_role" "aws-nuke-lambda-function-role" {
  count              = var.do_enable_automatic_resource_destroy ? 1 : 0
  name               = "aws-nuke-lambda-role"
  description        = "Allows Lambda functions to destroy all aws resources"
  assume_role_policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_assume_role_policy.json
}

########################################################################################################
# IAM ROLE POLICY CREATION AND ATTACHMENT
########################################################################################################

// Create compute policy and attach it to Lambda Function's role
resource "aws_iam_role_policy" "aws-nuke-lambda-function-role-compute-policy" {
  count  = var.do_enable_automatic_resource_destroy ? 1 : 0
  name   = "aws-nuke-lambda-function-role-compute-policy"
  role   = aws_iam_role.aws-nuke-lambda-function-role[0].id
  policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_compute_permissions.json
}

// Create storage policy and attach it to Lambda Function's role
resource "aws_iam_role_policy" "aws-nuke-lambda-function-role-storage-policy" {
  count  = var.do_enable_automatic_resource_destroy ? 1 : 0
  name   = "aws-nuke-lambda-function-role-storage-policy"
  role   = aws_iam_role.aws-nuke-lambda-function-role[0].id
  policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_storage_permissions.json
}

// Create database policy and attach it to Lambda Function's role
resource "aws_iam_role_policy" "aws-nuke-lambda-function-role-database-policy" {
  count  = var.do_enable_automatic_resource_destroy ? 1 : 0
  name   = "aws-nuke-lambda-function-role-databse-policy"
  role   = aws_iam_role.aws-nuke-lambda-function-role[0].id
  policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_database_permissions.json
}

// Create network policy and attach it to Lambda Function's role
resource "aws_iam_role_policy" "aws-nuke-lambda-function-role-network-policy" {
  count  = var.do_enable_automatic_resource_destroy ? 1 : 0
  name   = "aws-nuke-lambda-function-role-network-policy"
  role   = aws_iam_role.aws-nuke-lambda-function-role[0].id
  policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_network_permissions.json
}

// Create logging and analytics policy and attach it to Lambda Function's role
resource "aws_iam_role_policy" "aws-nuke-lambda-function-role-analytics-and-logs-policy" {
  count  = var.do_enable_automatic_resource_destroy ? 1 : 0
  name   = "aws-nuke-lambda-function-role-analytics-and-logs-policy"
  role   = aws_iam_role.aws-nuke-lambda-function-role[0].id
  policy = data.aws_iam_policy_document.aws_nuke_lambda_function_role_analytic_and_logging_permissions.json
}

########################################################################################################
# LAMBDA FUNCTION RELATED POLICIES AND PERMISSIONS
########################################################################################################
// Setup invocation permissions for SNS to trigger our Lambda function
resource "aws_lambda_permission" "aws-nuke-lambda-allow-sns-invocation" {
  count         = var.do_enable_automatic_resource_destroy ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.aws-nuke-lambda[0].nuke-function-name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_spend_limit_lambda_trigger[0].sns_topic_arn
}