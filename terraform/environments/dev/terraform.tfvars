region         = "us-east-1"
prefix         = "open-webui"
vpc_cidr       = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# RDS設定
postgres_version     = "14.6"
db_instance_class    = "db.t3.micro"
allocated_storage    = 20
max_allocated_storage = 100
db_name              = "openwebuidb"
db_username          = "openwebui"
db_password          = "" # 環境変数 TF_VAR_db_password から取得します。例: export TF_VAR_db_password="your-secure-password"

# EKS設定
kubernetes_version   = "1.27"
node_instance_types  = ["t3.medium"]
node_disk_size       = 20
node_desired_size    = 2
node_min_size        = 1
node_max_size        = 3

# タグ設定
default_tags = {
  Environment = "dev"
  Project     = "open-webui"
  ManagedBy   = "terraform"
}
