data "aws_route53_zone" "main" {
  name = "${var.my_hosted_zone}." # Note the trailing dot
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.my_hosted_zone}" # Subdomain you want to route
  type    = "A"

  alias {
    name                   = aws_lb.alb_region1.dns_name
    zone_id                = aws_lb.alb_region1.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.my_hosted_zone
  type    = "A"

  alias {
    name                   = aws_lb.alb_region1.dns_name
    zone_id                = aws_lb.alb_region1.zone_id
    evaluate_target_health = true
  }
}

# 1. Request an ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = var.my_hosted_zone
  subject_alternative_names = ["*.${var.my_hosted_zone}"] # Covers all subdomains
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    env     = "prod"
    project = var.project_name
  }
}

# 2. Create DNS records for ACM validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# 3. Certificate Validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 4. Create HTTPS Listener for ALB
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb_region1.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_region1.arn
  }
}

# 5. Optional: HTTP to HTTPS Redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_region1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
