data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_ecs_service" "service" {
  name = var.name

  cluster = data.aws_ecs_cluster.this.id
  network_configuration {
    subnets         = var.ecs_vpc_subnets_private_ids
    security_groups = [aws_security_group.sg.id]
  }

  desired_count         = 1
  launch_type           = "FARGATE"
  task_definition       = aws_ecs_task_definition.task_definition.arn
  wait_for_steady_state = true
  tags                  = var.tags
  propagate_tags        = "SERVICE"

  lifecycle {
    ignore_changes = [desired_count]
  }
}


resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution.arn
  # ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume
  task_role_arn = local.ecs_task_role_arn
  # ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services.
  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  container_definitions = jsonencode([
    {
      environment = local.task_env_vars
      name        = "CloudConnector"
      image       = var.image
      essential   = true
      secrets = [
        {
          name      = "SECURE_API_TOKEN"
          valueFrom = var.secure_api_token_secret_name
        }
      ]
      portMappings = [
        {
          containerPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.id
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  tags = var.tags
}


locals {
  suffix_org = var.is_organizational ? "org" : "single"
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(local.verify_ssl)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "terraform_aws_ecs_${local.suffix_org}"
    },
    {
      name  = "CONFIG"
      value = base64encode(local.default_config)
    },
    {
      name  = "SECURE_URL",
      value = data.sysdig_secure_connection.current.secure_url
    }
    ], flatten([
      for env_key, env_value in var.extra_env_vars : [
        {
          name  = env_key,
          value = env_value
        }
      ]
    ])
  )
}
