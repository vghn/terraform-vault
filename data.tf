# Vault Data Volume
data "aws_instance" "vault" {
  instance_id = aws_instance.vault.id
}

resource "aws_ebs_volume" "vault_data" {
  availability_zone = data.aws_subnet.primary.availability_zone
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
  volume_id    = aws_ebs_volume.vault_data.id
  skip_destroy = true
}
