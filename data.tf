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
