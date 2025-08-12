# deepseek-architecture
Terraform project that create an AWS Architecture by prompt Engineering

# To test the RDS postgres
- Create an EC2 instances
- Add this code to the User Data:
    #!/bin/bash
cd /tmp
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo dnf install -y postgresql15
    
- Add an Inbound rule in the SG of DB to enable conecctions from SG wheres EC2 resides
-  Command to coonet from shell:
psql -h <db-end-point> -U <user> -d <admin>


# Para poder desplegar ECR, se necesita una policy que permita crear repositorios etc y luego se debe atachar al usuario utilizado para desplegar la infraestructura.

<!-- {
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "ECRPermissions",
			"Effect": "Allow",
			"Action": [
				"ecr:CreateRepository",
				"ecr:GetAuthorizationToken",
				"ecr:DescribeRepositories",
				"ecr:PutImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:ListTagsForResource"
			],
			"Resource": "*"
		},
		{
			"Sid": "IAMPermissionsForPolicies",
			"Effect": "Allow",
			"Action": [
				"iam:GetPolicy",
				"iam:GetPolicyVersion",
				"iam:ListPolicyVersions",
				"iam:DeletePolicy",
				"iam:DetachUserPolicy",
				"iam:ListAttachedUserPolicies",
				"iam:AttachUserPolicy",
				"iam:ListEntitiesForPolicy"
			],
			"Resource": "*"
		}
	]
} -->


# Acceso al cluster con KUBECTL
1- Instalación
brew install kubectl     # Mac

# Paso 2: Actualiza tu kubeconfig para conectarte al cluster
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster --profile jsvegam.aws.data

# Paso 3: Verifica la conexión con kubectl
kubectl get nodes

# Paso 4: Instala herramientas de monitoreo

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl top nodes
kubectl top pods --all-namespaces

# login:

ACCOUNT_ID=368707729092
REGION=us-east-1
REGISTRY=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
REPO=deepseek-app

aws ecr get-login-password --region us-east-1 --profile jsvegam.aws.data \
  | docker login --username AWS --password-stdin 368707729092.dkr.ecr.us-east-1.amazonaws.com









