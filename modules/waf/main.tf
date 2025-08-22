resource "aws_wafv2_web_acl" "main" {
  name        = "${var.prefix}-waf-web-acl"
  description = "WAF Web ACL for ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "MethodWhitelist"
    priority = 10

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string         = "GET"
                positional_constraint = "EXACTLY"
                field_to_match {
                  method {}
                }
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string         = "POST"
                positional_constraint = "EXACTLY"
                field_to_match {
                  method {}
                }
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
        statement {
          not_statement {
            statement {
              byte_match_statement {
                search_string         = "HEAD"
                positional_constraint = "EXACTLY"
                field_to_match {
                  method {}
                }
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MethodWhitelistMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "PathWhitelist"
    priority = 20

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.path_whitelist.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "PathWhitelistMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "MaliciousPathBlock"
    priority = 30

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.malicious_paths.arn
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 1
          type     = "LOWERCASE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MaliciousPathBlockMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "UserEmailValidation"
    priority = 40

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string         = "/v1/user"
            positional_constraint = "STARTS_WITH"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "POST"
            positional_constraint = "EXACTLY"
            field_to_match {
              method {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          not_statement {
            statement {
              regex_pattern_set_reference_statement {
                arn = aws_wafv2_regex_pattern_set.email_pattern.arn
                field_to_match {
                  body {
                    oversize_handling = "CONTINUE"
                  }
                }
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UserEmailValidationMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BlockedUserAgents"
    priority = 50

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.blocked_user_agents.arn
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        text_transformation {
          priority = 1
          type     = "LOWERCASE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockedUserAgentsMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFWebACLMetric"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

resource "aws_wafv2_regex_pattern_set" "path_whitelist" {
  name        = "${var.prefix}-path-whitelist"
  description = "Allowed paths"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "^/(v1/(user|product|stress)|healthcheck)$"
  }

  tags = var.common_tags
}

resource "aws_wafv2_regex_pattern_set" "malicious_paths" {
  name        = "${var.prefix}-malicious-paths"
  description = "Malicious paths to block"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "/(wp-admin|phpmyadmin|admin|config|\\.env|\\.git|\\.svn)"
  }

  tags = var.common_tags
}

resource "aws_wafv2_regex_pattern_set" "email_pattern" {
  name        = "${var.prefix}-email-pattern"
  description = "Email validation pattern"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"
  }

  tags = var.common_tags
}

resource "aws_wafv2_regex_pattern_set" "blocked_user_agents" {
  name        = "${var.prefix}-blocked-user-agents"
  description = "Blocked user agents"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "(bot|crawler|spider|scraper|curl|wget|python|java|perl|ruby)"
  }

  tags = var.common_tags
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "/aws/wafv2/${var.prefix}-waf"
  retention_in_days = 7

  tags = var.common_tags
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}
