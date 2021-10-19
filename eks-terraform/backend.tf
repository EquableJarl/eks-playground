terraform {
  backend "s3" {
    bucket = "equablejarl2"
    key    = "equablejarl2/tfstateFiles/eks-playground.tfstate"
    region = "eu-west-2"
  }
}