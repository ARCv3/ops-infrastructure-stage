resource "aws_ecs_cluster" "ecs" {
  name = "arc-api-cluster"
}

resource "aws_ecs_service" "service" {
  name = "arc-api-service"

  cluster = aws_ecs_cluster.ecs.arn
  launch_type = "FARGATE"
  enable_execute_command = true

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  desired_count = 1
  task_definition = aws_ecs_task_definition.td.arn

  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.sg.id]
    subnets = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.albtg.arn
    container_port = 443
    container_name = "arc-api"
  }

}

resource "aws_cloudwatch_log_group" "logGroup" {
    name = "arc-log-group"
    retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "logStream" {
    name = "arc-api-logs"
    log_group_name = aws_cloudwatch_log_group.logGroup.name
}

resource "aws_ecs_task_definition" "td" {

    container_definitions = jsonencode([
        {
            name = "arc-api"
            image = "140023379914.dkr.ecr.us-east-2.amazonaws.com/arc-api-repo"
            cpu = 256
            memory = 512
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort = 80
                    protocol = "tcp"
                },
                {
                    containerPort = 443
                    hostPort = 443
                    protocol = "tcp"
                }
            ]
            logConfiguration = {

                logDriver = "awslogs"
                options = {
                    awslogs-region = "us-east-2"
                    awslogs-group="arc-log-group"
                    awslogs-stream-prefix="arc-api-logs"
                }

            }
            tags = {}
            systemControls = []
            volumesFrom = []
            mountPoints = []
        }
    ])

    family = "arc-api"
    requires_compatibilities = ["FARGATE"]
    cpu = "256"
    memory = "512"
    network_mode = "awsvpc"
    task_role_arn = "arn:aws:iam::140023379914:role/ecsTaskExecutionRole"
    execution_role_arn = "arn:aws:iam::140023379914:role/ecsTaskExecutionRole"
}
