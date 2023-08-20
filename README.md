# Terraform_ECS

ECS를 통한 도커 기반 컨테이너 서비스 인프라 구축 및 CodePipeline 으로 ECS 배포 자동화

리소스를 생성하는데 필요한 iam 권한 및 정책은 콘솔로 생성했습니다. 

배포순서 
1. 루트모듈
2. VPCE
3. Database
4. Backend
5. Frontend
6. WAF
7. Bastion

Backend는 ECS 서비스로 구성되어있고, 로그정보를 Firelens를 통해 수집하게 설정했습니다. Fluentbit 컨테이너를 포함하고 있습니다.

Frontend는 ECS Task로 구성되어 있습니다. 

컨테이너 환경을 관리하기위한 Bastion 인스턴스를 ECS로 구성하였습니다. Systems Manager를 통해 접속 가능합니다. 그렇기 때문에 해당 iam 역할을 task에 부착해주었습니다. 

