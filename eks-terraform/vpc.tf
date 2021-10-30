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

locals {
    pub_index = range(var.num_public_clusters)
    pri_index = range(var.num_private_clusters)

    pub_subs = flatten([
    for z in var.azs : [
      for i in local.pub_index : {
        zone  = z
        index = i
            }
        ]
    ])

    pri_subs = flatten([
    for z in var.azs : [
      for i in local.pub_index : {
        zone  = z
        index = i
            }
        ]
    ])



}

resource "aws_subnet" "subnet-eks-playground-public" {
    for_each = { for sub in local.pub_subs : "${sub.zone}_${sub.index}" => sub }
    vpc_id = aws_vpc.eks-playground-vpc.id
    cidr_block = "10.0.${index(local.pub_subs, each.value) + 1}.0/24"
    map_public_ip_on_launch = true
    availability_zone = each.value.zone
    
    tags = {
        Name = "public-subnet ${each.value.index + 1}-${each.value.zone}"
        "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
}

resource "aws_subnet" "subnet-eks-playground-private" {
    for_each = { for sub in local.pri_subs :"${sub.zone}_${sub.index}" => sub }
    vpc_id = aws_vpc.eks-playground-vpc.id
    cidr_block = "10.0.${index(local.pri_subs, each.value) + 100}.0/24"
    map_public_ip_on_launch = true
    availability_zone = each.value.zone
    
    tags = {
        Name = "private-subnet ${each.value.index + 1}-${each.value.zone}"
        "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
}

# resource "make_pri_subnets" "pri_subnet_translation" {
#     for_each = aws_subnet.subnet-eks-playground-private
#     add = "${concat(var.pri_sub_list, [each.key])}"
  
# }

output subnet_id {
  value = values(aws_subnet.subnet-eks-playground-public)[*].id
}

# resource "aws_subnet" "subnet-eks-playground-public" {
#     count = length(var.public_subnets)
#     vpc_id = aws_vpc.eks-playground-vpc.id
#     cidr_block = var.public_subnets[count.index]
#     map_public_ip_on_launch = true
#     availability_zone = var.azs[count.index]
    
#     tags = {
#         Name = "public-subnet ${count.index}"
#         "kubernetes.io/cluster/${var.cluster-name}" = "shared"
#     }
# }

# resource "aws_subnet" "subnet-eks-playground-private" {
#     count = length(var.private_subnets)
#     vpc_id = aws_vpc.eks-playground-vpc.id
#     cidr_block = var.private_subnets[count.index]
#     map_public_ip_on_launch = false
#     availability_zone = var.azs[count.index]
    
#     tags = {
#         Name = "private-subnet ${count.index}"
#         "kubernetes.io/cluster/${var.cluster-name}" = "shared"
#     }
# }
