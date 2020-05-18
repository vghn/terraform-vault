# Vault Subnets
data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id
}

data "aws_subnet" "primary" {
  id = sort(data.aws_subnet_ids.public.ids)[0]
}

# Allowed IPs
data "dns_a_record_set" "home" {
  host = "home.ghn.me"
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
  cidr_blocks       = formatlist("%s/32", data.dns_a_record_set.home.addrs)
}

resource "aws_security_group_rule" "vault_server" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  security_group_id = aws_security_group.vault.id
  cidr_blocks       = ["0.0.0.0/0"]
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
