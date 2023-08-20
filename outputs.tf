## VPC
output "minkianVpc" {
  value       = aws_vpc.minkianVpc.id
  description = "vpc id of minkian"
}

## Subnet
output "PrivateDb1A" {
  value       = aws_subnet.PrivateDb1A.id
  description = "RDS subnet of minkianVpc"
}

output "PrivateDb1C" {
  value       = aws_subnet.PrivateDb1C.id
  description = "RDS subnet of minkianVpc"
}

output "PrivateEgress1A" {
  value       = aws_subnet.PrivateEgress1A.id
  description = "VPCE subnet of minkianVpc"
}

output "PrivateEgress1C" {
  value       = aws_subnet.PrivateEgress1C.id
  description = "VPCE subnet of minkianVpc"
}

output "PrivateContainer1A" {
  value       = aws_subnet.PrivateContainer1A.id
  description = "backend subnet of minkianVpc"
}

output "PrivateContainer1C" {
  value       = aws_subnet.PrivateContainer1C.id
  description = "backend subnet of minkianVpc"
}




## Routetable
output "minkianRouteApp" {
  value       = aws_route_table.minkianRouteApp.id
  description = "Routetable of App"
}


## Security Group
output "minkiansgIngress" {
  value       = aws_security_group.minkiansgIngress.id
  description = "Security for Ingress"
}

output "minkiansgManagement" {
  value       = aws_security_group.minkiansgManagement.id
  description = "Security for Management"
}

output "minkiansgContainer" {
  value       = aws_security_group.minkiansgContainer.id
  description = "Security for Backend Container"
}

output "minkiansgFrontContainer" {
  value       = aws_security_group.minkiansgFrontContainer.id
  description = "Security for Frontend Container"
}

output "minkiansgInternal" {
  value       = aws_security_group.minkiansgInternal.id
  description = "Security for Internal LB"
}

output "minkiansgDb" {
  value       = aws_security_group.minkiansgDb.id
  description = "Security for Database"
}

output "minkiansgEgress" {
  value       = aws_security_group.minkiansEgress.id
  description = "Security for VPCE"
}

## ALB
output "BackendHost" {
  value       = aws_lb.albinternal.dns_name
  description = "backend dns"
}

output "BackendTargetGroup_Blue" {
  value       = aws_lb_target_group.bluetagregroup.arn
  description = "backend blue targetgroup"
}

output "BackendTargetGroup_Bluename" {
  value       = aws_lb_target_group.bluetagregroup.name
  description = "backend blue targetgroup name"
}

output "BackendTargetGroup_Green" {
  value       = aws_lb_target_group.greentagregroup.arn
  description = "backend green targetgroup"
}

output "BackendTargetGroup_Greenname" {
  value       = aws_lb_target_group.greentagregroup.name
  description = "backend green targetgroup name"
}

output "Blue_Listener" {
  value       = aws_lb_listener.backend_blue.arn
  description = "backend blue listener"
}

output "Green_Listener" {
  value       = aws_lb_listener.backend_green.arn
  description = "backend green listener"
}



