locals {
  s3_origin_id = var.dns_name
}

resource "aws_cloudfront_distribution" "cloudfront" {

  origin {
    domain_name = aws_s3_bucket.download-bucket.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy = "http-only"
      origin_read_timeout = 30
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "cloudfront-${var.bucket_name}"
  default_root_object = "index.html"

  aliases = [var.dns_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 3600
    default_ttl            = 86400
    max_ttl                = 604800
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations = [
        "AM",
        "AZ",
        "BY",
        "CD",
        "CI",
        "ER",
        "GN",
        "IQ",
        "IR",
        "KP",
        "LB",
        "LR",
        "LY",
        "MM",
        "SD",
        "SL",
        "SO",
        "SS",
        "SY",
        "ZW"
      ]
    }
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
    cloudfront_default_certificate = true
  }
}
