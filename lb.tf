resource "aws_alb_target_group" "albtg" {
    name = "arc-api-stg"
    target_type = "ip"
    vpc_id = aws_vpc.vpc.id

    health_check {
      protocol = "HTTPS"
      path = "/v2/api/health"
    }

    protocol = "HTTPS"
    port = 443
}

resource "aws_alb" "alb" {
    name = "arc-api-stg"
    internal = false
    security_groups = [aws_security_group.sg.id]
    subnets = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
}

resource "aws_alb_listener" "alb_rule" {
    protocol = "HTTPS"
    port = 443
    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.albtg.arn
    }
    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn = "arn:aws:acm:us-east-2:140023379914:certificate/1cccefae-9e78-475c-9b38-70bc82df0c6f"
    load_balancer_arn = aws_alb.alb.arn
}

resource "aws_alb_target_group" "albtg2" {
    name = "unity-stg"
    target_type = "ip"
    vpc_id = aws_vpc.vpc.id

    health_check {
      protocol = "HTTP"
      path = "/"
    }

    protocol = "HTTP"
    port = 80
}

resource "aws_alb" "alb2" {
    name = "unity-stg"
    internal = false
    security_groups = [aws_security_group.sg.id]
    subnets = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
}

resource "aws_alb_listener" "alb_rule2" {
    protocol = "HTTPS"
    port = 443
    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.albtg2.arn
    }
    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn = "arn:aws:acm:us-east-2:140023379914:certificate/1cccefae-9e78-475c-9b38-70bc82df0c6f"
    load_balancer_arn = aws_alb.alb2.arn
}





