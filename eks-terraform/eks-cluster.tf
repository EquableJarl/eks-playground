#EKS setting up the IAM roles and policies 
resource "aws_iam_role" "role-eks-cluster" {
  name = "terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.role-eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.role-eks-cluster.name}"
}

#Setting up the EKS SG

resource "aws_security_group" "sg-public-cluster" {
  name        = "sgPub"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks-playground-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-public-eks"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["86.30.132.35/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg-public-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg-public-cluster.id}"
  source_security_group_id = "${aws_security_group.public-sg-worker-node.id}"
  to_port                  = 443
  type                     = "ingress"
}




resource "aws_eks_cluster" "demo" {
  name            = var.cluster-name
  role_arn        = "${aws_iam_role.role-eks-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.sg-public-cluster.id}"]
    subnet_ids         = values(aws_subnet.subnet-eks-playground-public)[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
  ]
}