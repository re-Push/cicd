### k8scluster1 private IP 값 출력
output "k8scluster1_Private_IP" {
  value = aws_instance.k8s-control-plane1.private_ip
  depends_on = [
    aws_instance.k8s-control-plane1
  ]
}

### k8scluster2 private IP 값 출력
output "k8scluster2_private_IP" {
  value = aws_instance.k8s-control-plane2.private_ip
  depends_on = [
    aws_instance.k8s-control-plane2
  ]
}


### Network Load Balancer Domain Name 값 출력
output "Network_LoadBancer_Domain_Name" {
  value = aws_lb.bastionhost-network-loadbalancer.dns_name
  depends_on = [
    aws_lb.bastionhost-network-loadbalancer
  ]
}

### Web Application Load Balancer Domain Name 값 출력
output "Web_Application_LoadBancer_Domain_Name" {
  value = aws_lb.application-web-loadbalancer.dns_name
  depends_on = [
    aws_lb.application-web-loadbalancer
  ]
}

### WAS Application Load Balancer Domain Name 값 출력
output "WAS_Application_LoadBancer_Domain_Name" {
  value = aws_lb.application-was-loadbalancer.dns_name
  depends_on = [
    aws_lb.application-was-loadbalancer
  ]
}

### Database Endpoint 값 출력
output "Database_Endpoint" {
  value = aws_db_instance.global-shop-project-db.endpoint
  depends_on = [
    aws_db_instance.global-shop-project-db
  ]
}
