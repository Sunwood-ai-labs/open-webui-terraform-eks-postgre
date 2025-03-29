# Open WebUI with PostgreSQL on EKS - 使用方法ガイド

このドキュメントでは、Open WebUIをPostgreSQLバックエンドとEKS上で実行するための詳細な手順を説明します。

## 目次

1. [環境構築](#環境構築)
2. [アクセスと初期設定](#アクセスと初期設定)
3. [運用管理](#運用管理)
4. [トラブルシューティング](#トラブルシューティング)
5. [アンインストール](#アンインストール)

## 環境構築

### 前提条件の確認

以下のツールがインストールされていることを確認してください：

- AWS CLI v2以上
- Terraform v1.0.0以上
- kubectl v1.21以上
- Helm v3.5.0以上

AWS認証情報が適切に設定されていることも確認してください：

```bash
aws configure
# または環境変数を設定
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### デプロイ手順

#### 自動デプロイ（推奨）

提供されているデプロイスクリプトを使用すると、ワンコマンドで環境を構築できます：

```bash
# 初期化のみを実行
./scripts/deploy.sh --init

# プランを確認（変更内容の確認）
./scripts/deploy.sh --plan

# 環境を構築
./scripts/deploy.sh --apply
```

デプロイには約20〜30分かかります。主な手順は以下の通りです：

1. VPC、サブネット、セキュリティグループなどのネットワークリソースの作成
2. PostgreSQL RDSインスタンスの作成
3. EKSクラスターとノードグループの作成
4. AWS Load Balancer Controllerのインストール
5. PostgreSQLデータベースの初期化（pgvector拡張機能の有効化）
6. Open WebUIのデプロイ

#### 手動デプロイ

手動でデプロイする場合は、以下の手順に従ってください：

1. Terraformの実行：

```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

2. kubeconfigの設定：

```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region $(terraform output -raw region)
```

3. PostgreSQLの初期化：

```bash
cd ..
./scripts/init_postgres.sh $(terraform output -raw db_instance_endpoint | cut -d: -f1) 5432 $(terraform output -raw db_instance_name) openwebui YourPassword
```

4. 接続文字列の生成：

```bash
./scripts/generate_connection_string.sh $(terraform output -raw db_instance_endpoint | cut -d: -f1) 5432 $(terraform output -raw db_instance_name) openwebui YourPassword
```

5. Kubernetesリソースのデプロイ：

```bash
# シークレットの更新
kubectl apply -f postgres-secret-update.yaml

# ConfigMapの適用
kubectl apply -f kubernetes/manifests/open-webui-config.yaml

# Helmリポジトリの追加
helm repo add open-webui https://helm.openwebui.com/
helm repo update

# Open WebUIのデプロイ
helm install open-webui open-webui/open-webui -f kubernetes/helm/open-webui-values.yaml

# Ingressの適用
kubectl apply -f kubernetes/manifests/open-webui-ingress.yaml
```

## アクセスと初期設定

### Open WebUIへのアクセス

デプロイが完了すると、AWS Load Balancerが作成されます。以下のコマンドでURLを取得できます：

```bash
kubectl get ingress open-webui-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

このURLにブラウザからアクセスすると、Open WebUIのログイン画面が表示されます。

### 初期アカウントの設定

初回アクセス時に管理者アカウントを作成します：

1. 「Register」をクリックして新規アカウントを作成
2. ユーザー名、メールアドレス、パスワードを入力
3. 最初に作成したアカウントが自動的に管理者権限を持ちます

### APIキーの設定

Open WebUIで外部AIモデルを使用するには、APIキーの設定が必要です：

1. ログイン後、右上のユーザーアイコンをクリック
2. 「Settings」を選択
3. 「API Keys」タブを選択
4. 使用するAIプロバイダーのAPIキーを入力して保存

## 運用管理

### リソースのモニタリング

#### EKSクラスターのモニタリング

```bash
# ノードの状態確認
kubectl get nodes

# Podの状態確認
kubectl get pods

# サービスの状態確認
kubectl get svc

# Ingressの状態確認
kubectl get ingress
```

#### PostgreSQLのモニタリング

AWS RDSコンソールまたは以下のコマンドでモニタリングできます：

```bash
# 接続テスト
PGPASSWORD=YourPassword psql -h $(terraform output -raw db_instance_endpoint | cut -d: -f1) -U openwebui -d openwebuidb -c "SELECT 1"

# データベース情報の確認
PGPASSWORD=YourPassword psql -h $(terraform output -raw db_instance_endpoint | cut -d: -f1) -U openwebui -d openwebuidb -c "\l"
```

### バックアップと復元

#### PostgreSQLのバックアップ

RDSは自動的にバックアップを作成しますが、手動でスナップショットを作成することもできます：

```bash
aws rds create-db-snapshot \
  --db-instance-identifier open-webui-postgres \
  --db-snapshot-identifier open-webui-manual-snapshot
```

#### バックアップからの復元

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier open-webui-postgres-restored \
  --db-snapshot-identifier open-webui-manual-snapshot
```

### スケーリング

#### EKSノードのスケーリング

```bash
# ノード数の変更
aws eks update-nodegroup-config \
  --cluster-name open-webui-cluster \
  --nodegroup-name open-webui-node-group \
  --scaling-config desiredSize=3,minSize=1,maxSize=5
```

#### RDSインスタンスのスケーリング

```bash
# インスタンスタイプの変更
aws rds modify-db-instance \
  --db-instance-identifier open-webui-postgres \
  --db-instance-class db.t3.small \
  --apply-immediately
```

### アップデート

#### Open WebUIのアップデート

```bash
# Helmリポジトリの更新
helm repo update

# Open WebUIのアップグレード
helm upgrade open-webui open-webui/open-webui -f kubernetes/helm/open-webui-values.yaml
```

#### EKSクラスターのアップデート

```bash
# クラスターバージョンの更新
aws eks update-cluster-version \
  --name open-webui-cluster \
  --kubernetes-version 1.28
```

## トラブルシューティング

### よくある問題と解決策

#### EKSクラスターに接続できない

```bash
# kubeconfigの再設定
aws eks update-kubeconfig --name open-webui-cluster --region us-east-1
```

#### PostgreSQL接続エラー

1. セキュリティグループの確認：
   - RDSセキュリティグループがEKSノードからの接続を許可していることを確認

2. 接続情報の確認：
   ```bash
   kubectl get secret open-webui-postgres-secret -o yaml
   ```

3. データベースの接続テスト：
   ```bash
   PGPASSWORD=YourPassword psql -h <db-endpoint> -U openwebui -d openwebuidb -c "SELECT 1"
   ```

#### Open WebUIのPodが起動しない

```bash
# Podの状態確認
kubectl get pods

# 詳細情報の確認
kubectl describe pod <pod-name>

# ログの確認
kubectl logs <pod-name>
```

#### Ingressが機能しない

```bash
# Ingressの状態確認
kubectl get ingress

# AWS Load Balancer Controllerのログ確認
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## アンインストール

環境を完全に削除するには、以下の手順に従ってください：

### 自動アンインストール

```bash
./scripts/deploy.sh --destroy
```

### 手動アンインストール

```bash
# Kubernetesリソースの削除
helm uninstall open-webui
kubectl delete -f kubernetes/manifests/

# Terraformリソースの削除
cd terraform
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## 補足情報

### セキュリティに関する注意事項

- 本番環境では、必ず強力なパスワードを使用してください
- `terraform.tfvars`ファイル内のパスワードは必ず変更してください
- RDSインスタンスのパブリックアクセスは無効になっていますが、追加のセキュリティ対策を検討してください
- 機密情報はAWS Secrets Managerなどのサービスを使用して管理することを検討してください

### コスト最適化

- 使用していない環境は`--destroy`オプションで削除してください
- 開発環境ではマルチAZ設定を無効にすることでコストを削減できます
- 小規模な環境では、ノード数やインスタンスタイプを調整してコストを最適化できます
