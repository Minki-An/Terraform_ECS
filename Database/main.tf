provider "aws" {
  region = "ap-northeast-2"

  # 2.x 버전의 AWS 공급자 허용
  version = "~> 5.7"
}


#인프라 배포 state 파일 불러오기
data "terraform_remote_state" "baseinfra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate" 
  }
}


#iam_role for RDS_Proxy: rds proxy 생성할 iam 역할 데이터 소스로 불러오기
data "aws_iam_role" "RDS_Proxy_iam" {
  name = "rds-proxy-role-1689432998923" # 본인 rds proxy iam 으로 교체
}

data "aws_secretsmanager_secret_version" "rds_secret" { 
  secret_id = "arn:aws:secretsmanager:ap-northeast-2:<AccountId>:secret:Terraform/RDS/-k1aMxW"
}

# Seoul Region Aurora Cluster Subnet group: 오로라 클러스터 서브넷 그룹 생성
resource "aws_db_subnet_group" "aws_aurora_subnet_group" {
  name       = "rds_cluster_group"
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateDb1A, data.terraform_remote_state.baseinfra.outputs.PrivateDb1C ]
  tags = {
    Name = "minkian Aurora subnet group"
  }
}

resource "aws_rds_cluster_parameter_group" "rds_cluster_minkian" {
  name        = "rds-cluster-seoul"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

}

resource "aws_rds_cluster" "minkian_aurora_cluster" {
  apply_immediately       = true
  cluster_identifier      = "aurora-cluster-minkian"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.3"
  db_subnet_group_name    = aws_db_subnet_group.aws_aurora_subnet_group.name
  vpc_security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgDb ]
  database_name           = "minkian_db"
  master_username         = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)["username"] #마스터 사용자 이름
  master_password         = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)["password"] #마스터 사용자 암호
  backup_retention_period = 5
  skip_final_snapshot = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_cluster_minkian.name
}

# Aurora Cluster Instance 
resource "aws_rds_cluster_instance" "primary" {
  cluster_identifier    = aws_rds_cluster.minkian_aurora_cluster.id
  identifier            = "minkian-database-1"
  engine                = "aurora-mysql"
  instance_class        = "db.t3.small"  
  publicly_accessible   = false
}

resource "aws_rds_cluster_instance" "secondary" {
  cluster_identifier    = aws_rds_cluster.minkian_aurora_cluster.id
  identifier            = "minkian-database-2"
  engine                = "aurora-mysql"
  instance_class        = "db.t3.small"  
  publicly_accessible   = false
}

