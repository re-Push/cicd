### keypair 생성
resource "aws_key_pair" "global-shop-project-key" {
  key_name   = "global-shop-project-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}


### jenkins 가상머신 생성, (Install jenkins,docker,k8s on jenkins)
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id-jenkins 	                             # jenkins ami id
  availability_zone      = module.global-shop-project-vpc.azs[1]             # availability zone 설정 (ap-northeast-2c)      
  instance_type          = "t2.medium"                                       # instance type 설정 (t2.medium)
  vpc_security_group_ids = [aws_security_group.all-sg.id]                    # security group 설정 (변경 예정)
  subnet_id              = module.global-shop-project-vpc.private_subnets[3] # private subnet 설정 (192.168.56.176/28)       
  key_name               = aws_key_pair.global-shop-project-key.key_name     # keypair 설정

  tags = {
    Name = "jenkins"
  }
}


### k8scluster1 가상머신 생성, control plane
resource "aws_instance" "k8s-control-plane1" {
  ami                    = var.ami_id_workernode                             # workernode ami id
  availability_zone      = module.global-shop-project-vpc.azs[0]             # availability zone 설정 (ap-northeast-2a)
  instance_type          = "t2.large"                                        # instance type 설정 (t2.large)
  vpc_security_group_ids = [aws_security_group.all-sg.id]                    # security group 설정 (변경 예정)
  subnet_id              = module.global-shop-project-vpc.private_subnets[2] # private subnet 설정 (192.168.56.160/28)
  key_name               = aws_key_pair.global-shop-project-key.key_name     # keypair 설정

root_block_device {
    volume_size          = 20
}

  tags = {
    Name = "k8s-control-plane1"
  }
}
    
### k8scluster2 가상머신 생성, control plane
resource "aws_instance" "k8s-control-plane2" {
  ami                    = var.ami_id_workernode                             # workernode ami id
  availability_zone      = module.global-shop-project-vpc.azs[1]             # availability zone 설정 (ap-northeast-2c)
  instance_type          = "t2.medium"                                       # instance type 설정 (t2.medium)
  vpc_security_group_ids = [aws_security_group.all-sg.id]                    # security group 설정 (변경 예정)
  subnet_id              = module.global-shop-project-vpc.private_subnets[3] # private subnet 설정 (192.168.56.176/28)
  key_name               = aws_key_pair.global-shop-project-key.key_name     # keypair 설정

  root_block_device {
    volume_size          = 10
}

  tags = {
    Name = "k8s-control-plane2"
  }
}
