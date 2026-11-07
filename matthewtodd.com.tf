resource "aws_route53_zone" "com_matthewtodd" {
 name = "matthewtodd.com"
}

output "com_matthewtodd_name_servers" {
  value = aws_route53_zone.com_matthewtodd.name_servers
}

#-----------------------------------------------------------------------
# Cert
#-----------------------------------------------------------------------
resource "aws_acm_certificate" "com_matthewtodd_redirect_cert" {
  domain_name = "matthewtodd.com"
  validation_method = "DNS"
  subject_alternative_names = ["www.matthewtodd.com"]
}

resource "aws_route53_record" "com_matthewtodd_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.com_matthewtodd_redirect_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "com_matthewtodd_cert" {
  certificate_arn         = aws_acm_certificate.com_matthewtodd_redirect_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.com_matthewtodd_cert_validation : record.fqdn]
}

#-----------------------------------------------------------------------
# Cloudfront
#-----------------------------------------------------------------------
resource "aws_cloudfront_function" "com_matthewtodd_redirect" {
  name = "redirect-to-matthewtodd-org"
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

resource "aws_cloudfront_distribution" "com_matthewtodd_redirect_distribution" {
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

  aliases = ["matthewtodd.com", "www.matthewtodd.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "DummyOrigin"
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.com_matthewtodd_redirect.arn
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
    acm_certificate_arn      = aws_acm_certificate_validation.com_matthewtodd_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

#-----------------------------------------------------------------------
# DNS
#-----------------------------------------------------------------------
resource "aws_route53_record" "com_matthewtodd_a" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "matthewtodd.com"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.com_matthewtodd_redirect_distribution.domain_name
    zone_id = aws_cloudfront_distribution.com_matthewtodd_redirect_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

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

resource "aws_route53_record" "com_matthewtodd_www" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "www.matthewtodd.com"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.com_matthewtodd_redirect_distribution.domain_name
    zone_id = aws_cloudfront_distribution.com_matthewtodd_redirect_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "com_matthewtodd__domainkey" {
  zone_id = aws_route53_zone.com_matthewtodd.zone_id
  name    = "sig1._domainkey.matthewtodd.com"
  type    = "CNAME"
  ttl     = 3600
  records = ["sig1.dkim.matthewtodd.com.at.icloudmailadmin.com."]
}
