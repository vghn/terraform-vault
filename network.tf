# Vault Subnets
data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id
}

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.public.ids)}"
  id    = "${data.aws_subnet_ids.public.ids[count.index]}"
}

locals {
  subnet_ids_sorted_by_az  = "${values(zipmap(data.aws_subnet.public.*.availability_zone, data.aws_subnet.public.*.id))}"
  subnet_cidr_sorted_by_az = "${values(zipmap(data.aws_subnet.public.*.availability_zone, data.aws_subnet.public.*.cidr_block))}"
}

# Vault Instance Security Group
resource "aws_security_group" "vault" {
  name        = "Vault"
  description = " Vault Security Group"
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_security_group_rule" "vault_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vault.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault_server" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  security_group_id = aws_security_group.vault.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault_monitoring" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.vault.id
  cidr_blocks       = ["${var.monitoring_ip}/32"]
}

resource "aws_security_group_rule" "vault_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.vault.id
  source_security_group_id = aws_security_group.vault.id
}

resource "aws_security_group_rule" "vault_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vault.id
  cidr_blocks       = ["0.0.0.0/0"]
}
