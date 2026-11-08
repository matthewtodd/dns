resource "aws_route53_zone" "family_todd" {
 name = "todd.family"
}

output "family_todd_name_servers" {
  value = aws_route53_zone.family_todd.name_servers
}

#-----------------------------------------------------------------------
# Cert
#-----------------------------------------------------------------------
resource "aws_acm_certificate" "family_todd_redirect_cert" {
  domain_name = "todd.family"
  validation_method = "DNS"
  subject_alternative_names = ["www.todd.family"]
}

resource "aws_route53_record" "family_todd_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.family_todd_redirect_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.family_todd.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "family_todd_cert" {
  certificate_arn         = aws_acm_certificate.family_todd_redirect_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.family_todd_cert_validation : record.fqdn]
}

#-----------------------------------------------------------------------
# Cloudfront
#-----------------------------------------------------------------------
resource "aws_cloudfront_function" "family_todd_redirect" {
  name = "redirect-todd-family-to-matthewtodd-org"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<EOF
function handler(event) {
  return {
    statusCode: 307,
    statusDescription: 'Temporary Redirect',
    headers: {
      'location': { 'value': 'https://matthewtodd.org' + event.request.uri }
    }
  };
}
EOF
}

resource "aws_cloudfront_distribution" "family_todd_redirect_distribution" {
  origin {
    domain_name = "example.com"
    origin_id   = "DummyOrigin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["todd.family", "www.todd.family"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "DummyOrigin"
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.family_todd_redirect.arn
    }

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.family_todd_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

#-----------------------------------------------------------------------
# DNS
#-----------------------------------------------------------------------
resource "aws_route53_record" "family_todd_a" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "todd.family"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.family_todd_redirect_distribution.domain_name
    zone_id = aws_cloudfront_distribution.family_todd_redirect_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "family_todd_mx" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "todd.family"
  type    = "MX"
  ttl     = 3600
  records = [
    "10 mx01.mail.icloud.com.",
    "10 mx02.mail.icloud.com."
  ]
}

resource "aws_route53_record" "family_todd_spf" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "todd.family"
  type    = "SPF"
  ttl     = 3600
  records = ["v=spf1 redirect=icloud.com"]
}

resource "aws_route53_record" "family_todd_txt" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "todd.family"
  type    = "TXT"
  ttl     = 3600
  records = [
    "apple-domain=nQiZ7uxKAyz9V2IP",
    "v=spf1 redirect=icloud.com"
  ]
}

resource "aws_route53_record" "family_todd__dmarc" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "_dmarc.todd.family"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=reject"]
}

resource "aws_route53_record" "family_todd_www" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "www.todd.family"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.family_todd_redirect_distribution.domain_name
    zone_id = aws_cloudfront_distribution.family_todd_redirect_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "family_todd__domainkey" {
  zone_id = aws_route53_zone.family_todd.zone_id
  name    = "sig1._domainkey.todd.family"
  type    = "CNAME"
  ttl     = 3600
  records = ["sig1.dkim.todd.family.at.icloudmailadmin.com."]
}
