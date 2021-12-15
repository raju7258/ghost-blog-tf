resource "aws_cloudfront_distribution" "alb_distribution" {
    enabled                        = true
    http_version                   = "http2"
    is_ipv6_enabled                = true
    price_class                    = "PriceClass_All"
    retain_on_delete               = false
    wait_for_deployment            = true
    web_acl_id                     = var.wafid
    aliases                        = [var.var_aliases]
    comment                        = "Ghost ${var.env} Cloudfront"
    default_cache_behavior {
        allowed_methods        = var.allowed_methods
        cached_methods         = ["GET","HEAD",]
        compress               = true
        default_ttl            = 0
        max_ttl                = 0
        min_ttl                = 0
        smooth_streaming       = false
        target_origin_id       = "ghost-${var.env}"
        trusted_key_groups     = []
        trusted_signers        = []
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id          = var.cachingdisabled
        origin_request_policy_id = var.allviewer
    }
   ordered_cache_behavior {
      allowed_methods          = [
              "GET",
              "HEAD",
              "OPTIONS",
            ]
      cached_methods           = [
              "GET",
              "HEAD",
            ]
      path_pattern             = "/*"
      target_origin_id         = "ghost-${var.env}"
      viewer_protocol_policy   = "redirect-to-https"
      compress                 = true
      cache_policy_id          = var.cachingoptimized
      origin_request_policy_id = var.allviewer

   }

   origin_group {
       origin_id = "ghost-${var.env}"

       failover_criteria {
            status_codes = [403, 404]
       }
       member {
           origin_id = "primary"
       }
       member {
           origin_id = "secondary"
       }
   }
   
    origin {
        connection_attempts = 3
        connection_timeout  = 10
        domain_name         = var.var_albdns
        origin_id           = "primary"

        custom_origin_config {
            http_port                = 80
            https_port               = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy   = "match-viewer"
            origin_read_timeout      = 30
            origin_ssl_protocols     = [
                "TLSv1.2",
            ]
        }
    }

    origin {
        connection_attempts = 3
        connection_timeout  = 10
        domain_name         = var.var_sec_albdns
        origin_id           = "secondary"

        custom_origin_config {
            http_port                = 80
            https_port               = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy   = "match-viewer"
            origin_read_timeout      = 30
            origin_ssl_protocols     = [
                "TLSv1.2",
            ]
        }
    }

    logging_config {
      include_cookies = false
      bucket          = "${aws_s3_bucket.cloudfrontlogs.bucket}.s3.amazonaws.com"
    }

    restrictions {
        geo_restriction {
            locations        = []
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = false
        minimum_protocol_version       = "TLSv1.2_2019"
        ssl_support_method             = "sni-only"
        acm_certificate_arn            = var.var_acm

    }

    depends_on = [
        aws_s3_bucket.cloudfrontlogs
    ]
}

resource "aws_s3_bucket" "cloudfrontlogs" {
  bucket = "ghost-${var.env}-cf-logs"
  acl    = "private"

}