### bastion host autoscaling, image_id= install mysql on bastion host

resource "aws_launch_template" "bastion-launch-template" {
  depends_on = [
    module.global-shop-project-vpc.public_subnets # 명시적 의존성 부여, public subnet 생성 후 생성
  ]

  name                                 = "bastion-launch-template"
  description                          = "bastion for Auto Scaling"
  instance_type                        = "t2.micro"                                    # instance type 설정 (t2.micro)
  image_id                             = var.ami_id_ubuntu                             # image_id 설정
  instance_initiated_shutdown_behavior = "terminate"                                   # image shutdown 시 terminate 활성화
  key_name                             = aws_key_pair.global-shop-project-key.key_name # key pair 설정

  network_interfaces {
    associate_public_ip_address = true                           # autoscaling network interfaces 설정
    security_groups             = [aws_security_group.all-sg.id] # security group 설정 (변경 예정)
  }

  monitoring {
    enabled = true # monitoring 활성화
  }

  placement {
    availability_zone = "ap-northeast-2" # availability zone 설정 (ap-northeast-2)
  }

  tags = {
    Name = "bastion-launch-template"
  }

  tag_specifications {
    resource_type = "instance" # autoscaling으로 생성된 instance의 이름 설정
    tags = {
      Name = "bastion_host_autoscaling"
    }
  }

  user_data = "IyEgL2Jpbi9iYXNoDQplY2hvICJTdHJpY3RIb3N0S2V5Q2hlY2tpbmcgbm8iID4+IC9ldGMvc3NoL3NzaF9jb25maWc="  # SSH접속 known_host 무시
}


### bastion autoscaling group 생성
resource "aws_autoscaling_group" "bastion-asg" {
  launch_template {
    id      = aws_launch_template.bastion-launch-template.id             # 시작 템플릿 연결
    version = aws_launch_template.bastion-launch-template.latest_version # 시작 템플릿 버전 지정
  }

  name             = "bastion-asg"
  desired_capacity = 2 # 원하는 용량 (2)
  min_size         = 2 # 최소 용량 (2)
  max_size         = 4 # 최대 용량 (4)

  health_check_type         = "ELB"                                                                                                # health check type (ELB)
  health_check_grace_period = 300                                                                                                  # health check grace period (300)
  force_delete              = true                                                                                                 # 삭제 활성화
  vpc_zone_identifier       = [module.global-shop-project-vpc.public_subnets[0], module.global-shop-project-vpc.public_subnets[1]] # public subnet 설정(192.168.56.0/27, 192.168.56.32/27)


}

### autoscaling policy 생성
resource "aws_autoscaling_policy" "bastion-target-tracking-configuration" {
  name                   = "bastion-target-tracking-configuration"
  autoscaling_group_name = aws_autoscaling_group.bastion-asg.name # autoscaling group 연결
  policy_type            = "TargetTrackingScaling"                # policy type 대상추적크기조정 설정
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # predefined metric type 설정 (CPU 사용률)
    }

    target_value = 50.0 # target value (50)
  }
}

### worker node web autoscaling

resource "aws_launch_template" "workernode-web-launch-template" {
  depends_on = [
    module.global-shop-project-vpc.private_subnets
  ]

  name                                 = "workernode-web-launch-template"
  description                          = "worker node for Auto Scaling"
  instance_type                        = "t2.medium"                                   # instance type 설정 (t2.medium)
  image_id                             = var.ami_id_workernode                         # image_id 설정 (k8s cluster 설치 전 image 사용)
  instance_initiated_shutdown_behavior = "terminate"                                   # image shutdown 시 terminate 활성화
  key_name                             = aws_key_pair.global-shop-project-key.key_name # key pair 설정

  network_interfaces {
    associate_public_ip_address = false                          # autoscaling network interfaces 설정
    security_groups             = [aws_security_group.all-sg.id] # security group 설정 (변경 예정)
  }

  monitoring {
    enabled = true # monitoring 활성화
  }

  placement {
    availability_zone = "ap-northeast-2" # availability zone 설정 (ap-northeast-2)
  }

  tags = {
    Name = "workernode-web-launch-template"
  }

  tag_specifications {
    resource_type = "instance" # autoscaling으로 생성된 instance의 이름 설정
    tags = {
      Name = "workernode_web"
    }
  }

}


