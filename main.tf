provider "aws" {
  version = "5.7"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "minkianVpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true
  instance_tenancy   = "default"
  
  tags = {
    Name = "minkianVpc"
  }
}

resource "aws_internet_gateway" "minkianigw" {
  vpc_id = aws_vpc.minkianVpc.id

  tags = {
    Name = "minkianigw"
  }
}


## 컨테이너 애플리케이션용 프라이빗 서브넷 
resource "aws_subnet" "PrivateContainer1A" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.8.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-container-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "PrivateContainer1C" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.9.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-container-1c"
    Type = "Isolated"
  }
}

## 컨테이너 애플리케이션용 라우팅 테이블
resource "aws_route_table" "minkianRouteApp" {
  
  vpc_id = aws_vpc.minkianVpc.id

  tags = {
    Name = "minkian-route-app"
  }
}

resource "aws_route_table_association" "minkianRouteAppAssociationA" {
  subnet_id      = aws_subnet.PrivateContainer1A.id
  route_table_id = aws_route_table.minkianRouteApp.id
}

resource "aws_route_table_association" "minkianRouteAppAssociationC" {
  subnet_id      = aws_subnet.PrivateContainer1C.id
  route_table_id = aws_route_table.minkianRouteApp.id
}

# DB 관련
## DB용 프라이빗 서브넷

resource "aws_subnet" "PrivateDb1A" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.16.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-db-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "PrivateDb1C" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.17.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-db-1c"
    Type = "Isolated"
  }
}

resource "aws_route_table" "minkianRouteDb" {
  
  vpc_id = aws_vpc.minkianVpc.id

  tags = {
    Name = "minkian-route-db"
  }
}

resource "aws_route_table_association" "minkianRouteDbAssociationA" {
  subnet_id      = aws_subnet.PrivateDb1A.id
  route_table_id = aws_route_table.minkianRouteDb.id
}

resource "aws_route_table_association" "minkianRouteDbAssociationC" {
  subnet_id      = aws_subnet.PrivateDb1C.id
  route_table_id = aws_route_table.minkianRouteDb.id
}

# Ingress 관련 설정
## Ingress용 퍼블릭 서브넷 

resource "aws_subnet" "PublickIngress1A" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-ingress-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "PublickIngress1C" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-ingress-1c"
    Type = "Public"
  }
}

## Ingress용 라우팅 테이블
resource "aws_route_table" "minkianRouteIngress" {
  
  vpc_id = aws_vpc.minkianVpc.id
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.minkianigw.id
}

  tags = {
    Name = "minkian-route-ingress"
  }
}

resource "aws_route_table_association" "minkianRouteIngressAssociationA" {
  subnet_id      = aws_subnet.PublickIngress1A.id
  route_table_id = aws_route_table.minkianRouteIngress.id
}

resource "aws_route_table_association" "minkianRouteIngressAssociationC" {
  subnet_id      = aws_subnet.PublickIngress1C.id
  route_table_id = aws_route_table.minkianRouteIngress.id
}

# 관리 서버 관련 설정 
## 관리용 퍼블릭 서브넷 

resource "aws_subnet" "PublickManagement1A" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.240.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-management-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "PublickManagement1C" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.241.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-management-1c"
    Type = "Public"
  }
}

## 관리용 라우팅 테이블은 인그레스용과 동일한 것 사용


resource "aws_route_table_association" "minkianRouteManagementAssociationA" {
  subnet_id      = aws_subnet.PublickManagement1A.id
  route_table_id = aws_route_table.minkianRouteIngress.id
}

resource "aws_route_table_association" "minkianRouteManagementAssociationC" {
  subnet_id      = aws_subnet.PublickManagement1C.id
  route_table_id = aws_route_table.minkianRouteIngress.id
}

# VPC 엔드포인트 관련 설정
## VPC 엔드포인트(Egress 통신)용 프라이빗 서브넷

resource "aws_subnet" "PrivateEgress1A" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.248.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-egress-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "PrivateEgress1C" {
  vpc_id     = aws_vpc.minkianVpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.249.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-egress-1c"
    Type = "Isolated"
  }
}

# Security Groups
# 보안 그룹 생성
## 인터넷 공개용 보안그룹 생성 

resource "aws_security_group" "minkiansgIngress" {
  name_prefix = "ingress-"
  description = "Security group for ingress"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "from 0.0.0.0/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    ipv6_cidr_blocks = ["::/0"]
    description     = "from ::/0:80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }
    tags = {
    Name = "minkian-sg-ingress"
  }
}

# 관리 서버용 보안그룹 생성 

resource "aws_security_group" "minkiansgManagement" {
  name_prefix = "management-"
  description = "Security group for management"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-management"
  }
}

# 백엔드 컨테이너 애플리케이션용 보안 그룹 생성 
resource "aws_security_group" "minkiansgContainer" {
  name_prefix = "container-"
  description = "Security group for backend app"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-container"
  }
}

# 프론트엔드 컨테이너 애플리케이션용 보안 그룹 생성
resource "aws_security_group" "minkiansgFrontContainer" {
  name_prefix = "front-container-"
  description = "Security group for front container app"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-container"
  }
}

# 내부용 로드밸런서의 보안그룹 생성 
resource "aws_security_group" "minkiansgInternal" {
  name_prefix = "internal-"
  description = "Security group for internal loadbalancer"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-internal"
  }
}

# DB용 보안 그룹 생성 

