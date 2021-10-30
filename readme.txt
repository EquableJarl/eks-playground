EKS-Playground

What am I trying to do here?

Deploy a website, using my own domain as the public dns.  I want to deploy the website onto an AWS hosted EKS 
Cluster and balance the traffic using kong so I can switch traffic between the pods by modifying the configmap. 



- how do I set up the DNS? 

- Buy a domain

- try and create some modules to make this kinda thing easier in the future...
    - VPC 
    
###############

NOTES

Run the terraform, will build al the terraform infa and output the manual step for the Kubernetes workernode deployment
run the script to configure the workernodes

Command to build docker
docker run -it --rm -d -p 8080:80 --name web equablejarl/eks-nginx

command to deploy to eks
kubectl apply -f eks-nginx-deployment.yaml


*******

Whats to do on the terraform? 

Fix the naming convention for the subnets.. 
Why do we only get 2 worker nodes? 



