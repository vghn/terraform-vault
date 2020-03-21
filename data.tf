# Vault Data Volume
resource "aws_ebs_volume" "vault_data" {
  availability_zone = "us-east-1a"
  type              = "gp2"
  encrypted         = true
  size              = 2

  tags = merge(
    var.common_tags,
    {
      "Name"     = "Vault Data"
      "Snapshot" = "true"
    },
  )
}

resource "aws_volume_attachment" "vault_data_attachment" {
  device_name  = "/dev/sdg"
  instance_id  = aws_instance.vault.id
  volume_id    = aws_ebs_volume.vault.id
  skip_destroy = true
}

# Vault HA DynamoDB table
resource "aws_dynamodb_table" "vault" {
  name           = "vault"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Path"
  range_key      = "Key"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "Vault"
    },
  )
}
