provider "aws" {
  version = "5.7"
}

data "terraform_remote_state" "baseinfra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate" 
  }
}

## cloudwatch loggroup
resource "aws_cloudwatch_log_group" "firelens_log_group" {
  name = "/aws/ecs/minkian-firelens"
  tags = {
    Name = "firelens"
  }
}
## Backend cluster
resource "aws_ecs_cluster" "Backend_cluster" {
  name = "minkian-backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## Backend Task Definition
resource "aws_ecs_task_definition" "Backend_Task" {
  family = "minkian-backend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = 512
  memory = 1024
  task_role_arn = "arn:aws:iam::<AccountId>:role/minkian-ecsTaskRole"
  execution_role_arn = "arn:aws:iam::<AccountId>:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "backend-app"
      image     = "<AccountId>.dkr.ecr.ap-northeast-2.amazonaws.com/minkian-backend:v1"
      cpu       = 256
      memory_reservation    = 512
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
        logDriver = "awsfirelens"
      }

    },
    {
      name      = "log_router"
      image     = "<AccountId>.dkr.ecr.ap-northeast-2.amazonaws.com/minkian-firelens:v1"
      cpu       = 64
      memory_reservation    = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name = "APP_ID"
          value = "backend-def"
        },
        {
          name = "AWS_ACCOUNT_ID"
          value = "<AccountId>"
        },
        {
          name = "AWS_REGION"
          value = "ap-northeast-2"
        },
        {
          name = "LOG_BUCKET_NAME"
          value = "minkian-ecs-logs"
        },
        {
          name = "LOG_GROUP_NAME"
          value = "/aws/ecs/minkian-backend-def"
        }
      ]

      firelensConfiguration = {
        type = "fluentbit"
        options = {
          config-file-type = "file"
          config-file-value = "/fluent-bit/configs/custom.conf"
        }
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/aws/ecs/minkian-firelens"
          awslogs-region = "ap-northeast-2"
          awslogs-stream-prefix = "firelens"
        }
      }
    }
  ])
}

## Backend Service
resource "aws_ecs_service" "minkian_backend_service" {
  name            = "minkian-backend-service"
  cluster         = aws_ecs_cluster.Backend_cluster.id
  task_definition = aws_ecs_task_definition.Backend_Task.arn
  desired_count   = 2
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  scheduling_strategy  = "REPLICA"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = [data.terraform_remote_state.baseinfra.outputs.PrivateContainer1A, data.terraform_remote_state.baseinfra.outputs.PrivateContainer1C]
    security_groups = [data.terraform_remote_state.baseinfra.outputs.minkiansgContainer]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.baseinfra.outputs.BackendTargetGroup_Blue
    container_name   = "backend-app"
    container_port   = 80
  }

}

## Codedeploy app

resource "aws_codedeploy_app" "backendapp" {
  compute_platform = "ECS"
  name             = "backenddeployapp"
}

## Codedeploy Group
resource "aws_codedeploy_deployment_group" "backendappgroup" {
  app_name               = aws_codedeploy_app.backendapp.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "deployment-group-backend"
  service_role_arn       = "arn:aws:iam::<AccountId>:role/ecsCodeDeployRole"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.Backend_cluster.name
    service_name = aws_ecs_service.minkian_backend_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [data.terraform_remote_state.baseinfra.outputs.Blue_Listener]
      }

      test_traffic_route {
        listener_arns = [data.terraform_remote_state.baseinfra.outputs.Green_Listener]
      }

      target_group {
        name = data.terraform_remote_state.baseinfra.outputs.BackendTargetGroup_Bluename
      }

      target_group {
        name = data.terraform_remote_state.baseinfra.outputs.BackendTargetGroup_Greenname
      }
    }
  }
}

## Autoscaling

resource "aws_appautoscaling_target" "backend_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/minkian-backend-cluster/minkian-backend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_ecs_policy" {
  name               = "minkian-ecs-scalingPolicy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.backend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }

  depends_on = [aws_appautoscaling_target.backend_target]
}
