# current-ui.md

## このドキュメントについて

- Citytoriに現在存在する画面、状態、主要なUIを把握するための一覧です
- 実装を確認した時点の内容であり、画面や導線を変更した場合は更新します
- プロダクトの方向性は `docs/product-direction.md`、デザインの方向性は `docs/design-direction.md` を参照してください

## 画面一覧

| 画面 | route |
| --- | --- |
| 未ログインのトップ | `GET /` |
| ログイン済みホーム | `GET /` |
| 散歩一覧 | `GET /word_chain_walks` |
| 散歩中画面 | `GET /word_chain_walks/:id` |
| 散歩完了後のタイムライン | `GET /word_chain_walks/:id` |
| 散歩完了後の地図 | `GET /word_chain_walks/:id/map` |
| 散歩完了直後の結果画面 | `GET /word_chain_walks/:word_chain_walk_id/completion` |
| 個別記録詳細 | `GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id` |
| 利用規約 | `GET /terms` |
| プライバシーポリシー | `GET /privacy` |
| ユーザー詳細 | `GET /users/:id` |

## 各画面

### 未ログインのトップ

- **route**: `GET /`
- **主なview / partial**: `home/show.html.erb`、`home/_logged_out.html.erb`
- **目的**: サービス内容を伝え、Googleログインへ案内する
- **主な操作**: Googleログイン、利用規約・プライバシーポリシーの確認
- **主な状態**: 未ログイン時に表示する
- **関連Stimulus / JavaScript**: なし

### ログイン済みホーム

- **route**: `GET /`
- **主なview / partial**: `home/show.html.erb`、`home/_logged_in.html.erb`、`word_chain_walks/_active_word_chain_walk.html.erb`、`_start_word_chain_walk.html.erb`
- **目的**: 進行中の散歩を再開する、または新しい散歩を始める。直近の散歩を確認する
- **主な操作**: 「続きから歩く」、散歩開始、散歩一覧への移動
- **主な状態**:
  - 進行中の散歩がある場合は再開用カードを表示する
  - 進行中の散歩がない場合は開始カードを表示する
  - 完了済み散歩は最大3件を表示し、0件時は空状態を表示する
- **関連Stimulus / JavaScript**: `walk-start`

### 散歩一覧

- **route**: `GET /word_chain_walks`
- **主なview / partial**: `word_chain_walks/index.html.erb`、`_word_chain_walk.html.erb`
- **目的**: 進行中・完了済みの散歩を一覧し、詳細へ移動する
- **主な操作**: 散歩カードを開く、0件時に散歩を始める
- **主な状態**:
  - 進行中と完了済みで状態バッジと表示内容が変わる
  - 0件時は開始ボタン付きの空状態を表示する
- **関連Stimulus / JavaScript**: なし

### 散歩中画面

- **route**: `GET /word_chain_walks/:id`（未完了の散歩）
- **主なview / partial**: `word_chain_walks/show.html.erb`、`_active.html.erb`、`active/_target.html.erb`、`active/_count.html.erb`、`active/_latest_step.html.erb`
- **目的**: 次に探す文字を確認し、散歩中の記録を追加する
- **主な操作**: 写真を撮る、直前の記録を開く・取り消す、散歩を終える
- **主な状態**:
  - 記録数と直前の記録は、記録がある場合に表示する
  - 記録がない場合は「まだ言葉を見つけていません」を表示する
  - 次に探す文字と、開始文字として使える候補を表示する
- **関連Stimulus / JavaScript**: `modal`、`previews`、`geolocation`、`form`、Turbo Stream

### 個別記録詳細

- **route**: `GET /word_chain_walks/:word_chain_walk_id/word_chain_walk_steps/:id`
- **主なview / partial**: `word_chain_walk_steps/show.html.erb`
- **目的**: ことば、写真、メモ、位置情報を1件ずつ振り返る
- **主な操作**: 散歩詳細へ戻る
- **主な状態**:
  - メモがない場合は「メモはありません」を表示する
  - 位置情報がある場合のみ、個別の地図を表示する
  - 地図上のマーカーから開く場合は、詳細ページではなく記録カードを返す
- **関連Stimulus / JavaScript**: `step-map`、Turbo Frame

### 散歩完了直後の結果画面

