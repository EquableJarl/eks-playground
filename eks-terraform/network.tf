resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.eks-playground-vpc.id
    
    tags = {
      "Name" = "prod-igw"
    }
  
}

resource "aws_eip" "nat" {
    vpc = true
  
}

resource "aws_nat_gateway" "prod-nat-gw" {
    allocation_id = aws_eip.nat.id
    subnet_id = values(aws_subnet.subnet-eks-playground-public)[0].id
    
    tags = {
      "Name" = "prod-nat-gw"
    }
}

resource "aws_route_table" "pub-crta" {
    vpc_id = aws_vpc.eks-playground-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-igw.id
    }

    tags = {
        Name = "public crta to the igw"
    }

  

}
resource "aws_route_table" "private-crta"{
    vpc_id = aws_vpc.eks-playground-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.prod-nat-gw.id
    } 
    
    tags = {
        Name = "nated crta to the ngw"
    }
}



# resource "aws_route_table_association" "crta-public-subnet" {
#     count = length(values(aws_subnet.subnet-eks-playground-public)[*].id)
#     subnet_id = values(aws_subnet.subnet-eks-playground-public)[count.index].id
#     route_table_id = aws_route_table.pub-crta.id
# }

resource "aws_route_table_association" "crta-public-subnet" {
    for_each = aws_subnet.subnet-eks-playground-public 
    subnet_id = each.value.id
    route_table_id = aws_route_table.pub-crta.id
}

resource "aws_route_table_association" "crta-private-subnet" {
    for_each = aws_subnet.subnet-eks-playground-private
    subnet_id = each.value.id
    route_table_id = aws_route_table.private-crta.id
}

# resource "aws_route_table_association" "crta-private-subnet" {
#     count = length(values(aws_subnet.subnet-eks-playground-private)[*].id)
#     subnet_id = values(aws_subnet.subnet-eks-playground-private)[count.index].id
#     route_table_id = aws_route_table.pub-crta.id
# }




# resource "aws_route_table_association" "crta-public-subnet" {
#     count = length(aws_subnet.subnet-eks-playground-public)
#     subnet_id = aws_subnet.subnet-eks-playground-public[count.index].id
#     route_table_id = aws_route_table.pub-crta.id
# }

# resource "aws_route_table_association" "crta-private-subnet" {
#     count = length(aws_subnet.subnet-eks-playground-private)
#     subnet_id = aws_subnet.subnet-eks-playground-private[count.index].id
#     route_table_id = aws_route_table.private-crta.id
# }



