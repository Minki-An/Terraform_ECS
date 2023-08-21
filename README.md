# Terraform_ECS

ECS를 통한 도커 기반 컨테이너 서비스 인프라 구축 및 CodePipeline 으로 ECS 배포 자동화

![image](https://github.com/Minki-An/Terraform_ECS/assets/127027898/1898bc04-f3ac-4b3e-bb5c-6a4a1d4a3d0d)

리소스를 생성하는데 필요한 iam 권한 및 정책은 콘솔로 생성했습니다. 

Backend는 ECS 서비스로 구성되어있고, 로그정보를 Firelens를 통해 수집하게 설정했습니다. Fluentbit 컨테이너를 포함하고 있습니다.Frontend는 ECS Task로 구성되어 있습니다. 

컨테이너 환경을 관리하기위한 Bastion 인스턴스를 ECS로 구성하였습니다. Systems Manager를 통해 접속 가능합니다. 해당 iam 역할을 task에 부착해주었습니다. 


