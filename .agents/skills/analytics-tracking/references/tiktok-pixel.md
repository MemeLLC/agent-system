# TikTok Pixel - GTM実装マニュアル

> 最新仕様は [TikTok Pixel](https://ads.tiktok.com/help/article/tiktok-pixel) および [Standard Events & Parameters](https://ads.tiktok.com/help/article/standard-events-parameters) で要確認。

---

## 1. イベント・パラメータリファレンス

### 標準イベント

> **PageView（ページ計測）**: 標準イベントとは別枠。Base Codeの `ttq.page()` で自動発火する。GTMではBaseタグ（All Pagesトリガー）で対応。最適化・CV設計には以下の標準イベントを使用。

| イベント名 | 用途例 |
|-----------|-------|
| **ViewContent** | 商品詳細ページ、記事ページ |
| **Search** | サイト内検索 |
| **AddToCart** | カート追加 |
| **AddToWishlist** | お気に入り登録 |
| **InitiateCheckout** | チェックアウトページ遷移 |
| **AddPaymentInfo** | 支払い情報入力完了 |
| **Purchase** | 購入完了（旧名称: CompletePayment / PlaceAnOrder） |
| **Lead** | リード獲得・フォーム送信（旧名称: SubmitForm） |
| **CompleteRegistration** | 会員登録完了 |
| **Contact** | 問い合わせ（電話クリック含む） |
| **Download** | ファイルダウンロード |
| **Subscribe** | 購読・ニュースレター登録 |
| **StartTrial** | トライアル開始 |
| **Schedule** | 予約確認 |
| **SubmitApplication** | 申請フォーム送信 |
| **ApplicationApproval** | 申請承認 |
| **FindLocation** | 店舗検索 |
| **CustomizeProduct** | 商品カスタマイズ |
| **Login** | ログイン成功 |

> **旧イベント名の移行**（2系統あり）:
> - **リネーム（旧名も継続サポート）**: CompletePayment→Purchase、SubmitForm→Lead（バックエンドで新名称に自動変換。旧名でも動作する）
> - **Soft-deprecated（2027年まで）**: ClickButton、PlaceAnOrder（要公式確認）
> **新規実装では必ず新名称を使用。**
>
> **注意**: 上記一覧は調査時点のもの。最適化・入札に使用できるイベントは [Supported standard events](https://ads.tiktok.com/help/article/standard-events-parameters) を正として採用すること。

### イベントパラメータ

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `value` | Number | 注文合計金額（`currency` と常にセットで送信。ROAS計測・VBOに必須） |
| `currency` | String | ISO 4217通貨コード（`'JPY'`等） |
| `content_id` | String | 商品ID（カタログSKU IDと完全一致必須。DPA利用時は必須） |
| `content_ids` | Array | 複数商品ID（例: `['987','654']`） |
| `content_type` | String | `'product'`（SKU ID指定時）or `'product_group'`（グループID指定時）。DPA利用時は必須 |
| `content_name` | String | 商品名・ページ名 |
| `content_category` | String | 商品カテゴリ |
| `contents` | Array | 商品詳細の配列（下表参照） |
| `price` | Number | 単価（`value` = 合計金額、`price` = 単品価格。別概念） |
| `quantity` | Integer | 数量 |
| `search_string` | String | サイト内検索クエリ（Searchイベントで推奨。※一部ドキュメントでは `query` と記載される場合あり） |
| `description` | String | アイテムの追加説明 |
| `status` | String | ステータス |
| `order_id` | String | 注文ID |
| `num_items` | Integer | アイテム数 |

> **event_id**: イベントパラメータ（第2引数）ではなく**設定オブジェクト（第3引数）**で指定する一意識別子。Events API併用時のデデュプリケーションに必須。GTMテンプレートでは専用フィールドで設定。

### contents配列

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `content_id` | String | 商品ID（カタログSKU IDと完全一致。大文字小文字区別） |
| `content_type` | String | `'product'` or `'product_group'` |
| `content_name` | String | 商品名 |
| `content_category` | String | カテゴリ |
| `price` | Number | 単価 |
| `quantity` | Integer | 数量 |
| `brand` | String | ブランド名 |

---

## 2. GTM構成

### 前提

- TikTok Ads Manager > Events Manager で **Pixel ID** を取得済み
- **推奨**: Events Manager > Settings > Partner Platform > Google Tag Manager からの**自動セットアップ**（Base Codeタグ + イベントタグ・トリガー・変数がGTMに自動インストールされる）
- **手動設定の場合**: Base Code（`ttq.load()` + `ttq.page()`）はCustom HTMLタグで設置し、イベント送信にはGTMコミュニティテンプレート「**TikTok Pixel**」を使用（GitHub: [tiktok/gtm-template-pixel](https://github.com/tiktok/gtm-template-pixel)。※テンプレート名はギャラリー上で変更される場合あり）

### タグ

| タグ名 | テンプレート | トリガー | 同意 |
|--------|------------|---------|------|
| TikTok Pixel - Base | Custom HTML（Base Code）or 自動設定 | All Pages | ad_storage |
| TikTok Pixel - Purchase | TikTok Pixel | CE - purchase | ad_storage |
| TikTok Pixel - Lead | TikTok Pixel | CE - generate_lead | ad_storage |
| TikTok Pixel - CompleteRegistration | TikTok Pixel | CE - sign_up | ad_storage |
| TikTok Pixel - AddToCart | TikTok Pixel | CE - add_to_cart | ad_storage |
| TikTok Pixel - ViewContent | TikTok Pixel | CE - view_item | ad_storage |
| TikTok Pixel - InitiateCheckout | TikTok Pixel | CE - begin_checkout | ad_storage |

全イベントタグに**タグシーケンス**を設定: 詳細設定 > タグの順序付け > `TikTok Pixel - Base` を先に発火。

### イベントごとのパラメータマッピング

| イベント | マッピング |
|---------|----------|
| **Purchase** | value → `{{DLV - ecommerce.value}}`、currency → `{{DLV - ecommerce.currency}}`、event_id → `{{DLV - ecommerce.transaction_id}}`、contents → `{{cjs - TikTok Pixel Contents}}` |
| **Lead** | event_id → `{{DLV - form.submission_id}}` |
| **CompleteRegistration** | status → `completed` |
| **AddToCart** | contents → `{{cjs - TikTok Pixel Contents}}` |
| **ViewContent** | contents → `{{cjs - TikTok Pixel Contents}}` |
| **InitiateCheckout** | contents → `{{cjs - TikTok Pixel Contents}}`、value → `{{DLV - ecommerce.value}}`、currency → `{{DLV - ecommerce.currency}}` |

### 変数

**定数変数**:

| 変数名 | 値 |
|--------|---|
| `TikTok Pixel ID` | （Pixel ID） |

**データレイヤー変数**:

| 変数名 | データレイヤー変数名 |
|--------|-------------------|
| `DLV - ecommerce` | `ecommerce` |
| `DLV - ecommerce.value` | `ecommerce.value` |
| `DLV - ecommerce.currency` | `ecommerce.currency` |
| `DLV - ecommerce.transaction_id` | `ecommerce.transaction_id` |
| `DLV - ecommerce.items` | `ecommerce.items` |
| `DLV - form.submission_id` | `form.submission_id` |

**カスタムJS変数**（GA4 items → TikTok Pixel contents変換）:

```javascript
// 変数名: cjs - TikTok Pixel Contents
function() {
  var ecommerce = {{DLV - ecommerce}};
  if (!ecommerce || !ecommerce.items) return [];
  return ecommerce.items.map(function(item) {
    return {
      content_id: item.item_id || '',
      content_type: 'product',
      content_name: item.item_name || '',
      content_category: item.item_category || '',
      price: item.price || 0,
      quantity: item.quantity || 1
    };
  });
}
```

### トリガー

| トリガー名 | 種類 | 条件 |
|-----------|------|------|
| All Pages | ページビュー | 全ページ |
| CE - purchase | カスタムイベント | `purchase` |
| CE - generate_lead | カスタムイベント | `generate_lead` |
| CE - sign_up | カスタムイベント | `sign_up` |
| CE - add_to_cart | カスタムイベント | `add_to_cart` |
| CE - view_item | カスタムイベント | `view_item` |
| CE - begin_checkout | カスタムイベント | `begin_checkout` |

> カスタムイベント名は**大文字小文字を区別**。dataLayerの `event` 値と完全一致させること。

---

## 3. TikTok Pixel固有の注意点

### event_idと重複排除

- 重複判定条件: **event_source_id**（Pixel ID）+ **event**（イベント名）+ **event_id** の3つが同一
- 同一ソース（Pixel同士 / Events API同士）: 最初のイベントから**48時間**以内の同一event_idを破棄（目安。公式仕様を要確認）
- Pixel↔Events API間: **5分以内**はマージ（データ結合）、**5分〜48時間**は後着を破棄
- event_idは**安定したID**を使用（注文ID等）。Events API併用時はPixelとEvents APIで**同じevent_id**を送信すること

### イベント名の移行

- **リネーム（旧名も継続サポート）**: CompletePayment→Purchase、SubmitForm→Lead（バックエンドで自動変換）
- **Soft-deprecated（2027年まで）**: ClickButton、PlaceAnOrder（要公式確認）
- **新規実装では必ず新名称を使用**

### 同意管理

TikTok独自のGoogle Consent Mode相当はない。**GTMの同意設定で制御するのが基本**:

- 全TikTokタグ（Base含む）に **`ad_storage`** を追加の同意チェックとして設定
- CMP連携で `ad_storage: granted` になるまで発火しない
- GDPR厳格オプトインでは、同意取得までBaseタグの発火をブロック（= Pixel自体を読み込まない）のが最も安全。`ttq.load()` はスクリプト取得・Cookie設定等の副作用を伴うため

TikTok Pixel APIには `holdConsent()` / `grantConsent()` / `revokeConsent()` メソッドもあるが、公式ドキュメントでの記載が限定的なため、GTMの同意設定を主たる制御手段とし、Pixel API側は補助的に利用。

### Advanced Matching（PII）

メール・電話番号でTikTokユーザーとのマッチ率を向上させる機能:

- **Automatic**: Events Managerでトグルオン。フォームフィールドを自動検出（規制産業では非推奨）
- **Manual**: `ttq.identify()` でハッシュ済PIIを送信。GTMテンプレートに専用フィールドがある場合はそこで設定

| フィールド | パラメータ名 | ハッシュ済パラメータ | フォーマット |
|-----------|------------|-------------------|------------|
| メール | `email` | `sha256_email` | 小文字化 → SHA-256 |
| 電話番号 | `phone_number` | `sha256_phone_number` | E.164形式 → SHA-256 |
| 外部ID | `external_id` | `sha256_external_id` | SHA-256 |

**推奨**: クライアントサイド送信は他タグへの流出リスクあり。可能な限り `sha256_*` パラメータで事前ハッシュ済の値を送信。**Events API経由のサーバーサイド送信を強く推奨**。

### EMQ（Event Match Quality）

- **0〜10のスコア**でコンバージョンイベントのマッチ品質を測定。**目標: 6.0以上**
- 向上策: ハッシュ済メール + 電話番号 + external_id + ttclid + _ttp + Advanced Matching有効化 + Events API併用

### カスタムイベント

標準イベント以外の任意アクションをトラッキング可能。ただし**キャンペーン最適化には標準イベントを使用**すること（カスタムイベントは主にレポーティング用途）。

### SPA環境

- TikTok PixelがSPA内のURL変遷を自動検出するかは**環境により異なる**（フレームワーク・ルーティング方式に依存。実環境で要テスト）
- 自動検出が動作しない場合、ルート変更時のイベント（ViewContent等）はHistory Changeトリガー等で別途発火設計が必要
- **二重発火に注意**: 自動検出と手動呼び出しが重複しないこと

### カタログ / DPA要件

ViewContent, AddToCart, Purchase の**3イベント必須**。全イベントで `content_id`（カタログSKU IDと完全一致。大文字小文字区別）+ `content_type` 必須。Purchaseは `value` + `currency` も必須。`contents` 配列に加え、トップレベルの `content_ids` / `content_type` も併記するとショッピング広告（Video Shopping Ads等）との互換性が向上。Pixel Upload機能でカタログが自動更新（約15分以内）。

---

## 4. Events API

TikTok推奨のハイブリッド運用: Pixel（クライアント）+ Events API（サーバー）を併用し、`event_id` で重複排除。

> **運用方針**: Pixelで送信する全コンバージョンイベント（Purchase, Lead等）をEvents APIでも送信するのが理想。最低限Purchaseは両方から送信し、`event_id` で重複排除すること。どのイベントをEvents APIでも送るかは事前に決定しておく。

### 必要な識別子（最低1つ）

| 識別子 | マッチ精度 | 説明 |
|--------|-----------|------|
| ttclid | 最高 | TikTok Click ID。URLパラメータから取得（30日間有効） |
| _ttp | 高 | TikTok Pixelが設定するファーストパーティCookie |
| メールアドレス（SHA256） | 高 | 小文字化後にハッシュ |
| 電話番号（SHA256、E.164） | 高 | E.164形式後にハッシュ |
| external_id（SHA256） | 中 | 広告主のユーザーID |
| IP + User Agent | 低 | フォールバック（最低優先度） |

**ttclid / _ttp連携**: Pixelは `?ttclid=XXX` をURLパラメータから自動取得し、`_ttp` cookieを設定する。Events API側ではランディング時にサーバーサイドで `ttclid` と `_ttp` を保存し、コンバージョン時に `user.ttclid` / `user.ttp` として送信。

### Events APIパラメータ

| パラメータ | パス | 必須 | 説明 |
|---|---|---|---|
| `event_source` | トップレベル | 必須 | `'web'`（ウェブサイトの場合） |
| `event_source_id` | トップレベル | 必須 | Pixel ID |
| `event` | data[] | 必須 | イベント名（Pixelと同一名称） |
| `event_time` | data[] | 必須 | UNIXタイムスタンプ（秒） |
| `event_id` | data[] | Pixel併用時は必須 | 重複排除用ID（Pixelと同一値） |
| `user.ttclid` | data[].user | 推奨 | TikTok Click ID |
| `user.ttp` | data[].user | 推奨 | `_ttp` cookieの値 |
| `user.email` | data[].user | 推奨 | SHA-256ハッシュ済メール |
| `user.phone` | data[].user | 推奨 | SHA-256ハッシュ済電話番号（E.164） |
| `user.external_id` | data[].user | 任意 | SHA-256ハッシュ済ユーザーID |
| `user.ip` | data[].user | 推奨 | IPv4/IPv6 |
| `user.user_agent` | data[].user | 推奨 | ブラウザUA文字列 |
| `properties.value` | data[].properties | 任意 | コンバージョン金額 |
| `properties.currency` | data[].properties | 任意 | ISO 4217通貨コード |
| `properties.contents` | data[].properties | 任意 | 商品詳細配列（Pixelと同構造） |
| `test_event_code` | トップレベル | テスト時 | テスト用コード（本番レポートに影響しない） |

**エンドポイント**: `POST https://business-api.tiktok.com/open_api/v1.3/event/track/`
**認証**: `Access-Token` ヘッダー（Events Managerで生成。Admin/Operator権限が必要）

### sGTM

- 認証: **Access Token**（Events Managerで生成）
- テンプレート: [tiktok/gtm-template-eapi](https://github.com/tiktok/gtm-template-eapi)（GA4標準イベントを自動認識しTikTokイベントに変換）
- テスト: `test_event_code` をリクエストに追加で検証可能（本番レポートに影響しない）
- バッチ制限（目安。要公式確認）: 最大50件/バッチ、最古から5分以内、1MB以下

---

## 5. デバッグ

| ツール | 確認内容 |
|--------|---------|
| **GTMプレビューモード** | タグ発火順序（Base→Event）、変数の値 |
| **TikTok Pixel Helper**（Chrome拡張） | ピクセル検出、パラメータ、エラー（緑/黄/赤インジケーター）。Events APIは検証不可 |
| **Test Events**（Events Manager） | リアルタイムイベント受信確認（QRコード経由）。Events APIは `test_event_code` で検証 |
| **Web Diagnostics**（Events Manager） | Errors（重大）/ Warnings（品質影響）/ Suggestions（最適化推奨） |
| **DevTools Network** | `analytics.tiktok.com` 等へのリクエスト確認 |
| **EMQスコア**（Events Manager） | マッチ品質スコア確認（目標: 6.0以上） |

---

## 6. 参考リンク

- [TikTok Pixel](https://ads.tiktok.com/help/article/tiktok-pixel)
- [Standard Events & Parameters](https://ads.tiktok.com/help/article/standard-events-parameters)
- [Custom Events](https://ads.tiktok.com/help/article/custom-events)
- [Advanced Matching for Web](https://ads.tiktok.com/help/article/advanced-matching-web)
- [Events API](https://ads.tiktok.com/help/article/events-api)
- [Event Deduplication](https://ads.tiktok.com/help/article/event-deduplication)
- [GTM Setup](https://ads.tiktok.com/help/article/get-started-google-tag-manager)
- [GTM Pixel Template (GitHub)](https://github.com/tiktok/gtm-template-pixel)
- [GTM Events API Template (GitHub)](https://github.com/tiktok/gtm-template-eapi)
- [TikTok Pixel Helper](https://ads.tiktok.com/help/article/tiktok-pixel-helper-2.0)
- [Web Diagnostics](https://ads.tiktok.com/help/article/web-diagnostics)
- [Value-Based Optimization (Web)](https://ads.tiktok.com/help/article/value-based-optimization-web)
- [Catalog Event Match Rates](https://ads.tiktok.com/help/article/best-practices-for-increasing-catalog-event-match-rates)
- [Using Cookies with TikTok Pixel](https://ads.tiktok.com/help/article/using-cookies-with-tiktok-pixel)