### workernode autoscaling group 생성
resource "aws_autoscaling_group" "workernode-web-asg" {
  launch_template {
    id      = aws_launch_template.workernode-web-launch-template.id             # 시작 템플릿 연결
    version = aws_launch_template.workernode-web-launch-template.latest_version # 시작 템플릿 버전 지정
  }

  name             = "workernode-web-asg"
  desired_capacity = 4 # 원하는 용량 (4)
  min_size         = 4 # 최소 용량 (4)
  max_size         = 8 # 최대 용량 (8)

  health_check_type         = "ELB"                                                                                                  # health check type (ELB)
  health_check_grace_period = 300                                                                                                    # health check grace period (300)
  force_delete              = true                                                                                                   # 삭제 활성화
  vpc_zone_identifier       = [module.global-shop-project-vpc.private_subnets[0], module.global-shop-project-vpc.private_subnets[1]] # private subnet설정 (192.168.56.128/28, 192.168.56.144/28)

}

### workernode autoscaling policy 생성
resource "aws_autoscaling_policy" "workernode-web-target-tracking-configuration" {
  name                   = "workernode-web-target-tracking-configuration"
  autoscaling_group_name = aws_autoscaling_group.workernode-web-asg.name # autoscaling group 연결
  policy_type            = "TargetTrackingScaling"                   # policy type 대상추적크기조정 설정
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # predefined metric type 설정 (CPU 사용률)
    }

    target_value = 50.0 # target value (50)
  }
}

### worker node was autoscaling

resource "aws_launch_template" "workernode-was-launch-template" {
  depends_on = [
    module.global-shop-project-vpc.private_subnets
  ]

  name                                 = "workernode-was-launch-template"
  description                          = "worker node for Auto Scaling"
  instance_type                        = "t2.medium"                                   # instance type 설정 (t2.medium)
  image_id                             = var.ami_id_workernode                       # image_id 설정 (k8s cluster 설치 전 image 사용)
  instance_initiated_shutdown_behavior = "terminate"                                   # image shutdown 시 terminate 활성화
  key_name                             = aws_key_pair.global-shop-project-key.key_name # key pair 설정

  network_interfaces {
    associate_public_ip_address = false                          # autoscaling network interfaces 설정
    security_groups             = [aws_security_group.all-sg.id] # security group 설정 (변경 예정)
  }

  monitoring {
    enabled = true # monitoring 활성화
  }

  placement {
    availability_zone = "ap-northeast-2" # availability zone 설정 (ap-northeast-2)
  }

  tags = {
    Name = "workernode-was-launch-template"
  }

  tag_specifications {
    resource_type = "instance" # autoscaling으로 생성된 instance의 이름 설정
    tags = {
      Name = "workernode_was"
    }
  }

}


### workernode autoscaling group 생성
resource "aws_autoscaling_group" "workernode-was-asg" {
  launch_template {
    id      = aws_launch_template.workernode-was-launch-template.id             # 시작 템플릿 연결
    version = aws_launch_template.workernode-was-launch-template.latest_version # 시작 템플릿 버전 지정
  }

  name             = "workernode-was-asg"
  desired_capacity = 4 # 원하는 용량 (4)
  min_size         = 4 # 최소 용량 (4)
  max_size         = 8 # 최대 용량 (8)

  health_check_type         = "ELB"                                                                                                  # health check type (ELB)
  health_check_grace_period = 300                                                                                                    # health check grace period (300)
  force_delete              = true                                                                                                   # 삭제 활성화
  vpc_zone_identifier       = [module.global-shop-project-vpc.private_subnets[2], module.global-shop-project-vpc.private_subnets[3]] # private subnet설정 (192.168.56.160/28, 192.168.56.176/28)

}

### workernode autoscaling policy 생성
resource "aws_autoscaling_policy" "workernode-was-target-tracking-configuration" {
  name                   = "workernode-was-target-tracking-configuration"
  autoscaling_group_name = aws_autoscaling_group.workernode-was-asg.name # autoscaling group 연결
  policy_type            = "TargetTrackingScaling"                   # policy type 대상추적크기조정 설정
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # predefined metric type 설정 (CPU 사용률)
    }

    target_value = 50.0 # target value (50)
  }
}
