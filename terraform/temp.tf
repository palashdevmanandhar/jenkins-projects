# # aws provider region for the project
# variable "region1" {
#   type        = string
#   default     = "us-east-1"
#   description = "virginia region and the default region"
# }

# variable "region2" {
#   type        = string
#   default     = "us-west-2"
#   description = "oregon region"
# }

# variable "availability_zone2_region1" {
#   type        = string
#   default     = "us-east-1b"
#   description = "second az region one"
# }



# variable "availability_zone_region1" {
#   type        = string
#   default     = "us-east-1a"
#   description = "default az region one"
# }

# variable "availability_zone_region2" {
#   type        = string
#   default     = "us-west-2a"
#   description = "default az region 2"
# }



# variable "deafult_vpc_id" {
#   type        = string
#   default     = "vpc-08dc24ade02456138"
#   description = "id of default vpc"
# }



# variable "project_name" {
#   type        = string
#   default     = "react-jenkins-project"
#   description = "description"
# }



# variable "my_hosted_zone" {
#   type    = string
#   default = "533267232470.realhandsonlabs.net"
# }

# resource "aws_security_group" "alb_sg" {
#   provider    = aws.region1
#   name        = "alb-security-group"
#   description = "Security group for ALB"
#   vpc_id      = aws_vpc.vpc_region1.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name    = "alb-security-group"
#     region  = var.region1
#     project = var.project_name
#   }
# }

# resource "aws_lb" "alb_region1" {
#   provider           = aws.region1
#   name               = "alb-region1"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [aws_subnet.public_subnet_region1.id, aws_subnet.public_subnet_region1_az2.id]

#   tags = {
#     project = var.project_name
#     env     = "prod"
#     region  = var.region1
#   }
# }

# # ALB Target Group
# resource "aws_lb_target_group" "tg_region1" {
#   provider = aws.region1
#   name     = "tg-region1"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc_region1.id

#   health_check {
#     enabled             = true
#     healthy_threshold   = 2
#     interval            = 30
#     timeout             = 5
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     matcher             = "200"
#     unhealthy_threshold = 2
#   }

#   tags = {
#     project = var.project_name
#     env     = "prod"
#     region  = var.region1
#   }
# }

# data "aws_route53_zone" "main" {
#   name = "${var.my_hosted_zone}." # Note the trailing dot
# }

# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "www.${var.my_hosted_zone}" # Subdomain you want to route
#   type    = "A"

#   alias {
#     name                   = aws_lb.alb_region1.dns_name
#     zone_id                = aws_lb.alb_region1.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "apex" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = var.my_hosted_zone
#   type    = "A"

#   alias {
#     name                   = aws_lb.example.dns_name
#     zone_id                = aws_lb.example.zone_id
#     evaluate_target_health = true
#   }
# }

# # 1. Request an ACM Certificate
# resource "aws_acm_certificate" "cert" {
#   domain_name               = var.my_hosted_zone
#   subject_alternative_names = ["*.${var.my_hosted_zone}"] # Covers all subdomains
#   validation_method         = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     env     = "prod"
#     project = var.project_name
#   }
# }

# # 2. Create DNS records for ACM validation
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.main.zone_id
# }

# # 3. Certificate Validation
# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }

# # 4. Create HTTPS Listener for ALB
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.alb_region1.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg_region1.arn
#   }
# }

# # 5. Optional: HTTP to HTTPS Redirect
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.alb_region1.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
