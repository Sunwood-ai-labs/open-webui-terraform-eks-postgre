#!/bin/bash
# Open WebUI with PostgreSQL on EKS 環境構築スクリプト
# このスクリプトはTerraformを使用してAWS上にOpen WebUI環境を構築します

set -e

# スクリプトが存在するディレクトリのパスを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 色の設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 使用方法の表示
function show_usage {
  echo "使用方法: $0 [options]"
  echo "オプション:"
  echo "  -h, --help     ヘルプを表示"
  echo "  -i, --init     Terraformの初期化のみ実行"
  echo "  -p, --plan     Terraformのプランのみ実行"
  echo "  -a, --apply    Terraformのapplyを実行"
  echo "  -d, --destroy  環境を破棄"
  exit 1
}

# 前提条件のチェック
function check_prerequisites {
  echo -e "${YELLOW}前提条件をチェックしています...${NC}"
  
  # AWS CLIのチェック
  if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLIがインストールされていません。${NC}"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
  fi
  
  # Terraformのチェック
  if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraformがインストールされていません。${NC}"
    echo "https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
    exit 1
  fi
  
  # kubectlのチェック
  if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectlがインストールされていません。${NC}"
    echo "https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
  fi
  
  # helmのチェック
  if ! command -v helm &> /dev/null; then
    echo -e "${RED}Helmがインストールされていません。${NC}"
    echo "https://helm.sh/docs/intro/install/"
    exit 1
  fi
  
  echo -e "${GREEN}すべての前提条件が満たされています。${NC}"
}

# Terraformの初期化
function terraform_init {
  echo -e "${YELLOW}Terraformを初期化しています...${NC}"
  cd "${SCRIPT_DIR}/../terraform"
  terraform init
  cd - > /dev/null
  echo -e "${GREEN}Terraformの初期化が完了しました。${NC}"
}

# Terraformのプラン
function terraform_plan {
  echo -e "${YELLOW}Terraformプランを実行しています...${NC}"
  cd "${SCRIPT_DIR}/../terraform"
  terraform plan -var-file=environments/dev/terraform.tfvars
  cd - > /dev/null
  echo -e "${GREEN}Terraformプランが完了しました。${NC}"
}

# Terraformのapply
function terraform_apply {
  echo -e "${YELLOW}Terraformを適用しています...${NC}"
  cd "${SCRIPT_DIR}/../terraform"
  terraform apply -var-file=environments/dev/terraform.tfvars -auto-approve
  cd - > /dev/null
  echo -e "${GREEN}Terraformの適用が完了しました。${NC}"
}

# Terraformの破棄
function terraform_destroy {
  echo -e "${YELLOW}環境を破棄しています...${NC}"
  cd "${SCRIPT_DIR}/../terraform"
  terraform destroy -var-file=environments/dev/terraform.tfvars -auto-approve
  cd - > /dev/null
  echo -e "${GREEN}環境の破棄が完了しました。${NC}"
}

# EKSクラスターの設定
function configure_eks {
  echo -e "${YELLOW}EKSクラスターを設定しています...${NC}"
  
  # kubeconfigの更新
  CLUSTER_NAME=$(cd terraform && terraform output -raw eks_cluster_name)
  aws eks update-kubeconfig --name $CLUSTER_NAME --region $(cd terraform && terraform output -raw region)
  
  echo -e "${GREEN}EKSクラスターの設定が完了しました。${NC}"
}

# PostgreSQLの初期化
function init_postgres {
  echo -e "${YELLOW}PostgreSQLを初期化しています...${NC}"
  
  # RDSエンドポイントの取得
  DB_ENDPOINT=$(cd terraform && terraform output -raw db_instance_endpoint)
  DB_NAME=$(cd terraform && terraform output -raw db_instance_name)
  
  # パスワードをterraform.tfvarsから取得
  DB_PASSWORD=$(grep -E "^db_password.*=.*\".*\"" ${SCRIPT_DIR}/../terraform/environments/dev/terraform.tfvars | sed -E 's/^db_password.*=.*"(.*)".*/\1/')
  
  # 初期化スクリプトの実行
  ./scripts/init_postgres.sh ${DB_ENDPOINT%:*} 5432 $DB_NAME openwebui "$DB_PASSWORD"
  
  echo -e "${GREEN}PostgreSQLの初期化が完了しました。${NC}"
}

# Kubernetesリソースのデプロイ
function deploy_kubernetes_resources {
  echo -e "${YELLOW}Kubernetesリソースをデプロイしています...${NC}"
  
  # RDSエンドポイントの取得
  DB_ENDPOINT=$(cd terraform && terraform output -raw db_instance_endpoint)
  
  # シークレットの更新
  sed -i "s/\${DB_HOST}/${DB_ENDPOINT%:*}/g" kubernetes/manifests/postgres-secret.yaml
  
  # マニフェストの適用
  kubectl apply -f kubernetes/manifests/postgres-secret.yaml
  kubectl apply -f kubernetes/manifests/open-webui-config.yaml
  
  # Helmリポジトリの追加
  helm repo add open-webui https://helm.openwebui.com/
  helm repo update
  
  # Open WebUIのデプロイ
  helm install open-webui open-webui/open-webui -f kubernetes/helm/open-webui-values.yaml
  
  # Ingressの適用
  kubectl apply -f kubernetes/manifests/open-webui-ingress.yaml
  
  echo -e "${GREEN}Kubernetesリソースのデプロイが完了しました。${NC}"
}

# メイン処理
if [ $# -eq 0 ]; then
  show_usage
fi

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_usage
      ;;
    -i|--init)
      check_prerequisites
      terraform_init
      exit 0
      ;;
    -p|--plan)
      check_prerequisites
      terraform_init
      terraform_plan
      exit 0
      ;;
    -a|--apply)
      check_prerequisites
      terraform_init
      terraform_apply
      configure_eks
      init_postgres
      deploy_kubernetes_resources
      exit 0
      ;;
    -d|--destroy)
      check_prerequisites
      terraform_destroy
      exit 0
      ;;
    *)
      echo -e "${RED}不明なオプション: $1${NC}"
      show_usage
      ;;
  esac
  shift
done
