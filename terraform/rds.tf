### RDS subnet group 생성
resource "aws_db_subnet_group" "rds-subnet-group" {
  name = "rds-subnet-group"
  subnet_ids = [
    module.global-shop-project-vpc.private_subnets[4],
    module.global-shop-project-vpc.private_subnets[5]
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

### Database Instance 생성
resource "aws_db_instance" "global-shop-project-db" {
  identifier             = "global-shop-project-db"
  allocated_storage      = 20                             # allocated storage 설정 (20)
  engine                 = "mysql"                        # engine 설정 (mysql)
  engine_version         = "8.0.28"                       # engine version 설정 (8.0.28)
  instance_class         = "db.t2.micro"                  # instance class 설정 (db.t2.micro), 이전 클래스 사용 시 db.t2.micro 사용 가능
  username               = "admin"                        # username 설정
  password               = "dkagh1.dkagh1."               # password 설정 (파일 처리 후 파일변수로 수정할 계획)
  storage_type           = "gp2"                          # storage_type (gp2)
  db_subnet_group_name   = "rds-subnet-group"             # RDS subnet group 지정
  skip_final_snapshot    = true                           # 종료 시 snapshot 생성 하지 않음 설정 (false -> RDS 종료 시 snapshot 생성)
  parameter_group_name   = "default.mysql8.0"             # parameter group name 설정 (default.mysql8.0)
  name                   = "BBS"                          # database name
  vpc_security_group_ids = [aws_security_group.all-sg.id] # security group 설정 (변경 예정)
  port                   = "3306"                         # port 설정 (3306)
  multi_az               = true                           # 다중 AZ 활성화

  backup_retention_period = 7             # 자동 백업 보관 주기
  backup_window           = "09:00-09:30" # 자동 백업 활동 시간

  depends_on = [
    aws_db_subnet_group.rds-subnet-group
  ]
}

