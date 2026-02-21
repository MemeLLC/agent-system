# X Pixel - GTM実装マニュアル

> 最新仕様は [Conversion Tracking for Websites](https://business.x.com/en/help/campaign-measurement-and-analytics/conversion-tracking-for-websites) で要確認。

---

## 1. イベント・パラメータリファレンス

### 標準イベント

| イベント名 | 用途例 |
|-----------|-------|
| **Page View** | 全ページ（Base Code設置で訪問計測。コンバージョンとして使う場合はEvents Managerでイベント作成が必要） |
| **Purchase** | 購入完了 |
| **Lead** | 問い合わせ完了、資料請求 |
| **Sign Up** | アカウント作成完了（※Events Managerで利用可能か要確認。ない場合は Lead / Subscribe 等で代替） |
| **Add to Cart** | カート追加 |
| **Add to Wishlist** | お気に入り登録 |
| **Checkout Initiated** | 決済ページ遷移 |
| **Content View** | 商品詳細ページ |
| **Added Payment Info** | 決済情報入力完了 |
| **Search** | サイト内検索 |
| **Subscribe** | 定期購読・メルマガ登録 |
| **Start Trial** | 無料体験申込 |
| **Download** | ファイル・アプリDL |
| **Product Customization** | 商品オプション選択 |
| **Custom** | 上記に当てはまらないアクション |

### イベントパラメータ

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `value` | Number | コンバージョン金額 |
| `currency` | String | ISO 4217通貨コード（`'JPY'`等） |
| `conversion_id` | String | 重複排除用の一意ID（注文ID等） |
| `search_string` | String | サイト内検索クエリ |
| `description` | String | イベントの追加説明 |
| `status` | String | `'started'` or `'completed'` |
| `contents` | Array | 商品詳細の配列（下表参照） |
| `num_items` | Number | 商品の合計数量（contents内の `num_items` とは別。トップレベル = 全体合計） |
| `email_address` | String | メールアドレス（X側でSHA256化。**CAPI送信推奨**） |
| `phone_number` | String | 電話番号（E.164形式。**CAPI送信推奨**） |
| `restricted_data_use` | String | `'restrict_optimization'` or `'off'` |

### contents配列

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `content_type` | String | 商品カテゴリ（Google分類準拠） |
| `content_id` | String | SKU or GTIN |
| `content_name` | String | 商品名 |
| `content_price` | Number | 単価 |
| `num_items` | Number | 数量 |
| `content_group_id` | String | バリアントのグループID |

---

## 2. GTM構成

### 前提

- X Ads Events Managerで **Pixel ID** と各 **Event ID**（`tw-XXXXX-YYYYY`形式）を取得済み
- GTMコミュニティテンプレート「**Twitter Base Pixel**」「**Twitter Event Pixel**」を使用（※テンプレ名はギャラリー上で変更される場合あり。最新名称を確認のこと）

### タグ

| タグ名 | テンプレート | トリガー | 同意 |
|--------|------------|---------|------|
| X Pixel - Base | Twitter Base Pixel | All Pages | ad_storage |
| X Pixel - Purchase | Twitter Event Pixel | CE - purchase | ad_storage |
| X Pixel - Lead | Twitter Event Pixel | CE - generate_lead | ad_storage |
| X Pixel - SignUp | Twitter Event Pixel | CE - sign_up | ad_storage |
| X Pixel - Add to Cart | Twitter Event Pixel | CE - add_to_cart | ad_storage |
| X Pixel - Content View | Twitter Event Pixel | CE - view_item | ad_storage |

全イベントタグに**タグシーケンス**を設定: 詳細設定 > タグの順序付け > `X Pixel - Base` を先に発火。

### イベントごとのパラメータマッピング

| イベント | マッピング |
|---------|----------|
| **Purchase** | value → `{{DLV - ecommerce.value}}`、currency → `{{DLV - ecommerce.currency}}`、conversion_id → `{{DLV - ecommerce.transaction_id}}`、contents → `{{cjs - X Pixel Contents}}` |
| **Lead** | conversion_id → `{{DLV - form.submission_id}}` |
| **SignUp** | status → `completed` |
| **Add to Cart** | contents → `{{cjs - X Pixel Contents}}` |
| **Content View** | contents → `{{cjs - X Pixel Contents}}` |

### 変数

**定数変数**（Pixel ID・Event IDを一元管理）:

| 変数名 | 値 |
|--------|---|
| `X Pixel ID` | （Pixel ID） |
| `X Event ID - Purchase` | （Event ID） |
| `X Event ID - Lead` | （Event ID） |
| `X Event ID - SignUp` | （Event ID） |
| `X Event ID - AddToCart` | （Event ID） |
| `X Event ID - ContentView` | （Event ID） |

**データレイヤー変数**:

| 変数名 | データレイヤー変数名 |
|--------|-------------------|
| `DLV - ecommerce` | `ecommerce` |
| `DLV - ecommerce.value` | `ecommerce.value` |
| `DLV - ecommerce.currency` | `ecommerce.currency` |
| `DLV - ecommerce.transaction_id` | `ecommerce.transaction_id` |
| `DLV - ecommerce.items` | `ecommerce.items` |
| `DLV - form.submission_id` | `form.submission_id` |

**カスタムJS変数**（GA4 items → X Pixel contents変換）:

```javascript
// 変数名: cjs - X Pixel Contents
function() {
  var ecommerce = {{DLV - ecommerce}};
  if (!ecommerce || !ecommerce.items) return [];
  return ecommerce.items.map(function(item) {
    return {
      content_id: item.item_id || '',
      content_name: item.item_name || '',
      content_price: item.price || 0,
      num_items: item.quantity || 1,
      content_type: item.item_category || 'product'
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

> カスタムイベント名は**大文字小文字を区別**。dataLayerの `event` 値と完全一致させること。

---

## 3. X Pixel固有の注意点

### conversion_id と重複排除

- **安定したID**を使用（注文ID等）。`Date.now()` やランダム値は不可
- Page View系のみX側で自動重複排除（目安: 約30分間。公式仕様を要確認）。**他イベント（Purchase / Lead等）はX側での自動重複排除なし**
- `conversion_id` の主な役割は **Pixel↔CAPI間の重複排除**。併用時は両方で**同じ `conversion_id`** を送信すること

### 購入前イベントのパラメータ制限

Add to Cart・Checkout Initiated等には `value` / `currency` / `conversion_id` を**マッピングしない**（意図しない収益帰属を防ぐ）。`contents` のみ送信。

### 同意管理

X Pixel独自のConsent Modeはない。GTMの同意設定で制御:
- 全X Pixelタグに **`ad_storage`** を追加の同意チェックとして設定
- CMP連携で `ad_storage: granted` になるまで発火しない

### PII（メール・電話番号）

クライアントサイド送信はdataLayer経由で他タグにも流出リスクあり。**CAPI経由のサーバーサイド送信を強く推奨**。

### SPA環境

- Base Codeは初回ロード時に**1回だけ**実行。ルーティング変更ごとに再実行しない
- ルート変更時のイベント（Content View等）は、History Changeトリガー等で別途発火設計が必要

---

## 4. Conversion API（CAPI）

X推奨のハイブリッド運用: Pixel（クライアント）+ CAPI（サーバー）を併用し、`conversion_id` で重複排除。

### CAPIの必要な識別子（最低1つ）

| 識別子 | マッチ精度 |
|--------|-----------|
| Click ID（twclid） | 最高 |
| メールアドレス（SHA256） | 高 |
| 電話番号（SHA256、E.164） | 高 |

**twclid連携**: Pixelは `?twclid=XXX` をURLや1st party cookieから自動取得する。CAPI側ではランディング時にサーバーサイドで保存し、コンバージョン時に送信。

### CAPIパラメータ

| パラメータ | 必須 | 説明 |
|---|---|---|
| `conversion_time` | 必須 | ISO 8601タイムスタンプ |
| `event_id` | 必須 | Events ManagerのイベントID |
| `conversion_id` | Pixel併用時は必須 | 重複排除用ID |
| `identifiers` | 必須（最低1つ） | twclid / hashed_email / hashed_phone_number |
| `value` / `price_currency` / `contents` | 任意 | Pixelと同概念だがフィールド名が異なる場合あり。[APIリファレンス](https://developer.x.com/en/docs/x-ads-api/measurement/web-conversions/conversion-api)準拠 |

### sGTM

- 認証: **OAuth 1.0a**（Consumer Key/Secret + OAuth Token/Secret）→ X Developer Portalで取得
- X Developer Account必要。CAPI申請にX営業承認が必要な場合あり
- **リアルタイムテスト不可**（反映確認に12〜24時間）
- 実装: Stapeカスタムタグ（容易）or 自前ホスティング（完全コントロール）

---

## 5. デバッグ

| ツール | 確認内容 |
|--------|---------|
| **GTMプレビューモード** | タグ発火順序（Base→Event）、変数の値 |
| **X Pixel Helper**（Chrome拡張） | ピクセル検出、パラメータ、エラー |
| **DevTools Network** | X関連ドメイン（`ads-twitter.com` 等）へのリクエスト |
| **Events Manager** | ステータス確認（※反映まで最大24時間） |

---

## 6. 参考リンク

- [X Business - Conversion Tracking](https://business.x.com/en/help/campaign-measurement-and-analytics/conversion-tracking-for-websites)
- [X Business - Pixel Helper](https://business.x.com/en/help/campaign-measurement-and-analytics/pixel-helper)
- [X Business - Restricted Data Use](https://business.x.com/en/help/campaign-measurement-and-analytics/conversion-tracking-for-websites/restricted-data-use-guide)
- [X Developer - Conversion API](https://developer.x.com/en/docs/x-ads-api/measurement/web-conversions/conversion-api)
- [X Pixel Helper - Chrome Web Store](https://chromewebstore.google.com/detail/x-pixel-helper/jepminnlebllinfmkhfbkpckogoiefpd)

### DPA利用時の追加要件

Page View / Content View / Add to Cart / Purchase の4イベント必須。全イベントで `contents` 必須、Purchaseは `value` / `currency` も必須。Email送信も推奨（要確認）。**物理商品のみ**対応。
