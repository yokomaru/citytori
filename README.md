# Citytori

CityToriは、街で見つけたものの名前を使って、しりとり形式で言葉をつないでいくゲーム形式の移動ログサービスです。

ランダムで提示された最初の文字をもとに、街にある看板や草花、ものを撮影し、その名前をひらがなで入力して次の文字につなげます。写真から文字を自動認識するサービスではありません。

写真を撮りながら遊ぶため、スマートフォンでの利用をおすすめします。記録した散歩はPCからも閲覧できます。

## サービスURL

[Citytori](https://citytori.com)

## 使い方

1. Googleアカウントでログインし、しりとり散歩を始めます。
2. 表示された文字から始まるものを街で探し、写真とひらがなのことばを記録します。メモも残せます。
3. 次の文字でしりとりを続け、散歩のあとに写真やことばを振り返ります。

例えば、花を撮って「はな」と記録すると、次に探す文字は「な」です。
散歩は好きなタイミング、または「ん」で終わることばの記録で終了します。
位置情報は任意で取得でき、記録した場所は地図でも振り返れます。

詳しくは[遊び方](https://citytori.com/how-to-play)をご覧ください。

## 主な機能

| 機能 | 内容 |
| --- | --- |
| しりとり散歩 | ランダムな文字から開始し、記録したことばに応じて次の文字を表示 |
| 写真・ことばの記録 | 街で見つけたものを撮影し、ひらがなで名前を記録 |
| メモ | 気づいたことを記録し、あとから追加・編集 |
| 散歩の振り返り | 過去の散歩の写真・ことば・メモを閲覧 |
| 地図 | 位置情報を記録した場所を地図で表示 |

## 使用技術

| 分類 | 技術 |
| --- | --- |
| バックエンド | Ruby 4.0.5、Ruby on Rails 8.1.4 |
| フロントエンド | Hotwire（Turbo / Stimulus）、Tailwind CSS 4.3.1 |
| データベース | PostgreSQL 18 |
| 認証 | Google OAuth 2.0（OmniAuth） |
| 画像管理・保存 | Active Storage、libvips、Cloudflare R2 |
| 地図 | Leaflet |
| インフラ・デプロイ | さくらのVPS、Kamal |
| CI/CD | GitHub Actions |
| テスト | RSpec、Capybara、Selenium |
| Lint・フォーマット | RuboCop、ESLint、Prettier、Herb Linter |

## 環境構築

### 前提条件

Ruby（[.ruby-version](.ruby-version)参照）、Bundler、PostgreSQL 18、libvips、Node.js・npmが必要です。
PostgreSQLを起動し、開発用・テスト用DBを作成できるロールを用意してください。

### 1. リポジトリの取得

```sh
git clone https://github.com/yokomaru/citytori.git
cd citytori
bundle install
npm ci
```

### 2. Googleログインの設定

Google CloudでOAuthクライアントIDとクライアントシークレットを取得し、開発用のRails credentialsに設定します。
既存のcredentialsを編集するには、対応する`config/credentials/development.key`が必要です。鍵の準備については管理者に確認してください。

```sh
EDITOR="vi" bin/rails credentials:edit --environment development
```

```yaml
google:
  client_id: "取得したクライアントID"
  client_secret: "取得したクライアントシークレット"
```

Google Cloudの承認済みリダイレクトURIに、以下を登録してください。

```text
http://localhost:3000/auth/google_oauth2/callback
```

### 3. セットアップ・起動

```sh
bin/setup
```

DBの準備後、RailsサーバーとTailwind CSSの監視ビルドが起動します。
起動後、[http://localhost:3000](http://localhost:3000)にアクセスします。

次回以降は以下で起動できます。

```sh
bin/dev
```

## テスト

テストにはGoogle Chromeとテスト用credentialsの復号鍵が必要です。
`DATABASE_URL`を指定する場合はテスト専用DBを使い、`RAILS_MASTER_KEY`もテスト用の鍵を指定してください。

```sh
bundle exec rspec
```

## Lint

```sh
bin/lint
```
