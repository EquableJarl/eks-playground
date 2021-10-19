resource "aws_vpc" "eks-playground-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true #gives you an internal domain name
    enable_dns_hostnames = true #gives you an internal host name
    enable_classiclink = false
    instance_tenancy = "default"    
    
   tags = {
      Name = "eks-playground-vpc"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
  
}

#TODO some kinda count creating the public, then the private subnets, using the availability zones as well. 
#I will use a default /24 for the subnets to make life easy. so need number of subbnets and something to handle az's

resource "aws_subnet" "subnet-eks-playground-public" {
    count = length(var.public_subnets)
    vpc_id = aws_vpc.eks-playground-vpc.id
    cidr_block = var.public_subnets[count.index]
    map_public_ip_on_launch = true
    availability_zone = var.azs[count.index]
    
    tags = {
        Name = "public-subnet ${count.index}"
        "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
}

resource "aws_subnet" "subnet-eks-playground-private" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.eks-playground-vpc.id
    cidr_block = var.private_subnets[count.index]
    map_public_ip_on_launch = false
    availability_zone = var.azs[count.index]
    
    tags = {
        Name = "private-subnet ${count.index}"
        "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
}
