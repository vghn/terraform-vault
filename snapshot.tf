# Data Lifecycle Manager (DLM) lifecycle policy for managing snapshots
resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role"
  description        = "Data Lifecycle Manager (DLM) lifecycle role for managing snapshots"
  assume_role_policy = data.aws_iam_policy_document.dlm_lifecycle_trust.json
}

data "aws_iam_policy_document" "dlm_lifecycle_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "dlm-lifecycle-policy"
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

data "aws_iam_policy_document" "dlm_lifecycle" {
  statement {
    sid = "AllowSnapshots"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowSnasphotTagging"

    actions = [
      "ec2:CreateTags",
    ]

    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

resource "aws_dlm_lifecycle_policy" "backup" {
  description        = "Vauilt DLM lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    target_tags = {
      Snapshot = "true"
    }

    schedule {
      name = "1 week of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["09:09"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true
    }
  }
}
