# Open WebUI with PostgreSQL on EKS

このリポジトリは、AWSのEKS（Elastic Kubernetes Service）上でPostgreSQLをバックエンドとして使用するOpen WebUI環境を構築するためのコードとスクリプトを提供します。TerraformとKubernetesマニフェストを使用して、インフラストラクチャからアプリケーションデプロイまでを自動化します。

## アーキテクチャ概要

このプロジェクトは以下のコンポーネントで構成されています：

1. **AWS VPC** - セキュアなネットワーク環境
2. **Amazon RDS for PostgreSQL** - Open WebUIのデータベースバックエンド
3. **Amazon EKS** - Kubernetesクラスター
4. **AWS Load Balancer Controller** - インターネットからのトラフィックルーティング
5. **Open WebUI** - Helmチャートを使用したデプロイ

## 前提条件

以下のツールがローカル環境にインストールされている必要があります：

- AWS CLI (認証済み)
- Terraform (v1.0.0以上)
- kubectl
- Helm

## ディレクトリ構造

```
open-webui-terraform-eks/
├── terraform/                  # Terraformコード
│   ├── modules/                # 再利用可能なモジュール
│   │   ├── vpc/                # VPCモジュール
│   │   ├── rds/                # RDSモジュール
│   │   └── eks/                # EKSモジュール
│   ├── environments/           # 環境固有の設定
│   │   └── dev/                # 開発環境設定
│   ├── main.tf                 # メインTerraformファイル
│   ├── variables.tf            # 変数定義
│   └── outputs.tf              # 出力定義
├── kubernetes/                 # Kubernetesマニフェスト
│   ├── manifests/              # 基本マニフェスト
│   └── helm/                   # Helmチャート設定
├── scripts/                    # ユーティリティスクリプト
└── docs/                       # ドキュメント
```

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/open-webui-terraform-eks.git
cd open-webui-terraform-eks
```

### 2. 環境変数の設定

```bash
# AWS認証情報の設定（既に設定済みの場合は不要）
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. デプロイスクリプトの実行

```bash
# 初期化のみ
./scripts/deploy.sh --init

# プランの確認
./scripts/deploy.sh --plan

# 環境の構築
./scripts/deploy.sh --apply

# 環境の破棄
./scripts/deploy.sh --destroy
```

## 手動デプロイ手順

自動スクリプトを使用せずに手動でデプロイする場合は、以下の手順に従ってください。

### 1. Terraformの初期化と適用

```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### 2. kubeconfigの設定

```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region $(terraform output -raw region)
```

### 3. PostgreSQLの初期化

```bash
../scripts/init_postgres.sh $(terraform output -raw db_instance_endpoint | cut -d: -f1) 5432 $(terraform output -raw db_instance_name) openwebui YourPassword
```

### 4. Kubernetesリソースのデプロイ

```bash
# シークレットの更新
DB_ENDPOINT=$(terraform output -raw db_instance_endpoint | cut -d: -f1)
sed -i "s/\${DB_HOST}/$DB_ENDPOINT/g" ../kubernetes/manifests/postgres-secret.yaml

# マニフェストの適用
kubectl apply -f ../kubernetes/manifests/postgres-secret.yaml
kubectl apply -f ../kubernetes/manifests/open-webui-config.yaml

# Helmリポジトリの追加
helm repo add open-webui https://helm.openwebui.com/
helm repo update

# Open WebUIのデプロイ
helm install open-webui open-webui/open-webui -f ../kubernetes/helm/open-webui-values.yaml

# Ingressの適用
kubectl apply -f ../kubernetes/manifests/open-webui-ingress.yaml
```

## アクセス方法

デプロイが完了すると、AWS Load Balancerが作成されます。以下のコマンドでURLを取得できます：

```bash
kubectl get ingress open-webui-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

このURLにブラウザからアクセスすると、Open WebUIのインターフェースが表示されます。

## カスタマイズ

### 環境設定の変更

`terraform/environments/dev/terraform.tfvars` ファイルを編集して、以下の設定をカスタマイズできます：

- リージョン
- インスタンスタイプ
- ノード数
- データベース設定
- その他のパラメータ

### Open WebUI設定の変更

`kubernetes/helm/open-webui-values.yaml` ファイルを編集して、Open WebUIの設定をカスタマイズできます。

## トラブルシューティング

### EKSクラスターに接続できない

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

### PostgreSQL接続エラー

RDSセキュリティグループがEKSノードからの接続を許可していることを確認してください。

### Open WebUIがデプロイされない

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

## メンテナンス

### バックアップ

RDSは自動的にバックアップを作成します。追加のバックアップが必要な場合は、以下のコマンドを使用します：

```bash
aws rds create-db-snapshot --db-instance-identifier <db-instance-id> --db-snapshot-identifier <snapshot-name>
```

### アップグレード

Open WebUIをアップグレードするには：

```bash
helm upgrade open-webui open-webui/open-webui -f kubernetes/helm/open-webui-values.yaml
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細はLICENSEファイルを参照してください。

## 貢献

バグ報告や機能リクエストは、GitHubのIssueを通じてお願いします。プルリクエストも歓迎します。
