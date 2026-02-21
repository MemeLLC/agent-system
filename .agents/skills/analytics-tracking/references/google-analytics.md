# GA4 + GTM - 設計・実装マニュアル

> GA4はすべてのアナリティクスの基盤であり、設計は後から変更が困難。初期設計を慎重に行うこと。
> 最新仕様は [GA4 Help Center](https://support.google.com/analytics/?hl=en) および [GA4 Developer Docs](https://developers.google.com/analytics/devguides/collection/ga4) で要確認。

---

## 1. プロパティ構造

### 階層

**アカウント** > **プロパティ** > **データストリーム**

- 1プロパティ = 1サイト（+ 関連アプリ）。統一ユーザージャーニーのため過度な分割を避ける
- データストリームは原則 Web 1 + iOS 1 + Android 1 の構成を推奨（公式上限は50だが、過度な分割を避ける）
- Webしかない場合はWebデータストリームを1つだけ設定する

| 設定 | 上限 |
|------|------|
| アカウントあたりプロパティ | 2,000 |
| プロパティあたりデータストリーム | 50（うちアプリ最大30） |

> サブプロパティ / ロールアッププロパティは360のみ。

---

## 2. イベント体系

### イベントカテゴリ

| カテゴリ | 説明 | 実装 |
|---------|------|------|
| **自動収集** | デフォルトで収集（`first_visit`, `session_start`, `page_view`等） | 不要 |
| **拡張計測** | GA4 UIで有効化（`scroll`, `click`, `file_download`, `video_start/progress/complete`, `form_start/submit`） | UIトグル |
| **推奨イベント** | Google規定の名前・パラメータ。特定レポート機能（収益化レポート等）が有効になる | GTM/コード |
| **カスタムイベント** | ユーザー定義。上記でカバーできないもの | GTM/コード |

**優先順位**: 推奨イベント > カスタムイベント。推奨イベントは収益化レポート自動生成やML機能に必須。

### イベント命名規則

- **大文字小文字を区別**（`my_event` ≠ `My_Event`）
- 英字で開始。英数字 + アンダースコアのみ。**40文字未満**
- **小文字スネークケース**を使用（例: `contact_form_submit`）。日本語は使用不可
- 日本語テキストはパラメータの**値**に使用する

**予約プレフィックス**（使用禁止）: `_`, `firebase_`, `ga_`, `google_`, `gtag.`

**予約イベント名**（使用禁止）: `ad_activeview`, `ad_click`, `ad_exposure`, `ad_query`, `ad_reward`, `adunit_exposure`, `app_clear_data`, `app_exception`, `app_install`, `app_remove`, `app_store_refund`, `app_store_subscription_cancel`, `app_store_subscription_convert`, `app_store_subscription_renew`, `app_update`, `app_upgrade`, `dynamic_link_app_open`, `dynamic_link_app_update`, `dynamic_link_first_open`, `error`, `first_open`, `first_visit`, `in_app_purchase`, `notification_dismiss`, `notification_foreground`, `notification_open`, `notification_receive`, `os_update`, `screen_view`, `session_start`, `user_engagement`

### イベント設計原則: イベント名よりパラメータを活用

イベント名は汎用的にし、詳細はパラメータで指定する。ユニークイベント名の増加を抑え、分析の柔軟性を確保する。

**悪い例**: `cta_click_top_banner`, `cta_click_bottom_button`, `cta_click_sidebar_link`

**良い例**:
```
Event: cta_click
Parameters:
  cta_id: cta_bnr_top / cta_btn_btm / cta_link_side
  click_url: https://...
```

パラメータ値のプレフィックスパターン: `種別_位置`（例: `cta_bnr_top`, `cta_btn_footer`）

> 運用上の目安: カスタムイベントは15〜25個程度に収める。Webは公式上限なしだがアプリは500のハードリミット。

### パラメータ規則

| 項目 | 制限 |
|------|------|
| イベントあたりパラメータ数 | 25 |
| パラメータ名 | 40文字、英数字+アンダースコア、英字開始 |
| パラメータ値 | 100文字（標準）/ 500文字（360） |
| ユーザープロパティ名 | 24文字 |
| ユーザープロパティ値 | 36文字 |

---

## 3. 推奨イベントリファレンス

### 全プロパティ共通

| イベント | 用途 |
|---------|------|
| `login` | ログイン |
| `sign_up` | サインアップ |
| `search` | サイト内検索 |
| `select_content` | コンテンツ選択 |
| `share` | コンテンツ共有 |

### Eコマース

> 「必須パラメータ」= 送らなくてもイベントは発火するが、収益化レポート・最適化・ROAS計測に不可欠なため実質必須。

| イベント | 用途 | 必須パラメータ |
|---------|------|---------------|
| `view_item_list` | 商品リスト閲覧 | `items` |
| `select_item` | 商品選択 | `items` |
| `view_item` | 商品詳細閲覧 | `currency`, `value`, `items` |
| `add_to_cart` | カート追加 | `currency`, `value`, `items` |
| `remove_from_cart` | カート削除 | `currency`, `value`, `items` |
| `add_to_wishlist` | ウィッシュリスト追加 | `currency`, `value`, `items` |
| `view_cart` | カート閲覧 | `currency`, `value`, `items` |
| `begin_checkout` | チェックアウト開始 | `currency`, `value`, `items` |
| `add_shipping_info` | 配送情報送信 | `currency`, `value`, `items` |
| `add_payment_info` | 支払い情報送信 | `currency`, `value`, `items` |
| `purchase` | 購入完了 | `currency`, `value`, `transaction_id`, `items` |
| `refund` | 返金 | `currency`, `value`, `transaction_id` |

### リードジェネレーション

| イベント | 用途 | 必須パラメータ |
|---------|------|---------------|
| `generate_lead` | リード生成（フォーム送信） | `currency`, `value` |
| `qualify_lead` | リード適格判定 | `currency`, `value` |
| `disqualify_lead` | リード不適格判定 | `currency`, `value` |
| `close_convert_lead` | リードコンバージョン | `currency`, `value` |
| `close_unconvert_lead` | 未コンバージョン | `currency`, `value` |

### SaaS向けカスタムイベント例

```
# オンボーディング
onboarding_start / onboarding_step_complete (step_name, step_number) / onboarding_complete

# 機能利用
feature_used (feature_name, feature_category) / feature_discovered (feature_name)

# サブスクリプション
plan_viewed (plan_name, plan_price) / trial_started / trial_expired
subscription_started (plan_name, billing_cycle, value)
subscription_upgraded / subscription_downgraded (from_plan, to_plan)
subscription_canceled (cancel_reason)

# サポート
help_article_viewed (article_id) / support_ticket_created / feedback_submitted (feedback_type, rating)
```

### items配列の構造

- イベントあたり最大**200アイテム**、items配列内に最大**27のカスタムパラメータ**
- 標準フィールド: `item_id`, `item_name`, `price`, `quantity`, `item_brand`, `item_category`（最大5階層）, `item_variant`, `affiliation`, `discount`, `coupon`, `location_id`, `index`

---

## 4. キーイベント（コンバージョン）

GA4では「コンバージョン」→「キーイベント」に名称変更。任意のイベントをキーイベントとしてマーク可能。本当に重要なビジネスアクションのみをマークする。

### カウント方法

| 方法 | 動作 | 最適な用途 |
|------|------|-----------|
| **毎回（Once per event）** | 発火するたびにカウント | Eコマース（各購入をカウント） |
| **セッションごとに1回（Once per session）** | 同一セッション内では1回のみカウント | リード（重複防止） |

### コンバージョンウィンドウ

| タイプ | デフォルト | オプション |
|------|-----------|-----------|
| 獲得イベント（`first_open`, `first_visit`） | 30日 | 7日 |
| その他キーイベント | 90日 | 30日、60日 |

### アトリビューション

GA4で利用可能なモデルは**2つのみ**（他は廃止済み）:

| モデル（UI表記） | 説明 | 推奨ケース |
|-----------------|------|-----------|
| **Data-driven** | MLで各タッチポイントの貢献度を算出 | 月間200+ CV / 2,000+ タッチポイント |
| **Paid and organic channels last click** | 最後の有料/オーガニックタッチポイントに100%クレジット | CV量が少ない / シンプルな購入フロー |

**推奨**: トラフィックが少ない段階はlast click → データ蓄積後にdata-drivenへ切替。

**レポートごとのアトリビューションの違い**（設定に関係なく固定）:

| レポート | 使用アトリビューション |
|---------|---------------------|
| トラフィック獲得 | ラスト非直接クリック |
| ユーザー獲得 | ファーストタッチ |
| コンバージョン | 選択したモデル（Data-driven or Last click） |

> これはデータ不一致の主要な原因。レポートの数値が合わない場合、まずこの違いを確認する。

### Google Adsとの連携

- GA4キーイベントはGoogle Adsで**セカンダリ**がデフォルト → 入札に使うなら**プライマリ**に変更
- インポート後、入札戦略適用まで**3週間**待つ
- 反映: 最大**24時間**
- 移行時: 旧CVアクションを「セカンダリ」→ 新GA4アクションを「プライマリ」

---

## 5. カスタムディメンション・指標

### クォータ

| タイプ | 標準 | 360 |
|--------|------|-----|
| イベントスコープ | 50 | 125 |
| ユーザースコープ | 25 | 100 |
| アイテムスコープ | 10 | 25 |
| カスタム指標 | 50 | 125 |

### ベストプラクティス

- **まず既定ディメンションを確認**。既存パラメータに重複登録するとクォータを浪費
- **高カーディナリティを避ける**: ユニーク値が多すぎると「(other)」行に集約される（目安: 数百ユニーク値程度で発生し得る。状況により変動）。Event ID / Session ID / User IDを登録しない
- **User IDはビルトインのUser-ID機能を使用**（カスタムディメンションにしない）
- 数値データには**カスタム指標**を使用
- 削除後、再作成まで**48時間**待つ
- カスタムパラメータ作成後は速やかにカスタムディメンション/指標を登録（登録しないとUIレポートに表示されない）

---

## 6. GTM 連携設計

### Googleタグ（GA4設定）

- Googleタグ = GA4への接続を確立する基盤タグ。**初期化トリガー**で全ページ発火
- GA4イベントタグは個別のトリガーで発火（旧「構成タグ」ドロップダウンは廃止済み）
- **設定変数**を使用してタグ間で共通パラメータを共有。**Googleタグ設定変数をMeasurement ID・server container URL・共通パラメータ・同意状態の唯一の定義元とし、イベントタグはその変数を参照するだけにする**（二重定義防止）
- **二重タグ禁止**: gtag.jsとGTMベースのGA4タグを同時使用するとデータが二重収集される。必ずどちらか一方のみ

### GTM命名規則

**タグ**: `[Platform] [type] - [name]`
- 例: `GA4 event - generate_lead`, `GA4 config`, `Meta - Purchase`

**トリガー**: `[Type] - [Description]`
- 例: `click - blog - register button`, `CE - purchase`, `timer - 30s engagement`

**変数**: `[prefix] - [description]`

| プレフィックス | 種類 |
|---------------|------|
| `dlv` | Data Layer Variable |
| `cookie` | First-party Cookie |
| `js` | JavaScript Variable |
| `cjs` | Custom JavaScript |
| `url` | URL Variable |
| `aev` | Auto-Event Variable |
| `regex` | Regular Expression |
| `const` | 定数 |

例: `dlv - ecommerce.value`, `cjs - X Pixel Contents`, `const - GA4 Measurement ID`

### DataLayer設計

**初期化**: GTMコンテナスニペットの**前に**宣言

```javascript
window.dataLayer = window.dataLayer || [];
```

**設計規則**:

- `event`キーを含めてイベントをプッシュする
- 変数名はキャメルケース（GTMは大文字小文字を区別）
- 説明的な名前を使用（`page_category` ✓, `cat` ✗）
- HTMLスクレイピングではなく明示的なdataLayerプッシュを使用

```javascript
dataLayer.push({
  event: 'form_submit',
  form_type: 'contact',
  form_location: 'footer'
});
```

**永続性**: dataLayer変数は現在のページ内でのみ保持。ページ遷移後は再プッシュまたはCookie/localStorageが必要。

### SPA対応

SPAでは`page_view`の二重計測やイベント欠落が起きやすい。方針を**事前に**決定すること。

**方針1（推奨）**: 拡張計測の「ブラウザの履歴イベントに基づくページの変更」を有効にする
- `history.pushState` / `popstate`を検知して自動`page_view`送信
- React Router、Vue Router、Next.js等で対応可能

**方針2**: 拡張計測の自動`page_view`を**無効**にし、GTMで手動送信
- `page_location`と`page_title`を明示的に設定

**二重計測チェック**: DebugViewでページ遷移ごとに`page_view`が**1回だけ**発火しているか必ず検証。

### サーバーサイドGTM（sGTM）

- ブラウザ → sGTMサーバー（1 HTTPリクエスト）→ 各ベンダー（GA4, Google Ads, Meta等）にディスパッチ
- クライアントサイドHTTPリクエスト減 → ページパフォーマンス向上
- `server_container_url`をGoogleタグとGA4イベントタグの**両方**に設定
- **注意**: 最初のヒットがsGTMをバイパスする可能性あり。適切なルーティングを確認

---

## 7. Eコマーストラッキング

### dataLayerパターン

**必須**: Eコマースイベントプッシュの**前に**eコマースオブジェクトをクリアする（残留データによる汚染防止）。

```javascript
dataLayer.push({ ecommerce: null }); // 前回のeコマースデータをクリア
dataLayer.push({
  event: 'add_to_cart',
  ecommerce: {
    currency: 'JPY',
    value: 3980,
    items: [{
      item_id: 'SKU_12345',
      item_name: 'Product Name',
      price: 3980,
      quantity: 1
    }]
  }
});
```

### GTMの「Eコマースデータを送信」チェックボックス

GA4イベントタグで有効にすると、dataLayerからeコマースデータを**自動読み取り**。個別の変数設定は不要。

### よくある間違い

1. `dataLayer.push({ ecommerce: null })` を実行しない → 残留データで後続イベント汚染
2. `currency` / `value`の省略 → 収益化レポートに数値が出ない
3. `transaction_id`にランダム値使用 → 重複排除が機能しない。安定した注文IDを使用すること
4. 連続イベント（数量ボタン連打等）にスロットリング/デバウンスを適用しない

### GTM vs. gtag.js

| 方式 | 推奨ケース |
|------|-----------|
| **gtag.js** | GA4のみでEコマース計測する場合 |
| **GTM** | 複数プラットフォーム（GA4 + Google Ads + Meta等）で同じdataLayerを共有する場合 |

---

## 8. データ品質

### 内部トラフィックフィルタリング

1. データストリーム > タグ設定 > 内部トラフィックの定義 でIP指定
2. データ設定 > データフィルタ でフィルタ作成
3. まず**「テスト」**状態で検証 → 確認後**「アクティブ」**に手動変更

> デフォルトは「テスト」状態で**フィルタリングは有効になっていない**。「アクティブ」への変更を忘れやすい。

### 開発者トラフィックフィルタリング

デバッグモード有効時のトラフィックを本番データから除外。データ設定 > データフィルタで有効化。

### リファラル除外

- 決済プロセッサー（PayPal、Stripe等）をリファラル除外リストに追加
- クロスドメイン設定に含まれるドメインの自己リファラルは自動処理

### クロスドメイントラッキング

- データストリーム > タグ設定 > ドメインの設定
- すべてのドメインで**同じ測定ID**（`G-XXXXX`）を使用
- `_gl`パラメータでクライアントIDを引き継ぎ
- リンク装飾（`<a>`タグ）に加え**フォーム装飾**（form decoration）も公式対応
- **よくある問題**: サーバーリダイレクトが`_gl`パラメータを除去する → リダイレクト時にURLパラメータ保持を要確認

---

## 9. User ID・レポーティングアイデンティティ

### User-ID

- ユニーク識別子（256文字以下）をログイン時に送信
- サインイン時: IDを送信 / 未サインイン: パラメータ送信しない / サインアウト時: `null`
- **カスタムディメンションに登録しない**（ビルトインUser-ID機能を使用）

### レポーティングアイデンティティ

| オプション | 方法 | 推奨 |
|-----------|------|------|
| **ブレンド** | User-ID > デバイスID > モデリング | **推奨**（最大カバレッジ） |
| オブザーブド | User-ID > デバイスID | モデリング不要の場合 |
| デバイスベース | デバイスIDのみ | シンプルだが精度最低 |

> Google Signals有効化でクロスデバイスインサイトが得られるが、トラフィックの少ないデータがしきい値処理で非表示になることがある。

---

## 10. 同意モード・プライバシー

### 同意タイプ

| 同意タイプ | 制御対象 |
|-----------|---------|
| `analytics_storage` | アナリティクスCookie/識別子 |
| `ad_storage` | 広告Cookie/デバイス識別子 |
| `ad_user_data` | 広告目的のユーザーデータ送信 |
| `ad_personalization` | パーソナライズド広告 |
| `functionality_storage` | 機能性Cookie |
| `personalization_storage` | パーソナライゼーション |
| `security_storage` | セキュリティ・不正防止 |

### 実装モード

| モード | 動作 | 特徴 |
|--------|------|------|
| **ベーシック** | 同意までタグをブロック | データ送信なし。一般的CVモデリング |
| **アドバンスド（推奨）** | デフォルト「拒否」でタグ読込。Cookieレスpingを送信 | 広告主固有のCVモデリング有効 |

> デフォルト同意設定は、同意バナーが表示される地域にスコープ限定する（バナー不要の地域では計測を維持）。

### 行動モデリングのしきい値

- `analytics_storage='denied'`: **7日間**にわたり1日**1,000イベント**以上
- `analytics_storage='granted'`のデイリーユーザー: **28日間のうち7日間**で1日**1,000ユーザー**以上
- しきい値を満たしても適格性は保証されない（MLが追加基準を適用）

### PII禁止

GA4にメールアドレス・電話番号・氏名・住所・クレジットカード番号・政府発行IDを送信してはならない（利用規約違反 → アカウント停止リスク）。

**よくある混入経路**:
- URLクエリパラメータにメール含有 → `page_location`に記録される
- フォーム入力値をパラメータとして誤送信
- User-IDにメール/ユーザー名を使用（ハッシュ化した内部IDを使うこと）

**対策**:
- データストリーム > タグ設定 > 「クエリパラメータをさらに構成する」で、PIIを含むクエリパラメータを除外リストに追加
- アプリ側のURL設計でPIIをクエリパラメータに含めない

### データ保持

| オプション | 条件 |
|-----------|------|
| 2ヵ月 | 標準デフォルト |
| **14ヵ月** | **標準で推奨（最大値）** |
| 26〜50ヵ月 / 無期限 | 360のみ |

- データ保持は**探索レポートにのみ**影響。標準集計レポートは無期限
- 年齢/性別/興味関心データは常に2ヵ月制限
- Google Signalsデータは最大26ヵ月
- **プロパティ作成後すぐに14ヵ月に変更する**

---

## 11. レポート・オーディエンス

### 探索レポート

| 手法 | 用途 |
|------|------|
| 自由形式 | ピボットテーブル、グラフ作成 |
| ファネル探索 | 最大10ステップ、離脱率（オープン/クローズド） |
| 経路探索 | ナビゲーションパスの可視化 |
| セグメントの重複 | 最大3セグメント比較（ベン図） |
| ユーザーエクスプローラ | 個別ユーザーのタイムライン |
| ユーザーのライフタイム | 長期LTV分析 |
| コホート探索 | 獲得日別リテンション |

> 探索はデータ保持設定の影響を受ける。サンプリング上限: 1,000万イベント（標準）/ 10億（360）。

### オーディエンス

| 設定 | 値 |
|------|-----|
| デフォルトメンバーシップ | 30日 |
| 最大メンバーシップ | 540日 |
| 上限 | 100（標準）/ 400（360） |
| 蓄積開始 | 24〜48時間（遡及適用なし） |

- **予測オーディエンス**: 7日間購入見込み / 離脱見込み / 予測収益（月間200+ CV / 2,000+ タッチポイント推奨）
- Google Ads連携時、リマーケティング用に自動エクスポート（反映に最大2日）

**行動ベースのセグメント例**:
- カート放棄者（追加後X日以内に未購入）
- 高エンゲージメント（エンゲージセッション > 閾値）
- 機能探索者（料金・機能ページ閲覧）
- シーケンス条件: リスト閲覧 → 詳細閲覧 → カート追加（未購入）
- 除外: 直近30日の購入者、直帰トラフィック（`engagement_time` < 10秒）

---

## 12. Google Ads / Search Console 連携

### Google Ads

**セットアップ**: GA4の編集者ロール + Google Adsの管理者アクセス。自動タグ付け有効化。GCLIDがリダイレクトで除去されないことを確認。

**キーイベントの取り扱い**:
- GA4キーイベントはGoogle Adsで**セカンダリ**がデフォルト → 入札に使うなら**プライマリ**に変更
- インポート後、入札戦略適用まで**3週間**待つ
- CV反映: 最大24時間

### Search Console

- GA4の編集者 + Search Consoleの確認済みオーナー
- ウェブデータストリームと1:1の関係
- データ利用可能: 収集後48時間

---

## 13. 設定上限サマリー

### スタンダードプロパティ

| 設定項目 | 上限 |
|---------|------|
| アカウントあたりプロパティ | 2,000 |
| プロパティあたりデータストリーム | 50（アプリ最大30） |
| ユニークイベント名（Web） | 無制限（運用上500以内推奨） |
| ユニークイベント名（アプリ） | 500（ハードリミット） |
| イベントあたりパラメータ | 25 |
| イベント名 | 40文字 |
| パラメータ名 | 40文字 |
| パラメータ値 | 100文字 |
| ユーザープロパティ名 | 24文字 |
| ユーザープロパティ値 | 36文字 |
| イベントスコープ カスタムディメンション | 50 |
| ユーザースコープ カスタムディメンション | 25 |
| アイテムスコープ カスタムディメンション | 10 |
| カスタム指標 | 50 |
| オーディエンス | 100 |
| キーイベント | 30 |
| Eコマース items/イベント | 200 |
| カーディナリティ閾値 | 目安: 数百ユニーク値で「(other)」発生（状況依存） |
| 探索サンプリング | 1,000万イベント |
| セッションタイムアウト | デフォルト30分（最大7時間55分） |
| データ保持 | デフォルト2ヵ月（最大14ヵ月） |

### 360プロパティ（差分のみ）

| 設定項目 | 上限 |
|---------|------|
| パラメータ値 | 500文字 |
| イベントスコープ カスタムディメンション | 125 |
| ユーザースコープ カスタムディメンション | 100 |
| アイテムスコープ カスタムディメンション | 25 |
| カスタム指標 | 125 |
| オーディエンス | 400 |
| キーイベント | 50 |
| 探索サンプリング | 10億イベント |

---

## 14. テスト・検証

### DebugView

- GA4管理画面でイベント・パラメータをリアルタイム表示
- `debug_mode`はデバッグ表示用のフラグであり、**イベント送信自体は止めない**（本番レポートに載り得る）
- 本番レポートから除外するには**開発者トラフィックのデータフィルタ**を有効化する
- 標準レポートは**24〜48時間**の処理遅延あり

### デバッグモード有効化

| 方法 | 説明 |
|------|------|
| GTMプレビューモード | 自動で`debug_mode: true`付与（最も簡単） |
| Chrome拡張 | Google Analytics Debugger |
| 手動パラメータ | GTMタグ設定で`debug_mode: true`追加 |

### 検証のベストプラクティス

- テストプランに従い、ランダムブラウジングしない
- キャッシュ干渉を避けるためシークレットモードを使用
- **エッジケースもテスト**（未ログインでカート追加、割引コード適用時、Cookie拒否時等）
- 期待値と実際の値を記録する
- 3つのツール併用: **DebugView** + **GTM Tag Assistant** + **DevTools Network**
- Eコマース: 正しいイベント名、ユニークな`transaction_id`、パラメータ構文を検証

---

## 15. 初期セットアップチェックリスト

### 初日

1. GA4プロパティ作成（アカウント構造確認）
2. ウェブデータストリーム作成（最大3つ）
3. GTM経由でGoogleタグインストール（**初期化トリガー**使用）
4. **データ保持を14ヵ月に変更**
5. **拡張計測イベントを有効化**（各トグルを個別確認。すべてを盲目的に有効にしない）
6. 内部トラフィックルール定義（IP指定）
7. 内部トラフィックフィルタ作成（「テスト」→ 検証 →「アクティブ」に変更）
8. 開発者トラフィックフィルタ作成・有効化
9. Google Signals有効化（該当する場合）

### 第1週

10. 推奨イベント実装（ビジネスタイプに適したもの）
11. キーイベント設定（カウント方法選択）
12. クロスドメイントラッキング設定（複数ドメインの場合）
13. Search Console連携
14. Google Ads連携（広告運用中の場合）
15. User-ID設定（認証機能がある場合）
16. GTM命名規則を策定・チーム共有

### 第2〜3週

17. カスタムディメンション・指標を登録
18. オーディエンス作成（リマーケティング・分析用）
19. 同意モード設定（特にEUトラフィック向け）
20. アトリビューション設定（DDA推奨。データが十分な場合）
21. リファラル除外設定（決済プロセッサー等）
22. DebugView + リアルタイムレポートで全体検証
23. **計測プランをスプレッドシートでドキュメント化**（イベント名・パラメータ・期待値・発火条件・カスタムディメンション登録状況）

---

## 16. 参考リンク

### GA4 公式

- [GA4 Help Center](https://support.google.com/analytics/?hl=en)
- [GA4 Developer Docs](https://developers.google.com/analytics/devguides/collection/ga4)
- [Recommended Events Reference](https://developers.google.com/analytics/devguides/collection/ga4/reference/events)
- [Ecommerce Implementation](https://developers.google.com/analytics/devguides/collection/ga4/ecommerce)
- [Configuration Limits](https://support.google.com/analytics/answer/12229528?hl=en)
- [Consent Mode](https://developers.google.com/tag-platform/security/concepts/consent-mode)
- [Data Retention](https://support.google.com/analytics/answer/7667196?hl=en)
- [Key Events](https://support.google.com/analytics/answer/9267568?hl=en)
- [Attribution Settings](https://support.google.com/analytics/answer/10597962?hl=en)
- [Cross-Domain Setup](https://support.google.com/analytics/answer/10071811?hl=en)
- [User-ID](https://developers.google.com/analytics/devguides/collection/ga4/user-id)

### 実務者リソース

- [Simo Ahava - GA4 Implementation Guide](https://www.simoahava.com/analytics/implementation-guide-events-google-analytics-4/)
- [Analytics Mania - GTM Naming Conventions](https://www.analyticsmania.com/post/google-analytics-and-google-tag-manager-naming-conventions/)
- [Analytics Mania - DataLayer Tutorial](https://www.analyticsmania.com/post/ultimate-google-tag-manager-data-layer-tutorial/)
- [Growth Runner - GA4 Gotchas & Limitations](https://growthrunner.com/blog/ga4-gotchas-limitations/)
