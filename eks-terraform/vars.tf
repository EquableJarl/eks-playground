variable "region" {
    type = string
    default = "eu-west-2"
}

variable "cluster-name" {
   type = string
   default = "eks-cluster"  
  
}

# variable "public_subnets" {
#   type    = list(string)
#   default = ["10.0.1.0/24", "10.0.11.0/24"]
# }

# variable "private_subnets" {
#   type = list(string)
#   default = ["10.0.2.0/24", "10.0.22.0/24"]
# }

variable "azs" {
    type = list(string)
    default = [ "eu-west-2a", "eu-west-2b", "eu-west-2c"]
  
}

variable "num_public_clusters" {
  type = number
  default = 2
  
}

variable "num_private_clusters" {
  type = number
  default = 2
  
}

