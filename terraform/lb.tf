### network load balancer (bastion host용)

resource "aws_lb" "bastionhost-network-loadbalancer" {
  name                             = "bastionhost-network-loadbalancer"
  internal                         = false                                                                                                # internet-facing 설정
  load_balancer_type               = "network"                                                                                            # load_balancer type 설정 (network)
  subnets                          = [module.global-shop-project-vpc.public_subnets[0], module.global-shop-project-vpc.public_subnets[1]] # public subnet 설정 (192.168.56.0/27, 192.168.56.32/27)
  enable_cross_zone_load_balancing = true                                                                                                 # 영역 간 로드밸런싱 활성화
}

### network load balancer target group 생성 (bastion host용)
resource "aws_lb_target_group" "bastionhost-network-targetgroup" {
  name     = "bastionhost-network-targetgroup"
  port     = 22    # port 설정 (22)
  protocol = "TCP" # protocol 설정 (TCP)
  vpc_id   = module.global-shop-project-vpc.vpc_id
}

### network load balancer listener 설정
resource "aws_lb_listener" "bastionhost-nlb-listener" {
  load_balancer_arn = aws_lb.bastionhost-network-loadbalancer.arn # network load_balancer 연결
  port              = 22                                          # port 설정 (22)
  protocol          = "TCP"                                       # protocol 설정 (TCP)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastionhost-network-targetgroup.arn # network load_balancer target group 연결
  }
}


### web application load balancer

resource "aws_lb" "application-web-loadbalancer" {
  name                             = "application-web-loadbalancer"
  internal                         = false                                                                                                # internet-facing 설정
  load_balancer_type               = "application"                                                                                        # load_balancer type 설정 (application)
  security_groups                  = [aws_security_group.all-sg.id]                                                                       # security group  설정 (nlb는 설정하지 않음)
  subnets                          = [module.global-shop-project-vpc.public_subnets[0], module.global-shop-project-vpc.public_subnets[1]] # public subnet 설정 (192.168.56.0/27, 192.168.56.32/27)
  enable_cross_zone_load_balancing = true                                                                                                 # 영역 간 로드밸런싱 활성화
}

### web application load balancer target group 생성 (workernode 용)
resource "aws_lb_target_group" "application-web-targetgroup" {
  name     = "application-web-targetgroup"
  port     = 32123     # port 설정 (80)
  protocol = "HTTP" # protocol 설정 (HTTP)
  vpc_id   = module.global-shop-project-vpc.vpc_id

}

### web application load balancer listener 설정
resource "aws_lb_listener" "application-web-listener" {
  load_balancer_arn = aws_lb.application-web-loadbalancer.arn # application load_balancer 연결
  port              = 80                                  # port 설정 (80)
  protocol          = "HTTP"                              # protocol 설정 (HTTP)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application-web-targetgroup.arn # application load_balancer target group 연결
  }
}


### was application load balancer

resource "aws_lb" "application-was-loadbalancer" {
  name                             = "application-was-loadbalancer"
  internal                         = true                                                                                                 # internet-facing 설정
  load_balancer_type               = "application"                                                                                        # load_balancer type 설정 (application)
  security_groups                  = [aws_security_group.all-sg.id]                                                                       # security group  설정 (nlb는 설정하지 않음)
  subnets                          = [module.global-shop-project-vpc.public_subnets[0], module.global-shop-project-vpc.public_subnets[1]] # public subnet 설정 (192.168.56.0/27, 192.168.56.32/27)
  enable_cross_zone_load_balancing = true                                                                                                 # 영역 간 로드밸런싱 활성화
}

### was application load balancer target group 생성 (workernode 용)
resource "aws_lb_target_group" "application-was-targetgroup" {
  name     = "application-was-targetgroup"
  port     = 31313     # port 설정 (31313)
  protocol = "HTTP" # protocol 설정 (HTTP)
  vpc_id   = module.global-shop-project-vpc.vpc_id

  stickiness {
    type            = "app_cookie" # sticky session 설정 -> load_balancer type (application 자체 쿠키를 가지고 있지 않은 경우)
    cookie_name     = "JSESSIONID"
    enabled         = true        # stickiness 활성화 (default 값 = true, 비활성 시 =  stickiness)
    cookie_duration = 3600       # lb_cookie type 에서만 설정가능 (1 day = 86400 seconds , 1 week = 604800 seconds)
  }
}

### was application load balancer listener 설정
resource "aws_lb_listener" "application-was-listener" {
  load_balancer_arn = aws_lb.application-was-loadbalancer.arn # application load_balancer 연결
  port              = 8080                                # port 설정 (80)
  protocol          = "HTTP"                              # protocol 설정 (HTTP)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application-was-targetgroup.arn # application load_balancer target group 연결
  }
}


### was auto scaling attachment  bastion + workernode

resource "aws_autoscaling_attachment" "bastion-autoscaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.bastion-asg.id # autoscaling group & network load_balancer target group attachment
  alb_target_group_arn   = aws_lb_target_group.bastionhost-network-targetgroup.arn
}

resource "aws_autoscaling_attachment" "workernode-web-autoscaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.workernode-web-asg.id # autoscaling group & application load_balancer target group attachment
  alb_target_group_arn   = aws_lb_target_group.application-web-targetgroup.arn
}
resource "aws_autoscaling_attachment" "workernode-was-autoscaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.workernode-was-asg.id # autoscaling group & application load_balancer target group attachment
  alb_target_group_arn   = aws_lb_target_group.application-was-targetgroup.arn
}
