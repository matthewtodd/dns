# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "com_matthewtodd" {
 name = "matthewtodd.com"
}

output "name_servers" {
  value = aws_route53_zone.com_matthewtodd.name_servers
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "com_matthewtodd_mx" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "matthewtodd.com"
  type    = "MX"
  ttl     = 3600
  records = [
    "10 mx01.mail.icloud.com.",
    "10 mx02.mail.icloud.com."
  ]
}

resource "aws_route53_record" "com_matthewtodd_spf" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "matthewtodd.com"
  type    = "SPF"
  ttl     = 3600
  records = ["v=spf1 redirect=icloud.com"]
}

resource "aws_route53_record" "com_matthewtodd_txt" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "matthewtodd.com"
  type    = "TXT"
  ttl     = 3600
  records = [
    "apple-domain=OV6hdxtj1YUKXaWo",
    "v=spf1 redirect=icloud.com"
  ]
}

resource "aws_route53_record" "com_matthewtodd__dmarc" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "_dmarc.matthewtodd.com"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=reject"]
}

resource "aws_route53_record" "com_matthewtodd__domainkey" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "sig1._domainkey.matthewtodd.com"
  type    = "CNAME"
  ttl     = 3600
  records = ["sig1.dkim.matthewtodd.com.at.icloudmailadmin.com."]
}
