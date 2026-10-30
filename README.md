<img src="app/assets/images/top-logo.png" alt="logo" width="600">

CityToriは、街で見つけたものでしりとりをしながら歩き、しりとり形式で言葉をつないでいくゲーム形式の移動ログサービスです。

ランダムで提示された最初の文字をもとに、街にある看板や草花、ものを撮影し、その名前をひらがなで入力して次の文字につなげます。
写真から文字を自動認識するサービスではありません。

いつもの散歩や移動に「ことばを探す」という遊びを加えることで、普段なら見過ごしていたものに目を向けるきっかけをつくります。

写真を撮りながら遊ぶため、スマートフォンでの利用をおすすめします。
記録した散歩はPCからも閲覧できます。

## サービスURL

https://citytori.com

## スクリーンショット
### トップページ
<img width="1184" alt="トップページのキャプチャ" src="https://github.com/machida/citytori/blob/design/review-fixes-2026-10-19/docs/screenshots/2026-10-27/landing.png?raw=true">

### 散歩中・直前の記録
<img width="1184" alt="ホームのキャプチャ" src="https://github.com/machida/citytori/blob/design/review-fixes-2026-10-19/docs/screenshots/2026-10-27/active.png?raw=true">

### 散歩完了
<img width="1184" alt="ホームのキャプチャ" src="https://github.com/machida/citytori/blob/design/review-fixes-2026-10-19/docs/screenshots/2026-10-27/completion.png?raw=true">

### 地図・記録の選択状態
<img width="1184" alt="ホームのキャプチャ" src="https://github.com/machida/citytori/blob/design/review-fixes-2026-10-19/docs/screenshots/2026-10-27/map.png?raw=true">

### 散歩の記録（タイムライン）
<img width="1184" alt="ホームのキャプチャ" src="https://github.com/machida/citytori/blob/design/review-fixes-2026-10-19/docs/screenshots/2026-10-27/timeline.png?raw=true">

## 使い方
1. Googleアカウントでログインして、しりとり散歩を始めます。
2. 表示された文字から始まるものを街で探し、写真とひらがなのことばを記録します。メモも残せます。
3. 次の文字でしりとりを続け、散歩のあとに写真やことばを振り返ることができます。

例えば、花を撮って「はな」と記録すると、次に探す文字は「な」になります。

散歩は好きなタイミング、または「ん」で終わることばの記録で終了します。

ブラウザで位置情報の利用を許可すると、取得できた場所も記録し、地図で振り返れます。位置情報なしでも利用できます。

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
| バックエンド | Ruby 4.0.9、Ruby on Rails 8.1.4 |
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

PostgreSQLを起動し、開発用とテスト用DBを作成できるロールを用意してください。

### 1. リポジトリの取得

```sh
git clone https://github.com/yokomaru/citytori.git
cd citytori
bundle install
npm ci
```

### 2. 開発用credentialsの準備

Googleログインの認証情報はRails credentialsで管理しています。

`bin/setup`を実行する前に、以下の開発環境用ファイルを準備してください。

- `config/credentials/development.yml.enc`：暗号化された認証情報
- `config/credentials/development.key`：復号するための鍵

リポジトリには `development.yml.enc` が含まれていますが、復号用の鍵は含まれていません。

Google CloudでOAuthクライアントを「ウェブ アプリケーション」として作成し、自分のクライアントIDとクライアントシークレットを取得してください。

初回clone後は、既存の暗号化ファイルを退避し、自分用の開発credentialsを作成します。`development.key`がない場合は、鍵も自動生成されます。

```sh
mv config/credentials/development.yml.enc config/credentials/development.yml.enc.bak
EDITOR="vi" bin/rails credentials:edit --environment development
```

開いたエディタに以下の認証情報を設定して保存してください。

```yaml
google:
  client_id: "Google OAuthのクライアントID"
  client_secret: "Google OAuthのクライアントシークレット"
```

また、Google Cloudの「承認済みのリダイレクトURI」に以下を登録してください。

```text
http://localhost:3000/auth/google_oauth2/callback
```

※ この準備は初回のみ必要です。別の環境用の`RAILS_MASTER_KEY`を設定している場合は、作成前に`unset RAILS_MASTER_KEY`で解除してください。

※ 退避した`.bak`ファイル、`development.key`、認証情報の平文、自分用に生成した`development.yml.enc`はGitにコミットしないでください。

### 3. セットアップ・起動

```sh
bin/setup
```

DBの準備後、RailsサーバーとTailwind CSSの監視ビルドが起動します。

起動後、http://localhost:3000 にアクセスします。

次回以降は以下で起動できます。

```sh
bin/dev
```

## テスト
初回はDBとCSSを準備します。

```sh
RAILS_ENV=test bin/rails db:prepare
RAILS_ENV=test bin/rails tailwindcss:build
```

テストを実行します。

```sh
bundle exec rspec
```

※ `DATABASE_URL`を指定する場合はテスト専用DBを使用し、開発用の`RAILS_MASTER_KEY`は解除してください。

## Lint

```sh
bin/lint
```

## Formatter

```sh
bin/format
```
