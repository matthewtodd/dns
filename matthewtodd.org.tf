resource "aws_route53_zone" "org_matthewtodd" {
  name = "matthewtodd.org"
}

output "org_matthewtodd_name_servers" {
  value = aws_route53_zone.org_matthewtodd.name_servers
}

resource "aws_route53_record" "org_matthewtodd_a" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "matthewtodd.org"
  type    = "A"
  ttl     = 3600
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

resource "aws_route53_record" "org_matthewtodd_aaaa" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "matthewtodd.org"
  type    = "AAAA"
  ttl     = 3600
  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153"
  ]
}

resource "aws_route53_record" "org_matthewtodd_mx" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "matthewtodd.org"
  type    = "MX"
  ttl     = 3600
  records = [
    "10 mx01.mail.icloud.com.",
    "10 mx02.mail.icloud.com."
  ]
}

resource "aws_route53_record" "org_matthewtodd_spf" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "matthewtodd.org"
  type    = "SPF"
  ttl     = 3600
  records = ["v=spf1 redirect=icloud.com"]
}

resource "aws_route53_record" "org_matthewtodd_txt" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "matthewtodd.org"
  type    = "TXT"
  ttl     = 3600
  records = [
    "apple-domain=1wvGvooGgBJbLE6A",
    "v=spf1 redirect=icloud.com"
  ]
}

resource "aws_route53_record" "org_matthewtodd__atproto" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "_atproto.matthewtodd.org"
  type    = "TXT"
  ttl     = 3600
  records = ["did=did:plc:q5r24vxbohsa7fopgxylynu4"]
}

resource "aws_route53_record" "org_matthewtodd__dmarc" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "_dmarc.matthewtodd.org"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=reject"]
}

resource "aws_route53_record" "org_matthewtodd__github_pages_challenge" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "_github-pages-challenge-matthewtodd.matthewtodd.org"
  type    = "TXT"
  ttl     = 3600
  records = ["d34cfe9b1b2d02ff913e43ca08cd54"]
}

resource "aws_route53_record" "org_matthewtodd__perquackey" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "perquackey.matthewtodd.org"
  type    = "CNAME"
  ttl     = 3600
  records = ["matthewtodd.github.io."]
}

resource "aws_route53_record" "org_matthewtodd__www" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "www.matthewtodd.org"
  type    = "CNAME"
  ttl     = 3600
  records = ["matthewtodd.github.io."]
}

resource "aws_route53_record" "org_matthewtodd__domainkey" {
  zone_id = aws_route53_zone.org_matthewtodd.zone_id
  name    = "sig1._domainkey.matthewtodd.org"
  type    = "CNAME"
  ttl     = 3600
  records = ["sig1.dkim.matthewtodd.org.at.icloudmailadmin.com."]
}
