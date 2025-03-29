#!/bin/bash
# PostgreSQLデータベース初期化スクリプト
# このスクリプトはRDSインスタンス作成後に実行し、必要な拡張機能を有効化します

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

echo "PostgreSQLデータベースの初期化を開始します..."
echo "ホスト: $DB_HOST"
echo "ポート: $DB_PORT"
echo "データベース名: $DB_NAME"
echo "ユーザー名: $DB_USER"

# PostgreSQLクライアントの確認
if ! command -v psql &> /dev/null; then
  echo "PostgreSQLクライアントがインストールされていません。インストールしてください。"
  echo "例: apt-get install postgresql-client"
  exit 1
fi

# データベース接続テスト
echo "データベース接続をテストしています..."
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &> /dev/null; then
  echo "データベース接続に失敗しました。接続情報を確認してください。"
  exit 1
fi

echo "データベース接続に成功しました。"

# pgvector拡張機能の有効化
echo "pgvector拡張機能を有効化しています..."
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS pgvector;" &> /dev/null; then
  echo "pgvector拡張機能が正常に有効化されました。"
else
  echo "pgvector拡張機能の有効化に失敗しました。"
  exit 1
fi

# データベース情報の表示
echo "データベース情報:"
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "\dx"

echo "PostgreSQLデータベースの初期化が完了しました。"
