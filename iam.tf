# Vault Instance Role
resource "aws_iam_instance_profile" "vault" {
  name = "vault"
  role = aws_iam_role.vault.name
}

resource "aws_iam_role" "vault" {
  name               = "vault"
  description        = "Vault"
  assume_role_policy = data.aws_iam_policy_document.vault_trust.json
}

data "aws_iam_policy_document" "vault_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "vault" {
  name   = "vault"
  role   = aws_iam_role.vault.name
  policy = data.aws_iam_policy_document.vault_role.json
}

data "aws_iam_policy_document" "vault_role" {
  statement {
    sid       = "AllowAssumeRole"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  # Used by the AWS authentication backend
  statement {
    sid = "AllowIAMAuth"

    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid       = "AllowS3ListAllBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid     = "AllowS3AccessToAssetsBucket"
    actions = ["*"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.vault.id}",
      "arn:aws:s3:::${aws_s3_bucket.vault.id}/*",
    ]
  }

  statement {
    sid = "AllowKMSUse"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["arn:aws:kms:*:*:alias/aws/s3"]
  }
}

resource "aws_iam_role_policy_attachment" "vault_dynamodb" {
  role       = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