resource "aws_security_group" "minkiansgDb" {
  name_prefix = "database-"
  description = "Security group for database"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-db"
  }
}

# VPC 엔드포인트용 보안 그룹 생성 

resource "aws_security_group" "minkiansEgress" {
  name_prefix = "egress"
  description = "Security group for VPC Endpoint"
  vpc_id = aws_vpc.minkianVpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
    tags = {
    Name = "minkian-sg-vpce"
  }
}

# 역할 연결 
## Internal LB -> Front Container
resource "aws_vpc_security_group_ingress_rule" "minkianSgFrontContainerFromSgIngress" {
  security_group_id = aws_security_group.minkiansgFrontContainer.id

  referenced_security_group_id   = aws_security_group.minkiansgIngress.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

## Front Container -> Internal LB
resource "aws_vpc_security_group_ingress_rule" "minkianSgInternalFromSgFrontContainer" {
  security_group_id = aws_security_group.minkiansgInternal.id

  referenced_security_group_id   = aws_security_group.minkiansgFrontContainer.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

## Internal LB -> Back Container
resource "aws_vpc_security_group_ingress_rule" "minkianSgContainerFromSgInternal" {
  security_group_id = aws_security_group.minkiansgContainer.id

  referenced_security_group_id   = aws_security_group.minkiansgInternal.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

## Back container -> DB
resource "aws_vpc_security_group_ingress_rule" "minkianSgDbFromSgContainerTCP" {
  security_group_id = aws_security_group.minkiansgDb.id

  referenced_security_group_id   = aws_security_group.minkiansgContainer.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

## Front container -> DB
resource "aws_vpc_security_group_ingress_rule" "minkianSgDbFromSgFrontContainerTCP" {
  security_group_id = aws_security_group.minkiansgDb.id

  referenced_security_group_id   = aws_security_group.minkiansgFrontContainer.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

## Management server -> DB
resource "aws_vpc_security_group_ingress_rule" "minkianSgDbFromSgManagementTCP" {
  security_group_id = aws_security_group.minkiansgDb.id

  referenced_security_group_id   = aws_security_group.minkiansgManagement.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

## Management server -> Internal LB
resource "aws_vpc_security_group_ingress_rule" "minkianSgInternalFromSgManagementTCP" {
  security_group_id = aws_security_group.minkiansgInternal.id

  referenced_security_group_id   = aws_security_group.minkiansgManagement.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "minkianSgInternalFromSgManagementTCP2" {
  security_group_id = aws_security_group.minkiansgInternal.id

  referenced_security_group_id   = aws_security_group.minkiansgManagement.id
  from_port   = 10080
  ip_protocol = "tcp"
  to_port     = 10080
}

### Back container -> VPC endpoint
resource "aws_vpc_security_group_ingress_rule" "minkianSgVpceFromSgContainerTCP" {
  security_group_id = aws_security_group.minkiansEgress.id

  referenced_security_group_id   = aws_security_group.minkiansgContainer.id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

### Front container -> VPC endpoint
resource "aws_vpc_security_group_ingress_rule" "minkianSgVpceFromSgFrontContainerTCP" {
  security_group_id = aws_security_group.minkiansEgress.id

  referenced_security_group_id   = aws_security_group.minkiansgFrontContainer.id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

### Management server -> VPC endpoint
resource "aws_vpc_security_group_ingress_rule" "minkianSgVpceFromSgManagementTCP" {
  security_group_id = aws_security_group.minkiansEgress.id

  referenced_security_group_id   = aws_security_group.minkiansgManagement.id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

# LaodBalancer 관련 생성 
## Internal LB 타겟 그룹 생성 
resource "aws_lb_target_group" "bluetagregroup" {
  name        = "minkian-tf-demo-blue"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.minkianVpc.id
  health_check {
    enabled             = true
    interval            = 15
    path                = "/healthcheck" 
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200" 
  }
}

resource "aws_lb_target_group" "greentagregroup" {
  name        = "minkian-tf-demo-green"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.minkianVpc.id
  health_check {
    enabled             = true
    interval            = 15
    path                = "/healthcheck" 
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200" 
  }
}

## Bacend ALB 생성
resource "aws_lb" "albinternal" {
  name               = "minkian-alb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.minkiansgInternal.id ]
  subnets            = [ aws_subnet.PrivateContainer1A.id, aws_subnet.PrivateContainer1C.id ]
  tags = {
    Environment = "backend container"
  }
}

## Backend Listener 생성
resource "aws_lb_listener" "backend_blue" {
  load_balancer_arn = aws_lb.albinternal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bluetagregroup.arn
  }
}

resource "aws_lb_listener" "backend_green" {
  load_balancer_arn = aws_lb.albinternal.arn
  port              = "10080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.greentagregroup.arn
  }
}

# Frontend ALB 생성 

resource "aws_lb_target_group" "frontendtagregroup" {
  name        = "minkian-tg-front"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.minkianVpc.id
  health_check {
    enabled             = true
    interval            = 15
    path                = "/healthcheck" 
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200" 
  }
}

resource "aws_lb" "frontalb" {
  name               = "minkian-alb-internetfacing"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.minkiansgIngress.id ]
  subnets            = [ aws_subnet.PublickIngress1A.id, aws_subnet.PublickIngress1C.id ]
  tags = {
    Environment = "frontend container"
  }
}

resource "aws_lb_listener" "Frontend_listener" {
  load_balancer_arn = aws_lb.frontalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontendtagregroup.arn
  }
}
