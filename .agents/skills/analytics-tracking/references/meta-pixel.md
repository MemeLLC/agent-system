# Meta Pixel - GTM実装マニュアル

> 最新仕様は [Meta Pixel Reference](https://developers.facebook.com/docs/meta-pixel/reference) および [Events Manager](https://business.facebook.com/events_manager) で要確認。

---

## 1. イベント・パラメータリファレンス

### 標準イベント

| # | イベント名 | 用途例 | 必須パラメータ |
|---|-----------|-------|-------------|
| 1 | **PageView** | 全ページ（テンプレートでBaseタグとして全ページ発火） | なし |
| 2 | **ViewContent** | 商品詳細、コンテンツ閲覧 | 推奨: `content_ids`, `value`, `currency` |
| 3 | **Search** | サイト内検索 | 推奨: `search_string` |
| 4 | **AddToCart** | カート追加 | 推奨: `content_ids`, `value`, `currency` |
| 5 | **AddToWishlist** | ウィッシュリスト追加 | なし |
| 6 | **InitiateCheckout** | チェックアウト開始 | 推奨: `value`, `currency`, `num_items` |
| 7 | **AddPaymentInfo** | 支払い情報入力完了 | なし |
| 8 | **Purchase** | 購入完了 | **`value`（必須）、`currency`（必須）**（最適化・ROAS計測・DPAのため。欠落するとイベントが最適化に活用されない） |
| 9 | **Lead** | リード獲得 | 推奨: `value`, `currency` |
| 10 | **CompleteRegistration** | 登録完了 | なし |
| 11 | **Contact** | 問い合わせ | なし |
| 12 | **CustomizeProduct** | 商品カスタマイズ | なし |
| 13 | **Donate** | 寄付 | なし |
| 14 | **FindLocation** | 店舗検索 | なし |
| 15 | **Schedule** | 予約 | なし |
| 16 | **StartTrial** | 無料トライアル開始 | 推奨: `value`, `currency` |
| 17 | **SubmitApplication** | 申請送信 | なし |
| 18 | **Subscribe** | 有料サブスクリプション開始 | 推奨: `value`, `currency` |

> イベント数はMetaの更新により変動する可能性あり。最新は [Meta Pixel Reference](https://developers.facebook.com/docs/meta-pixel/reference) を正として採用。

### イベントパラメータ

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `value` | Float | 金額（**数値型で送信。文字列型は不可**。`currency` と常にセット） |
| `currency` | String | ISO 4217通貨コード（`'JPY'`等） |
| `content_name` | String | 商品名・コンテンツ名 |
| `content_category` | String | カテゴリ |
| `content_ids` | Array[String] | 商品ID配列（商品カタログIDと一致させる。DPA必須） |
| `content_type` | String | `'product'`（SKU単位）or `'product_group'`（バリエーション含むグループ） |
| `contents` | Array[Object] | 商品詳細オブジェクト配列（下表参照） |
| `num_items` | Integer | アイテム数 |
| `predicted_ltv` | Float | 予測LTV（Subscribe, StartTrialで活用） |
| `search_string` | String | 検索キーワード（Searchイベントで使用） |
| `status` | Boolean | 登録ステータス等（`true` / `false`） |

> **eventID**: イベントパラメータ（第3引数）ではなく**オプションオブジェクト（第4引数）**で指定する一意識別子: `fbq('track', 'Purchase', {params}, {eventID: '...'})` 。CAPI併用時の重複排除に必須。GTMテンプレートでは「Event ID」フィールドで設定。

### contents配列

| パラメータ | 型 | 説明 |
|-----------|------|------|
| `id` | String | 商品ID（カタログIDと一致。DPA必須） |
| `quantity` | Integer | 数量 |
| `item_price` | Float | 単価 |

---

## 2. GTM構成

### 前提

- Meta Events Manager で **Pixel ID** を取得済み
- GTMコミュニティテンプレート「**Facebook Pixel**」を使用（メンテナ: facebookarchive / Simo Ahava。※テンプレート名はギャラリー上で変更される場合あり）
- 別テンプレート「**Facebook Pixel by Stape**」もあり（DataLayer自動連携・Enhanced Ecommerce自動マッピング機能を搭載）
- テンプレートが `fbevents.js` の読み込みと初期化（`fbq('init', ...)`）を内部で処理するため、**カスタムHTMLでのBase Code設置は不要**

### テンプレートの主要設定オプション

| 設定項目 | 説明 |
|---|---|
| **Pixel ID** | Meta Pixel ID（複数カンマ区切り可） |
| **Event Name** | 標準イベント名 or カスタムイベント名（変数も使用可） |
| **Object Properties** | イベントパラメータ（テーブル or JS変数） |
| **Event ID** | 重複排除用の一意識別子（CAPI連携時に必須） |
| **Advanced Matching** | ユーザー情報（メール、電話等）の送信を有効化 |
| **Consent Granted** | `false` 時はSDKロードのみ・データ送信停止（Meta Consent Mode連携） |
| **Enhanced Ecommerce** | DataLayerのecommerceオブジェクトを自動マッピング（UA形式対応。GA4 `items` 形式はテンプレートの対応状況を確認） |
| **Disable Automatic Configuration** | ボタンクリック・メタデータの自動収集を無効化 |

### タグ

| タグ名 | テンプレート | トリガー | 同意 |
|--------|------------|---------|------|
| Meta Pixel - PageView | Facebook Pixel | All Pages | ad_storage |
| Meta Pixel - Purchase | Facebook Pixel | CE - purchase | ad_storage |
| Meta Pixel - Lead | Facebook Pixel | CE - generate_lead | ad_storage |
| Meta Pixel - CompleteRegistration | Facebook Pixel | CE - sign_up | ad_storage |
| Meta Pixel - AddToCart | Facebook Pixel | CE - add_to_cart | ad_storage |
| Meta Pixel - ViewContent | Facebook Pixel | CE - view_item | ad_storage |
| Meta Pixel - InitiateCheckout | Facebook Pixel | CE - begin_checkout | ad_storage |

全イベントタグに**タグシーケンス**を設定: 詳細設定 > タグの順序付け > `Meta Pixel - PageView` を先に発火。テンプレートが内部で初期化を処理するためSequencingは保険的な位置づけだが、確実なPixel初期化のために設定を推奨。SPAではHistory Changeトリガーで別途設計。

### イベントごとのパラメータマッピング

| イベント | マッピング |
|---------|----------|
| **Purchase** | value → `{{DLV - ecommerce.value}}`、currency → `{{DLV - ecommerce.currency}}`、Event ID → `{{DLV - ecommerce.transaction_id}}`、content_ids → `{{cjs - Meta Pixel Content IDs}}`、content_type → `product`、contents → `{{cjs - Meta Pixel Contents}}` |
| **Lead** | Event ID → `{{DLV - form.submission_id}}` |
| **CompleteRegistration** | status → `true` |
| **AddToCart** | content_ids → `{{cjs - Meta Pixel Content IDs}}`、content_type → `product`、contents → `{{cjs - Meta Pixel Contents}}` |
| **ViewContent** | content_ids → `{{cjs - Meta Pixel Content IDs}}`、content_type → `product`、contents → `{{cjs - Meta Pixel Contents}}` |
| **InitiateCheckout** | content_ids → `{{cjs - Meta Pixel Content IDs}}`、content_type → `product`、contents → `{{cjs - Meta Pixel Contents}}`、value → `{{DLV - ecommerce.value}}`、currency → `{{DLV - ecommerce.currency}}` |

### 変数

**定数変数**:

| 変数名 | 値 |
|--------|---|
| `Meta Pixel ID` | （Pixel ID） |

**データレイヤー変数**:

| 変数名 | データレイヤー変数名 |
|--------|-------------------|
| `DLV - ecommerce` | `ecommerce` |
| `DLV - ecommerce.value` | `ecommerce.value` |
| `DLV - ecommerce.currency` | `ecommerce.currency` |
| `DLV - ecommerce.transaction_id` | `ecommerce.transaction_id` |
| `DLV - ecommerce.items` | `ecommerce.items` |
| `DLV - form.submission_id` | `form.submission_id` |

**カスタムJS変数**（GA4 items → Meta Pixel変換）:

```javascript
// 変数名: cjs - Meta Pixel Contents
function() {
  var ecommerce = {{DLV - ecommerce}};
  if (!ecommerce || !ecommerce.items) return [];
  return ecommerce.items.map(function(item) {
    return {
      id: item.item_id || '',
      quantity: item.quantity || 1,
      item_price: Number(item.price || 0)
    };
  }).filter(function(x) { return x.id; });
}
```

```javascript
// 変数名: cjs - Meta Pixel Content IDs
function() {
  var ecommerce = {{DLV - ecommerce}};
  if (!ecommerce || !ecommerce.items) return [];
  return ecommerce.items.map(function(item) {
    return item.item_id || '';
  }).filter(Boolean);
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

## 3. Meta Pixel固有の注意点

### eventIDと重複排除

- 重複判定条件: **event_name** + **eventID** の一致（時間窓: 目安として最大**48時間**。公式ヘルプの記載に基づく。ただし送信遅延が大きいと結合/除外の挙動が崩れるため、Pixel・CAPI間はできるだけ近いタイミングで送信）
- eventIDは**安定したID**を使用（注文ID等）。CAPI併用時はPixelとCAPIで**同じ値**を送信
- **命名の違いに注意**:

| レイヤー | フィールド名 | 形式 |
|---|---|---|
| Pixel（ブラウザ） | `eventID` | camelCase。`fbq('track', ..., {eventID: '...'})` のオプション引数 |
| CAPI（サーバー） | `event_id` | snake_case。APIリクエストのJSONフィールド |
| DataLayer（GTM） | 任意（例: `meta_event_id`） | GTM変数で取得し、Pixel・CAPIの両タグに渡す |

3つのレイヤーで**値は同一**にすること。名前が異なるだけ。

### AEM（Aggregated Event Measurement）

iOS 14.5+のATT対応プロトコル。仕様変更が入っており（旧8イベント制限の撤廃、AEMタブ削除、ドメイン検証要件の変更等）、**Events Managerの現行UIを一次情報として確認**すること:

- AEMタブの有無
- イベント優先順位設定の要否
- ドメイン検証の要否

旧仕様が適用されているアカウントでは、8イベントの優先順位設定とドメイン検証が引き続き必要な場合がある。

### ドメイン認証

- Business Manager > ビジネス設定 > ブランドセーフティ > ドメイン で設定
- **DNS TXTレコード**（推奨。サイトリニューアルに影響されない）or **HTMLメタタグ**（`<meta name="facebook-domain-verification" content="..." />`）
- AEMのためのドメイン検証は2025年中期以降不要になったとの情報あり（上記参照）。ただしリンク所有権の証明・不正利用防止の目的では引き続き推奨

### 同意管理

- **GTMの同意設定が基本**: 全Meta Pixelタグに `ad_storage` を追加の同意チェックとして設定。CMP連携で `ad_storage: granted` になるまで発火しない
- **Meta Consent Mode**: CMPと連携してユーザーの同意選択を自動反映。Granted = フルデータ収集、Denied = プライバシー保護型の集約インサイトを推定。テンプレートの「Consent Granted」設定で制御
- GDPR厳格オプトインでは同意取得まで `fbevents.js` 自体を読み込まない設計が最も安全

### Advanced Matching（詳細マッチング）

メール・電話番号等でMetaユーザーとのマッチ率を向上させる機能:

- **Automatic（自動）**: Events Managerでトグルオン。フォームフィールドから自動検出・ハッシュ化送信
- **Manual（手動）**: `fbq('init', PIXEL_ID, {em, ph, ...})` で明示送信。Pixelが自動SHA-256ハッシュ化。GTMテンプレートのAdvanced Matchingセクションで設定
- **推奨**: 自動+手動の併用で最大EMQを実現

| パラメータ | 説明 | フォーマット |
|---|---|---|
| `em` | メールアドレス | 小文字 |
| `ph` | 電話番号 | 国番号+番号（数字のみ） |
| `fn` | 名 | 小文字 |
| `ln` | 姓 | 小文字 |
| `ge` | 性別 | `f` or `m` |
| `db` | 生年月日 | `YYYYMMDD` |
| `ct` | 市区町村 | 小文字、スペースなし |
| `st` | 都道府県/州 | 2文字コード、小文字 |
| `zp` | 郵便番号 | ハイフンなし |
| `country` | 国 | ISO 3166-1 alpha-2（`jp`, `us`） |
| `external_id` | 外部顧客ID | 自社システムの識別子 |

> DataLayerに生PII（平文のメール・電話番号）を含める場合、Cookie同意取得後にのみDataLayerに投入すること（他タグ経由の漏洩リスクあり）。**CAPI経由のサーバーサイド送信を強く推奨**。

### EMQ（Event Match Quality）

- **0〜10のスコア**（Events Manager > 各イベント横に表示。48時間ごと更新）
- **目標: 全主要イベントでスコア8以上**
- 向上策の優先度:

| 優先度 | データ |
|---|---|
| 最高 | メール（`em`） |
| 高 | 電話番号（`ph`）、`fbp`（`_fbp` Cookie値）、`fbc`（`_fbc` Cookie値）、`external_id` |
| 中 | 名（`fn`）、姓（`ln`）、市区町村（`ct`） |
| 低 | 国（`country`）、生年月日（`db`）、性別（`ge`） |

### カスタムイベント・カスタムコンバージョン

- **カスタムイベント**: `fbq('trackCustom', 'EventName', {...})`。**標準イベントで代替可能な場合は標準イベントを優先**（Metaのグローバルデータによる最適化恩恵）。命名はPascalCase推奨
- **カスタムコンバージョン**: Events Manager上でルールベースの定義（URLパターン or イベント+フィルタ条件）。コード変更不要。1アカウント最大100件

### SPA環境

- `fbevents.js` は初回ロードで1回だけ読み込み。ルーティング変更ごとに再読み込みしない
- ルート変更時のイベント（ViewContent等）はHistory Changeトリガー等で別途発火設計が必要
- SPAで `PageView` をルート変更ごとに送る場合は、History Changeトリガーで追加のPageViewタグを発火

### ダイナミック広告（DPA）/ カタログ要件

**ViewContent, AddToCart, Purchase の3イベント必須**。全イベントで:

- `content_ids`（商品カタログIDと完全一致）+ `content_type`（`'product'` or `'product_group'`）必須
- Purchaseは `value` + `currency` も必須
- `contents` 配列で商品詳細（`id`, `quantity`, `item_price`）も送信推奨

### Cookie

| Cookie名 | 有効期限 | 用途 |
|-----------|---------|------|
| `_fbp` | 約3ヶ月 | ウェブサイト訪問者のユニーク識別子（ファーストパーティ） |
| `_fbc` | 約3ヶ月 | Facebook広告クリックID（`fbclid`）を含み、CVを広告に紐付け |

ファーストパーティCookieのため、サードパーティCookie制限環境でも動作。CAPI併用時は `_fbp` / `_fbc` の値もサーバーに送信してマッチ精度を向上。

---

## 4. Conversions API（CAPI）

Meta推奨のハイブリッド運用: Pixel（クライアント）+ CAPI（サーバー）を併用し、`eventID` / `event_id` で重複排除。

> **運用方針**: Pixelで送信する全コンバージョンイベント（Purchase, Lead等）をCAPIでも送信するのが理想。最低限Purchaseは両方から送信し、eventIDで重複排除すること。どのイベントをCAPIでも送るかは事前に決定しておく。

### 必要な識別子

| 識別子 | 優先度 | ハッシュ | 説明 |
|--------|-------|--------|------|
| `fbc`（_fbc Cookie値） | 最高 | 不要 | Facebook Click ID（fbclidをCookie化したもの） |
| `fbp`（_fbp Cookie値） | 高 | 不要 | ブラウザ識別子 |
| メールアドレス（`em`） | 高 | SHA-256必要 | 小文字化後にハッシュ |
| 電話番号（`ph`） | 高 | SHA-256必要 | 国番号付き・数字のみでハッシュ |
| `external_id` | 中 | SHA-256推奨 | 広告主のユーザーID |
| `client_ip_address` + `client_user_agent` | 低 | 不要 | フォールバック（送信推奨） |

### CAPIパラメータ

| パラメータ | 必須 | 説明 |
|---|---|---|
| `event_name` | 必須 | イベント名（Pixelと同一名称。**大文字小文字を厳密に一致**） |
| `event_time` | 必須 | UNIXタイムスタンプ（秒単位） |
| `event_id` | Pixel併用時は必須 | 重複排除用ID（Pixelの `eventID` と同一値） |
| `event_source_url` | 推奨 | コンバージョン発生ページURL |
| `action_source` | 必須 | `'website'`（ウェブサイトの場合） |
| `user_data.em` | 推奨 | SHA-256ハッシュ済メール（配列） |
| `user_data.ph` | 推奨 | SHA-256ハッシュ済電話番号（配列） |
| `user_data.fbc` | 推奨 | `_fbc` Cookie値（ハッシュ不要） |
| `user_data.fbp` | 推奨 | `_fbp` Cookie値（ハッシュ不要） |
| `user_data.client_ip_address` | 推奨 | IPアドレス（ハッシュ不要） |
| `user_data.client_user_agent` | 推奨 | UA文字列（ハッシュ不要） |
| `user_data.external_id` | 任意 | SHA-256ハッシュ済ユーザーID（配列） |
| `custom_data.value` | 任意 | コンバージョン金額 |
| `custom_data.currency` | 任意 | ISO 4217通貨コード |
| `custom_data.content_ids` | 任意 | 商品ID配列 |
| `custom_data.content_type` | 任意 | `'product'` or `'product_group'` |
| `custom_data.contents` | 任意 | 商品詳細配列（Pixelと同構造） |
| `custom_data.num_items` | 任意 | アイテム数 |

**エンドポイント**: `POST https://graph.facebook.com/v{API_VERSION}/{PIXEL_ID}/events`
**認証**: `access_token` パラメータ（Events Managerで生成）

### sGTM

- テンプレート: コミュニティギャラリーの「**Facebook Conversions API**」タグ
- GA4またはData Clientでクライアント→サーバーへデータ転送し、CAPIタグでMetaへ送信
- Pixel ID + APIアクセストークンを設定し、イベントマッピング + ユーザーデータ + カスタムデータフィールドを設定
- ホスティング: **Stape.io**（推奨。デプロイ容易、テンプレートベース）or **Google Cloud Run**（カスタマイズ重視）

### 重複排除の検証

- **カバレッジ目標**: Pixelイベントに対するCAPIイベントのカバレッジ比率**75%以上**を目安（購入など主要CVから段階的に拡大）
- **安定化期間**: CAPIセットアップ後、最低24時間以上経過してからEMQの安定を確認
- Events Managerの「重複排除」メトリクスを定期的に監視

---

## 5. デバッグ

| ツール | 確認内容 |
|--------|---------|
| **GTMプレビューモード** | タグ発火順序（PageView→Event）、変数の値 |
| **Meta Pixel Helper**（Chrome拡張） | ピクセル検出、イベント・パラメータ、エラー。CAPIは検証不可 |
| **テストイベント**（Events Manager） | リアルタイムイベント受信確認（Pixel + CAPI両方） |
| **診断**（Events Manager） | パラメータ欠落、設定問題の警告、推奨アクション |
| **DevTools Network** | `facebook.com/tr` へのリクエスト確認 |
| **EMQスコア**（Events Manager） | マッチ品質スコア（目標: 8以上。48時間ごと更新） |

---

## 6. 参考リンク

- [Meta Pixel - 公式リファレンス](https://developers.facebook.com/docs/meta-pixel/)
- [Standard Events Reference](https://developers.facebook.com/docs/meta-pixel/reference)
- [Conversions API](https://developers.facebook.com/docs/marketing-api/conversions-api)
- [Advanced Matching](https://developers.facebook.com/docs/meta-pixel/advanced/advanced-matching)
- [Event Deduplication](https://developers.facebook.com/docs/marketing-api/conversions-api/deduplicate-pixel-and-server-events)
- [GDPR / Consent Implementation](https://developers.facebook.com/docs/meta-pixel/implementation/gdpr)
- [Domain Verification](https://developers.facebook.com/docs/sharing/domain-verification)
- [Meta Pixel Helper - Chrome Web Store](https://chromewebstore.google.com/detail/meta-pixel-helper/fdgfkebogiimcoedlicjlajpkdmockpc)
- [Events Manager](https://business.facebook.com/events_manager)
