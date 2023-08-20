provider "aws" {
  version = "5.7"
}

data "terraform_remote_state" "baseinfra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate" 
  }
}

resource "aws_vpc_endpoint" "ecrapi" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress ]
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  tags = {
    Name = "minkian-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecrdkr" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress ]
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  tags = {
    Name = "minkian-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name      = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [ data.terraform_remote_state.baseinfra.outputs.minkianRouteApp ]
  tags = {
    Name = "minkian-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress]
  tags = {
    Name = "minkian-vpce-logs"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress ]
  tags = {
    Name = "minkian-vpce-secrets"
  }
}


resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress ]
  tags = {
    Name = "minkian-vpce-ssm-messages"
  }
}


resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = data.terraform_remote_state.baseinfra.outputs.minkianVpc
  service_name = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [ data.terraform_remote_state.baseinfra.outputs.PrivateEgress1A, data.terraform_remote_state.baseinfra.outputs.PrivateEgress1C ]
  security_group_ids = [ data.terraform_remote_state.baseinfra.outputs.minkiansgEgress ]
  tags = {
    Name = "minkian-vpce-ssm"
  }
}