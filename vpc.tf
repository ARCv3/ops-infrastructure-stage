resource "aws_vpc" "vpc" {

    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true

}

resource "aws_subnet" "sn1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn2" {
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.vpc.id
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sn3" {
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.vpc.id
    availability_zone = "us-east-2c"
    map_public_ip_on_launch = true
}


resource "aws_security_group" "sg" {
    name = "sg"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "https"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {

        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gateway.id
  }
  route {
      ipv6_cidr_block =  "::/0"
      gateway_id = aws_internet_gateway.gateway.id
  }
}


resource "aws_route_table_association" "route1" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sn1.id
}

resource "aws_route_table_association" "route2" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.sn2.id
  }

resource "aws_route_table_association" "route3" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.sn3.id
}

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
