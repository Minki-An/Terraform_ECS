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

resource "aws_cloudwatch_log_group" "CloudWatchLogsBastion" {
  name = "/ecs/minkian-bastion-def"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "Bastion_cluster" {
  name = "minkian-bastion-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "Bastion_Task" {
  family = "minkian-bastion-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = 256
  memory = 512
  task_role_arn = "arn:aws:iam::<AccountId>:role/minkian-ecsTaskRole"
  execution_role_arn = "arn:aws:iam::<AccountId>:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "bastion"
      image     = "<AccountId>.dkr.ecr.ap-northeast-2.amazonaws.com/minkian-bastion:v1"
      cpu       = 256
      memory_reservation   = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/minkian-bastion-def"
          awslogs-region = "ap-northeast-2"
          awslogs-stream-prefix = "bastion"
        }
      }
    }
  ])
}

data "aws_ecs_task_execution" "Bastion" {
  count           = 1
  cluster         = aws_ecs_cluster.Bastion_cluster.id
  task_definition = aws_ecs_task_definition.Bastion_Task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "1.4.0"


  network_configuration {
    subnets          = [ data.terraform_remote_state.baseinfra.outputs.PrivateContainer1A, data.terraform_remote_state.baseinfra.outputs.PrivateContainer1C ]
    security_groups  = [ data.terraform_remote_state.baseinfra.outputs.minkiansgFrontContainer ]
    assign_public_ip = false
  }
}
