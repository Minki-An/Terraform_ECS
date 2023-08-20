# ecsTaskExecutionRole 생성되어 있어야함 

provider "aws" {
  version = "5.7"
}

data "terraform_remote_state" "baseinfra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate" 
  }
}

resource "aws_cloudwatch_log_group" "minkian_CloudWatchLogsFrontend" {
  name = "/ecs/minkian-frontend-def"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "Frontend_cluster" {
  name = "minkian-frontend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "Frontend_Task" {
  family = "minkian-frontedn-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = 512
  memory = 1024
  execution_role_arn = "arn:aws:iam::<AccountId>:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "front-app"
      image     = "<AccountId>.dkr.ecr.ap-northeast-2.amazonaws.com/minkian-frontend:v1"
      cpu       = 256
      memory_reservation   = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name = "SESSION_SECRET_KEY"
          value = "41b678c65b37bf99c37bcab522802760"
        },
        {
          name = "APP_SERVICE_HOST"
          value = "http://${var.BackendHost}"
        },
        {
          name = "NOTIF_SERVICE_HOST"
          value = "http://${var.BackendHost}"
        }
      ]
      secrets = [
        {
          name = "DB_HOST"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-2:<AccountId>:secret:minkian/mysql-72nOQQ:host::"
        },
        {
          name = "DB_NAME"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-2:<AccountId>:secret:minkian/mysql-72nOQQ:dbname::"
        },
        {
          name = "DB_USERNAME"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-2:<AccountId>:secret:minkian/mysql-72nOQQ:username::"
        },
        {
          name = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-2:<AccountId>:secret:minkian/mysql-72nOQQ:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/minkian-frontend-def"
          awslogs-region = "ap-northeast-2"
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])
}

data "aws_ecs_task_execution" "Frontend_Task" {
  count           = 1
  cluster         = aws_ecs_cluster.Frontend_cluster.id
  task_definition = aws_ecs_task_definition.Frontend_Task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "1.4.0"


  network_configuration {
    subnets          = [ data.terraform_remote_state.baseinfra.outputs.PrivateContainer1A, data.terraform_remote_state.baseinfra.outputs.PrivateContainer1C ]
    security_groups  = [ data.terraform_remote_state.baseinfra.outputs.minkiansgFrontContainer ]
    assign_public_ip = false
  }
}

