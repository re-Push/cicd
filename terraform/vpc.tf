### vpc 설정

module "global-shop-project-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "global-shop-project-vpc" # vpc name 설정

  cidr = "192.168.56.0/24" # vpc cidr 설정

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]                                               # availability zone 설정
  public_subnets  = ["192.168.56.0/27", "192.168.56.32/27"]  					         # public subnet 설정
  private_subnets = ["192.168.56.128/28", "192.168.56.144/28", "192.168.56.160/28", "192.168.56.176/28", "192.168.56.192/28", "192.168.56.208/28"] # private subnet 설정

  create_database_subnet_group = true # db subnet group 활성화

  create_igw = true # Internet gateway 활성화

  enable_nat_gateway = true # Nat gateway 활성화
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}
