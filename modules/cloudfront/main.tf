resource "aws_cloudfront_cache_policy" "all_headers_short_ttl" {
  name        = "${var.prefix}-all-headers-short-ttl"
  default_ttl = var.default_ttl
  max_ttl     = var.max_ttl
  min_ttl     = var.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "all_headers_user_ttl" {
  name        = "${var.prefix}-all-headers-user-ttl"
  default_ttl = var.user_default_ttl
  max_ttl     = var.user_max_ttl
  min_ttl     = var.user_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "all_headers_product_ttl" {
  name        = "${var.prefix}-all-headers-product-ttl"
  default_ttl = var.product_default_ttl
  max_ttl     = var.product_max_ttl
  min_ttl     = var.product_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "${var.prefix}-all-viewer"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = var.enabled
  comment         = var.comment
  is_ipv6_enabled = true
  price_class     = var.price_class

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "${var.prefix}-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.prefix}-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    ]
    cached_methods = ["GET", "HEAD", "OPTIONS"]

    compress = true

    cache_policy_id            = aws_cloudfront_cache_policy.all_headers_short_ttl.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/v1/user*"
    target_origin_id       = "${var.prefix}-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    ]
    cached_methods = ["GET", "HEAD", "OPTIONS"]

    compress = true

    cache_policy_id          = aws_cloudfront_cache_policy.all_headers_user_ttl.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/v1/product*"
    target_origin_id       = "${var.prefix}-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    ]
    cached_methods = ["GET", "HEAD", "OPTIONS"]

    compress = true

    cache_policy_id          = aws_cloudfront_cache_policy.all_headers_product_ttl.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
  }

  ordered_cache_behavior {
    path_pattern           = "/v1/stress*"
    target_origin_id       = "${var.prefix}-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    ]
    cached_methods = ["GET", "HEAD", "OPTIONS"]

    compress = true

    cache_policy_id          = aws_cloudfront_cache_policy.all_headers_short_ttl.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-cloudfront"
  })
}
