# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "matthewtodd_com" {
  name = "matthewtodd.com"
}

output "name_servers" {
  value = aws_route53_zone.matthewtodd_com.name_servers
}

# I need a bucket that redirects to matthewtodd.org, and an A record that points to it.
# How do S3 websites work again?
# https://developer.hashicorp.com/terraform/tutorials/aws/cloudflare-static-website

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "matthewtodd.com"
  type    = "MX"
  ttl     = 3600
  records = [
    "10 mx01.mail.icloud.com.",
    "10 mx02.mail.icloud.com."
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "matthewtodd.com"
  type    = "SPF"
  ttl     = 3600
  records = ["v=spf1 redirect=icloud.com"]
}

resource "aws_route53_record" "txt" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "matthewtodd.com"
  type    = "TXT"
  ttl     = 3600
  records = [
    "apple-domain=OV6hdxtj1YUKXaWo",
    "v=spf1 redirect=icloud.com"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "_dmarc.matthewtodd.com"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=reject"]
}

resource "aws_route53_record" "github_pages_challenge" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "_github-pages-challenge-matthewtodd.matthewtodd.com"
  type    = "TXT"
  ttl     = 3600
  records = ["d34cfe9b1b2d02ff913e43ca08cd54"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "www.matthewtodd.com"
  type    = "CNAME"
  ttl     = 3600
  records = ["matthewtodd.github.io."]
}

resource "aws_route53_record" "domainkey" {
  zone_id = aws_route53_zone.matthewtodd_com.zone_id
  name    = "sig1._domainkey.matthewtodd.com"
  type    = "CNAME"
  ttl     = 3600
  records = ["sig1.dkim.matthewtodd.com.at.icloudmailadmin.com."]
}