- **route**: `GET /word_chain_walks/:word_chain_walk_id/completion`
- **主なview / partial**: `word_chain_walks/completions/show.html.erb`
- **目的**: 完了した散歩の結果を要約し、振り返りへ案内する
- **主な操作**: 今回の散歩を振り返る、ホームに戻る
- **主な状態**:
  - 記録0件、最後のことばが「ん」で終わった場合、それ以外で案内文が変わる
  - 写真がある場合は最大3枚を表示する
- **関連Stimulus / JavaScript**: なし

### 完了済み散歩のタイムライン

- **route**: `GET /word_chain_walks/:id`（完了済みの散歩）
- **主なview / partial**: `word_chain_walks/_finished.html.erb`、`finished/_summary.html.erb`、`finished/_timeline.html.erb`
- **目的**: 散歩の開始から完了までを時系列で振り返る
- **主な操作**: 記録詳細を開く、地図へ切り替える、散歩を削除する
- **主な状態**:
  - 位置情報付きの記録がある場合のみ、タイムライン・地図の切替を表示する
  - 位置情報がない場合はタイムラインのみ表示する
- **関連Stimulus / JavaScript**: Turbo Frame

### 完了済み散歩の地図

- **route**: `GET /word_chain_walks/:id/map`
- **主なview / partial**: `word_chain_walks/map.html.erb`、`finished/_map.html.erb`、`finished/_map_card.html.erb`
- **目的**: 位置情報付きの記録を地図上で振り返る
- **主な操作**: タイムライン・地図の切替、地図の移動、マーカーから記録の確認
- **主な状態**:
  - 完了済み散歩だけが対象
  - 位置情報が1件もない場合は散歩詳細へ戻り、アラートを表示する
- **関連Stimulus / JavaScript**: `walk-map`、Leaflet、Turbo Frame

### 利用規約・プライバシーポリシー

- **route**: `GET /terms`、`GET /privacy`
- **主なview / partial**: `home/terms.html.erb`、`home/privacy.html.erb`
- **目的**: 利用条件、Google認証、写真・位置情報の取扱い、安全上の注意を伝える
- **主な操作**: フッターまたはログイン前トップから移動する
- **主な状態**: なし
- **関連Stimulus / JavaScript**: なし

### ユーザー詳細

- **route**: `GET /users/:id`
- **主なview / partial**: `users/show.html.erb`、`users/_user.html.erb`
- **目的**: 現在のユーザー名とメールアドレスを表示する
- **主な操作**: なし
- **主な状態**: なし
- **関連Stimulus / JavaScript**: なし

## 画面内の主な状態

### 散歩開始の位置情報モーダル

- **表示箇所**: ログイン済みホームの開始カード
- **主なview / partial**: `word_chain_walks/_start_modal.html.erb`
- 「始める」を押すと表示し、位置情報の取得可否を確認する
- 取得中は開始ボタンを無効にし、成功または失敗後に開始できる
- 失敗時は「位置情報なしで散歩を始める」と表示する
- **関連Stimulus**: `walk-start`

### 写真・記録モーダル

- **表示箇所**: 散歩中画面
- **主なview / partial**: `active/_modal.html.erb`、`word_chain_walk_steps/_form.html.erb`
- 写真選択後に表示し、写真プレビュー、位置情報の状態、ことば、メモを入力する
- 登録成功時は閉じ、散歩中画面の記録数・目標文字・直前の記録を更新する
- 入力エラーはモーダル内に表示する
- **関連Stimulus**: `modal`、`previews`、`geolocation`、`form`

### 共通ナビゲーションと通知

- **主なview / partial**: `layouts/_header.html.erb`、`layouts/_footer.html.erb`、`shared/_flash_messages.html.erb`
- ログイン済み時のヘッダーには、進行中の散歩への復帰、散歩一覧、ログアウト、退会がある
- 成功通知は緑、アラートは赤で表示する
- **関連Stimulus**: `header`

### 0件・未入力の状態

- ホーム: 完了済み散歩がない場合の案内
- 散歩一覧: 散歩がない場合の開始導線
- 散歩中: 記録がない場合の案内
- 完了画面: 記録0件・写真0件の場合の案内
- 個別記録詳細: メモがない場合の案内

## 現在確認できている仮導線・未確定部分

- 「遊び方を見る」は `#` へのリンクです
- 「位置情報の設定方法を見る」は `#` へのリンクです
- ヘッダーの「つかいかた」はリンクではないテキストです
- ユーザー詳細画面はrouteとviewがありますが、現在のナビゲーションからの導線は確認できません
- PWA用のmanifestとservice workerのviewはありますが、manifestのrouteとlayoutからのリンクはコメントアウトされています
