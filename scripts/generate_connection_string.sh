#!/bin/bash
# PostgreSQLデータベースの接続文字列を生成するスクリプト
# このスクリプトはTerraformの出力から接続文字列を生成します

# 環境変数の設定
DB_HOST="${1:-localhost}"
DB_PORT="${2:-5432}"
DB_NAME="${3:-openwebuidb}"
DB_USER="${4:-openwebui}"
DB_PASSWORD="${5:-YourSecurePasswordHere123!}"

# 使用方法の表示
function show_usage {
  echo "使用方法: $0 [DB_HOST] [DB_PORT] [DB_NAME] [DB_USER] [DB_PASSWORD]"
  echo "例: $0 my-postgres.rds.amazonaws.com 5432 openwebuidb openwebui mypassword"
  exit 1
}

# パラメータチェック
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  show_usage
fi

# 接続文字列の生成
CONNECTION_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "PostgreSQL接続文字列:"
echo "$CONNECTION_STRING"

# Kubernetesシークレットの更新用YAML生成
cat << EOF > postgres-secret-update.yaml
apiVersion: v1
kind: Secret
metadata:
  name: open-webui-postgres-secret
  namespace: default
type: Opaque
stringData:
  DATABASE_URL: "${CONNECTION_STRING}"
  WEBUI_SECRET_KEY: "your-secure-secret-key-change-this-in-production"
EOF

echo "Kubernetesシークレット更新用YAMLファイルが生成されました: postgres-secret-update.yaml"
echo "以下のコマンドでシークレットを更新できます:"
echo "kubectl apply -f postgres-secret-update.yaml"
