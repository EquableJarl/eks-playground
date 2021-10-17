#!/bin/bash

terraform output -raw config_map_aws_auth > config_map_aws_auth.yaml

aws eks update-kubeconfig --name eks-cluster --region eu-west-2   

kubectl apply -f config_map_aws_auth.yaml

kubectl get nodes --watch