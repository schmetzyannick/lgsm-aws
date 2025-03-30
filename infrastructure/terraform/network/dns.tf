resource "aws_route53_zone" "dns-zone" {
  name = var.zone-name
}