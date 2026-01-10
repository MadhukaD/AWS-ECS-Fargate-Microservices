# resource "aws_s3_bucket" "example" {
#   bucket = "example"
# }

# resource "aws_s3_bucket_acl" "example" {
#   bucket = aws_s3_bucket.example.id
#   acl    = "private"
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["codebuild.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "example" {
#   name               = "example"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "aws_iam_policy_document" "example" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = ["*"]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "ec2:CreateNetworkInterface",
#       "ec2:DescribeDhcpOptions",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DescribeSubnets",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeVpcs",
#     ]

#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:CreateNetworkInterfacePermission"]
#     resources = ["arn:aws:ec2:us-east-1:123456789012:network-interface/*"]

#     condition {
#       test     = "StringEquals"
#       variable = "ec2:Subnet"

#       values = [
#         aws_subnet.example1.arn,
#         aws_subnet.example2.arn,
#       ]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "ec2:AuthorizedService"
#       values   = ["codebuild.amazonaws.com"]
#     }
#   }

#   statement {
#     effect  = "Allow"
#     actions = ["s3:*"]
#     resources = [
#       aws_s3_bucket.example.arn,
#       "${aws_s3_bucket.example.arn}/*",
#     ]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "codeconnections:GetConnectionToken",
#       "codeconnections:GetConnection"
#     ]
#     resources = ["arn:aws:codestar-connections:us-east-1:123456789012:connection/guid-string"]
#   }
# }

# resource "aws_iam_role_policy" "example" {
#   role   = aws_iam_role.example.name
#   policy = data.aws_iam_policy_document.example.json
# }

# resource "aws_codebuild_project" "example" {
#   name          = "test-project"
#   description   = "test_codebuild_project"
#   build_timeout = 5
#   service_role  = aws_iam_role.example.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   cache {
#     type     = "S3"
#     location = aws_s3_bucket.example.bucket
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "SOME_KEY1"
#       value = "SOME_VALUE1"
#     }

#     environment_variable {
#       name  = "SOME_KEY2"
#       value = "SOME_VALUE2"
#       type  = "PARAMETER_STORE"
#     }
#   }

#   logs_config {
#     cloudwatch_logs {
#       group_name  = "log-group"
#       stream_name = "log-stream"
#     }

#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.example.id}/build-log"
#     }
#   }

#   source {
#     type            = "CODECOMMIT"
#     location        = "https://github.com/mitchellh/packer.git"
#     git_clone_depth = 1

#     git_submodules_config {
#       fetch_submodules = true
#     }
#   }

#   source_version = "master"

#   vpc_config {
#     vpc_id = aws_vpc.example.id

#     subnets = [
#       aws_subnet.example1.id,
#       aws_subnet.example2.id,
#     ]

#     security_group_ids = [
#       aws_security_group.example1.id,
#       aws_security_group.example2.id,
#     ]
#   }

#   tags = {
#     Environment = "Test"
#   }
# }

# =========================================================
# IAM ROLE (Shared by both CodeBuild projects)
# =========================================================
resource "aws_iam_role" "codebuild_service_role" {
  name = "fargate-microservices-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_service_policy" {
  role = aws_iam_role.codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # -------------------------------
      # CloudWatch Logs
      # -------------------------------
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:ap-southeast-1:348184816643:log-group:/aws/codebuild/*"
        ]
      },

      # -------------------------------
      # S3 (CodePipeline Artifacts)
      # -------------------------------
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::fargate-microservices-artifact-bucket/*"
        ]
      },

      # -------------------------------
      # CodeCommit
      # -------------------------------
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = [
          "arn:aws:codecommit:ap-southeast-1:348184816643:fargate-microservices-code-repo"
        ]
      },

      # -------------------------------
      # ECR (Docker build & push)
      # -------------------------------
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          var.user_ecr_repository_arn,
          var.product_ecr_repository_arn
        ]
      },

      # -------------------------------
      # CodeBuild Reports
      # -------------------------------
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = [
          "arn:aws:codebuild:ap-southeast-1:348184816643:report-group/*"
        ]
      }
    ]
  })
}

# =========================================================
# CODEBUILD PROJECT – PRODUCT SERVICE
# =========================================================
resource "aws_codebuild_project" "product_build" {
  name          = "product-build-project"
  service_role = aws_iam_role.codebuild_service_role.arn

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/fargate-microservices-code-repo"
    buildspec       = "product-service/buildspec.yml"
    git_clone_depth = 1
  }

  source_version = "refs/heads/master"

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/product-build-project"
      stream_name = "build-log"
    }
  }

  tags = {
    Environment = "Dev"
  }
}

# =========================================================
# CODEBUILD PROJECT – USER SERVICE
# =========================================================
resource "aws_codebuild_project" "user_build" {
  name          = "user-build-project"
  service_role = aws_iam_role.codebuild_service_role.arn

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/fargate-microservices-code-repo"
    buildspec       = "user-service/buildspec.yml"
    git_clone_depth = 1
  }

  source_version = "refs/heads/master"

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/user-build-project"
      stream_name = "build-log"
    }
  }
      
  tags = {
    Environment = "Dev"
  }
}
