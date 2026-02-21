# GTM（Google Tag Manager）設定マニュアル

> **目的:** AIがユーザーと協力してGTMコンテナを設計し、インポート可能なJSONファイルを出力するためのガイドライン。
> JSON仕様はGTMのコンテナエクスポート/インポート形式（`exportFormatVersion: 2`）に基づき、[Tag Manager API v2](https://developers.google.com/tag-platform/tag-manager/api/v2/devguide) の ContainerVersion モデルに準拠して記述。

---

## 1. 前提確認

### 1.1 ユーザーから収集する情報

| # | 項目 | 例 | 必須 |
|---|------|-----|------|
| 1 | GTMアカウントID | `123456` | ✅ |
| 2 | GTMコンテナID | `789012` | ✅ |
| 3 | コンテナ公開ID | `GTM-XXXXXXX` | ✅ |
| 4 | サイトドメイン | `example.com` | ✅ |
| 5 | GA4測定ID | `G-XXXXXXXXXX` | GA4使用時 |
| 6 | Google Ads コンバージョンID | `AW-XXXXXXXXX` | Google Ads使用時 |
| 7 | Meta Pixel ID | `123456789012345` | Meta使用時 |
| 8 | TikTok Pixel ID | `XXXXXXXXXX` | TikTok使用時 |
| 9 | X Pixel ID | `XXXXX` | X使用時 |
| 10 | Clarity Project ID | `xxxxxxxxxx` | Clarity使用時 |
| 11 | 使用プラットフォーム一覧 | GA4, Meta, Clarity | ✅ |
| 12 | 計測するコンバージョン | 購入、リード獲得 | ✅ |
| 13 | EC / 非EC | EC | サイト種別の判断用 |
| 14 | SPA / MPA | MPA | page_view制御の判断用 |

### 1.2 基本原則

- 計測ベンダーのタグはGTMダッシュボードで管理。HTMLに設置するのは**GTMスニペット1つだけ**
- 計測要件のための `dataLayer.push` はアプリケーション側のソースコードに実装する
- **PII送信禁止:** メール、電話番号、氏名等をGA4やその他の計測ツールに送信しない。`tel:` / `mailto:` リンク計測ではクリック事実と文脈（配置場所・種別）を記録し、生データはマスキングまたはカテゴリ化する
- gtag.jsとGTMで**同一目的のタグを重複実装しない**
- 公式が推奨する設定方法がある場合はそれに従う

---

## 2. コンテナ構造設計

### 2.1 コンテナの原則

| ルール | 説明 |
|--------|------|
| 1社1アカウント | 会社ごとにGTMアカウントを1つ |
| 1サイト1コンテナ | ドメインごとにコンテナを1つ。サブドメインは同一コンテナ |
| スリムに保つ | 不要なタグ・トリガー・変数は定期的に整理。まず一時停止→一定期間後に削除。削除時はバージョン名/説明に記録 |

### 2.2 フォルダ構成

```
_Global                    ← 共通トリガー・共通変数（先頭 _ で最上位に表示）
GA4                        ← GA4関連
GA4 - Ecommerce            ← EC計測がある場合
Google Ads                 ← Google広告関連
Meta                       ← Meta Pixel関連
TikTok                     ← TikTok Pixel関連
X                          ← X Pixel関連
Clarity                    ← Microsoft Clarity関連
Utilities                  ← ヘルパー変数等
```

- 新しいタグ・トリガー・変数は**必ずフォルダに入れる**
- フォルダ名の先頭に `_` を付けると一覧の上位に表示される

### 2.3 タグの発火順序

| 優先度 | トリガー | 用途 |
|--------|---------|------|
| 1 | Consent Initialization - All Pages | CMP（同意管理）タグ |
| 2 | Initialization - All Pages | Google タグ（GA4設定）、コンバージョンリンカー |
| 3 | All Pages | 各プラットフォームのベースタグ（Clarity、Meta Base等） |
| 4 | イベント固有トリガー | コンバージョン、クリックイベント等 |

### 2.4 典型的なタグ構成

**共通基盤:**

| タグ名 | タグタイプ | トリガー | 備考 |
|--------|----------|---------|------|
| GA4 - Config | Google タグ (`googtag`) | Initialization - All Pages | `send_page_view: true`（デフォルト） |
| Google Ads - Conversion Linker | コンバージョンリンカー (`gclidw`) | Initialization - All Pages | Google Ads使用時は原則設置 |

> **`page_view` について:** Google タグはデフォルトで `page_view` を自動送信する（`send_page_view` のデフォルト値が `true`）。別途 `page_view` タグを作成すると二重計測になる。SPAで手動制御が必要な場合のみ、Google タグ側で `send_page_view=false` に設定し、History Changeトリガーで手動発火させる。

**プラットフォーム別のタグ構成:** 各マニュアルを参照 → [セクション5](#5-プラットフォーム別リファレンス)

### 2.5 トリガーの共有

複数プラットフォームで同じタイミングに発火するタグがある場合、**トリガーは共有する**。プラットフォームごとに同じ条件のトリガーを作らない。共有トリガーは `_Global` フォルダに格納。

例: フォーム送信完了トリガー `CE - form_submit` を1つ作成し、GA4・Meta・TikTokのリードイベントタグすべてに紐付ける。

### 2.6 データレイヤー設計

アプリ側で `dataLayer.push` → GTM側でカスタムイベントトリガー + データレイヤー変数で受信。DOM要素の直接参照は脆いため、可能な限りデータレイヤーを使用する。

```javascript
// フォーム送信完了
dataLayer.push({
  event: 'form_submit',
  form_name: 'contact',
  form_id: 'contact-form-01'
});

// 購入完了（GA4 ecommerce準拠）
dataLayer.push({
  event: 'purchase',
  ecommerce: {
    transaction_id: 'T12345',
    value: 9800,
    currency: 'JPY',
    items: [{ item_id: 'SKU001', item_name: '商品名', price: 9800, quantity: 1 }]
  }
});
```

**dataLayerイベント名 vs GA4イベント名:**

| 種類 | 役割 | 例 |
|------|------|-----|
| dataLayerイベント名 | GTMトリガーの識別子。アプリ側で自由命名 | `form_submit`, `purchase` |
| GA4イベント名 | GA4レポートに表示。[推奨イベント](https://support.google.com/analytics/answer/9267735?hl=ja)に準拠推奨 | `generate_lead`, `purchase` |

### 2.7 定数変数でIDを一元管理

測定ID・ピクセルIDは定数変数に格納し、複数のタグから参照する。ID変更時に1箇所の修正で済む。

| 変数名 | 値の例 |
|--------|--------|
| `Const - GA4 Measurement ID` | `G-XXXXXXXXXX` |
| `Const - Google Ads Conversion ID` | `AW-XXXXXXXXX` |
| `Const - Meta Pixel ID` | `123456789012345` |
| `Const - TikTok Pixel ID` | `XXXXXXXXXX` |
| `Const - X Pixel ID` | `XXXXX` |
| `Const - Clarity Project ID` | `xxxxxxxxxx` |

---

## 3. 命名規則

### 3.1 基本方針

| 項目 | ルール |
|------|--------|
| 区切り文字 | ` - `（ハイフン+スペース） |
| 言語 | 英語 |
| 大文字小文字 | プラットフォーム名は大文字始まり、イベント名はsnake_case |

### 3.2 タグ

```
[プラットフォーム] - [タグタイプ] - [詳細]
```

| 例 | 説明 |
|-----|------|
| `GA4 - Config` | GA4設定タグ |
| `GA4 - Event - generate_lead` | GA4イベント |
| `GA4 - Event - click_cta - hero_section` | 詳細付きイベント |
| `Meta - Base` | ベースタグ |
| `Meta - Event - Purchase` | コンバージョン |
| `Clarity - Base` | ベースタグ |
| `TikTok - Event - CompletePayment` | コンバージョン |
| `Google Ads - Conversion - purchase` | コンバージョン |
| `Google Ads - Remarketing` | リマーケティング |
| `X - Event - Purchase` | コンバージョン |

**プラットフォームプレフィックス:**

| プレフィックス | プラットフォーム |
|---------------|----------------|
| GA4 | Google Analytics 4 |
| Google Ads | Google 広告 |
| Meta | Meta（Facebook/Instagram） |
| TikTok | TikTok |
| X | X（Twitter） |
| Clarity | Microsoft Clarity |
| LinkedIn | LinkedIn |

### 3.3 トリガー

```
[トリガータイプ] - [詳細]
```

| 例 | 説明 |
|-----|------|
| `PV - All Pages` | 全ページ |
| `PV - Thank You Page` | 条件付きPV |
| `Click - CTA Button` | クリック |
| `Link Click - External Links` | リンククリック |
| `Link Click - File Download` | ファイルDL |
| `Link Click - Phone Call` | 電話タップ |
| `Form - Contact Submit` | フォーム送信 |
| `Scroll - 50 Percent` | スクロール |
| `CE - purchase` | カスタムイベント |
| `CE - form_submit` | カスタムイベント |
| `Timer - 30s` | タイマー |
| `Visibility - Pricing Section` | 要素の表示 |

**トリガータイプのプレフィックス:**

| プレフィックス | トリガータイプ |
|---------------|---------------|
| PV | ページビュー |
| Click | すべての要素クリック |
| Link Click | リンクのみクリック |
| Form | フォーム送信 |
| Scroll | スクロール深度 |
| CE | カスタムイベント（dataLayer.push） |
| Timer | タイマー |
| Visibility | 要素の表示 |

除外トリガーは `Blocking - ` プレフィックス: `Blocking - Internal Traffic`, `Blocking - Staging Domain`

### 3.4 変数

```
[変数タイプ] - [詳細]
```

| 例 | 説明 |
|-----|------|
| `Const - GA4 Measurement ID` | 定数 |
| `DLV - ecommerce` | データレイヤー変数 |
| `DLV - form_name` | データレイヤー変数 |
| `URL - Page Path` | URL変数 |
| `URL - Query Parameter - utm_source` | URLクエリ |
| `Cookie - user_id` | Cookie |
| `CJS - Trim Page Title` | カスタムJS |
| `LUT - Page Type` | ルックアップテーブル |
| `Regex - Clean URL` | 正規表現テーブル |
| `DOM - H1 Text` | DOM要素 |
| `AEV - Click Classes` | 自動イベント変数 |

**変数タイプのプレフィックス:**

| プレフィックス | 変数タイプ |
|---------------|-----------|
| Const | 定数 |
| DLV | データレイヤー変数 |
| URL | URL変数 |
| Cookie | ファーストパーティCookie |
| CJS | カスタムJavaScript |
| LUT | ルックアップテーブル |
| Regex | 正規表現テーブル |
| DOM | DOM要素 |
| AEV | 自動イベント変数 |
| JSV | JavaScript変数 |

### 3.5 フォルダ

プラットフォーム名をそのまま使用。先頭 `_` で上位表示。

### 3.6 バージョン

```
[プラットフォーム] - [操作] - [対象]
```

例: `GA4 - Add - scroll event`, `Meta - Add - purchase conversion`, `Clarity - Initial Setup`

説明には「**誰が・何を・なぜ**」を記載。変更は小分けにして公開する（複数の無関係な変更を1バージョンにまとめない）。

---

## 4. コンテナJSON仕様

### 4.1 エクスポート/インポート

**エクスポート:** GTM管理画面 → 管理 → コンテナのエクスポート → バージョンまたはワークスペースを選択

**インポート:** GTM管理画面 → 管理 → コンテナのインポート → JSONファイルを選択

| インポート方法 | 動作 |
|---------------|------|
| 上書き（Overwrite） | 既存をすべて削除し、インポート内容で置き換え |
| 統合（Merge） | 既存を保持しつつ追加。競合時は「上書き」か「名前変更」を選択 |

### 4.2 トップレベル構造

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `exportFormatVersion` | number | エクスポート形式バージョン。現在は `2` |
| `exportTime` | string | エクスポート日時（UTC） |
| `containerVersion` | object | コンテナバージョンの全データ |

### 4.3 containerVersion

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `path` | string | APIリソースパス |
| `accountId` | string | GTMアカウントID |
| `containerId` | string | GTMコンテナID |
| `containerVersionId` | string | バージョンID |
| `name` | string | バージョン表示名 |
| `description` | string | バージョン説明 |
| `container` | object | コンテナメタ情報（name、publicId、usageContext等） |
| `tag` | Tag[] | タグ配列 |
| `trigger` | Trigger[] | トリガー配列 |
| `variable` | Variable[] | ユーザー定義変数配列 |
| `builtInVariable` | BuiltInVariable[] | 有効化された組み込み変数配列 |
| `folder` | Folder[] | フォルダ配列 |
| `customTemplate` | CustomTemplate[] | カスタムテンプレート配列 |
| `zone` | Zone[] | ゾーン配列 |
| `gtagConfig` | GtagConfig[] | Googleタグ設定配列 |
| `fingerprint` | string | ハッシュ値（変更検知用） |

### 4.4 Tag

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `accountId` | string | GTMアカウントID |
| `containerId` | string | GTMコンテナID |
| `tagId` | string | タグの一意ID |
| `name` | string | タグ表示名 |
| `type` | string | タグタイプ識別子 |
| `parameter` | Parameter[] | パラメータ配列 |
| `firingTriggerId` | string[] | 発火トリガーID配列（いずれかがtrueで発火） |
| `blockingTriggerId` | string[] | ブロッキングトリガーID配列（いずれかがtrueで発火阻止） |
| `tagFiringOption` | enum | 発火オプション |
| `liveOnly` | boolean | `true` で本番環境のみ発火 |
| `priority` | Parameter | 発火優先度（大きいほど先） |
| `setupTag` | SetupTag[] | セットアップタグ（最大1つ） |
| `teardownTag` | TeardownTag[] | ティアダウンタグ（最大1つ） |
| `parentFolderId` | string | 所属フォルダID |
| `paused` | boolean | `true` で一時停止 |
| `scheduleStartMs` | string | スケジュール開始日時（ミリ秒） |
| `scheduleEndMs` | string | スケジュール終了日時（ミリ秒） |
| `notes` | string | メモ |
| `monitoringMetadata` | Parameter | タグモニタリング用メタデータ |
| `consentSettings` | object | 同意設定 |
| `fingerprint` | string | ハッシュ値 |

**tagFiringOption:**

| 値 | 説明 |
|----|------|
| `unlimited` | イベントごとに複数回発火可能 |
| `oncePerEvent` | 1イベントにつき1回（ページ読み込みごとには複数回可能） |
| `oncePerLoad` | ページ読み込みにつき1回 |

**主要タグタイプ識別子（type）:**

| type | タグ |
|------|------|
| `googtag` | Google タグ（GA4設定、Google Ads統合） |
| `gaawc` | GA4 設定タグ（レガシー） |
| `gaawe` | GA4 イベントタグ |
| `awct` | Google 広告コンバージョン トラッキング |
| `sp` | Google 広告リマーケティング |
| `gclidw` | コンバージョンリンカー |
| `html` | カスタムHTML |
| `img` | カスタム画像 |
| `flc` | Floodlight カウンタ |
| `fls` | Floodlight セールス |
| `cvt_*` | コミュニティテンプレート（`cvt_XXXXXXXXXX` 形式） |

### 4.5 Trigger

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `accountId` | string | GTMアカウントID |
| `containerId` | string | GTMコンテナID |
| `triggerId` | string | トリガーの一意ID |
| `name` | string | トリガー表示名 |
| `type` | enum | トリガータイプ |
| `customEventFilter` | Condition[] | カスタムイベント発火条件（すべてtrueで発火） |
| `filter` | Condition[] | 追加フィルター条件（すべてtrueで発火） |
| `autoEventFilter` | Condition[] | 自動イベントフィルター |
| `parameter` | Parameter[] | 追加パラメータ |
| `parentFolderId` | string | 所属フォルダID |
| `notes` | string | メモ |
| `fingerprint` | string | ハッシュ値 |

**トリガータイプ（Web）:**

| type | トリガー | GTM UI名称 |
|------|---------|-----------|
| `pageview` | ページビュー | ページビュー |
| `domReady` | DOM Ready | DOM Ready |
| `windowLoaded` | ウィンドウの読み込み | ウィンドウの読み込み |
| `customEvent` | カスタムイベント | カスタム イベント |
| `click` | すべての要素クリック | すべての要素 |
| `linkClick` | リンクのみクリック | リンクのみ |
| `formSubmission` | フォーム送信 | フォームの送信 |
| `scrollDepth` | スクロール距離 | スクロール距離 |
| `elementVisibility` | 要素の表示 | 要素の表示 |
| `youTubeVideo` | YouTube動画 | YouTube 動画 |
| `historyChange` | 履歴の変更 | 履歴の変更 |
| `jsError` | JavaScriptエラー | JavaScript エラー |
| `timer` | タイマー | タイマー |
| `triggerGroup` | トリガーグループ | トリガー グループ |
| `init` | 初期化 | 初期化 |
| `consentInit` | 同意の初期化 | 同意の初期化 |

サーバーサイド: `serverPageview`（サーバーサイドのページビュー）

**トリガー固有フィールド:**

| トリガータイプ | 固有フィールド |
|--------------|--------------|
| クリック | `selector`（CSSセレクター）、`checkValidation`、`waitForTags`、`waitForTagsTimeout` |
| スクロール | `verticalScrollPercentageList`、`horizontalScrollPercentageList` |
| タイマー | `eventName`、`interval`（ミリ秒）、`limit`（最大発火回数） |

**Condition（フィルター条件）:**

| フィールド | 説明 |
|-----------|------|
| `type` | 条件タイプ: `equals`, `contains`, `startsWith`, `endsWith`, `matchRegex` 等 |
| `parameter[0]` | `arg0` = 左辺（変数参照。例: `{{_event}}`） |
| `parameter[1]` | `arg1` = 右辺（比較値。例: `purchase`） |

修飾パラメータ: `negate`（`true` で条件反転）、`ignore_case`（`true` で大文字小文字無視）

### 4.6 Variable

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `accountId` | string | GTMアカウントID |
| `containerId` | string | GTMコンテナID |
| `variableId` | string | 変数の一意ID |
| `name` | string | 変数表示名 |
| `type` | string | 変数タイプ識別子 |
| `parameter` | Parameter[] | パラメータ配列 |
| `parentFolderId` | string | 所属フォルダID |
| `notes` | string | メモ |
| `formatValue` | FormatValue | 値の変換オプション |
| `fingerprint` | string | ハッシュ値 |

**主要変数タイプ識別子（type）:**

| type | 変数 | GTM UI名称 |
|------|------|-----------|
| `c` | 定数 | 定数 |
| `v` | データレイヤー変数 | データレイヤーの変数 |
| `j` | JavaScript変数 | JavaScript 変数 |
| `jsm` | カスタムJavaScript | カスタム JavaScript |
| `k` | ファーストパーティCookie | ファーストパーティ Cookie |
| `u` | URL | URL |
| `d` | DOM要素 | DOM 要素 |
| `aev` | 自動イベント変数 | 自動イベント変数 |
| `gas` | Googleアナリティクス設定 | Google アナリティクス設定 |
| `smm` | ルックアップテーブル | ルックアップ テーブル |
| `remm` | 正規表現テーブル | 正規表現の表 |
| `e` | カスタムイベント | カスタム イベント |
| `dbg` | デバッグモード | デバッグモード |
| `ctv` | コンテナバージョン番号 | コンテナ バージョン番号 |
| `vis` | 要素の公開状態 | 要素の公開状態 |
| `gtcs` | Googleタグ: 設定 | Google タグ: 設定 |
| `gtes` | Googleタグ: イベント設定 | Google タグ: イベント設定 |

### 4.7 BuiltInVariable

**ページ関連:**

| type | 説明 |
|------|------|
| `pageUrl` | ページURL |
| `pageHostname` | ホスト名 |
| `pagePath` | パス |
| `referrer` | リファラー |
| `event` | イベント |

**クリック関連:**

| type | 説明 |
|------|------|
| `clickElement` | クリック要素 |
| `clickClasses` | クラス |
| `clickId` | ID |
| `clickTarget` | ターゲット |
| `clickUrl` | URL |
| `clickText` | テキスト |

**フォーム関連:**

| type | 説明 |
|------|------|
| `formElement` | フォーム要素 |
| `formClasses` | クラス |
| `formId` | ID |
| `formTarget` | ターゲット |
| `formUrl` | URL |
| `formText` | テキスト |

**スクロール関連:**

| type | 説明 |
|------|------|
| `scrollDepthThreshold` | 閾値 |
| `scrollDepthUnits` | 単位 |
| `scrollDepthDirection` | 方向 |

**履歴関連:**

| type | 説明 |
|------|------|
| `newHistoryUrl` | 新しい履歴URL |
| `oldHistoryUrl` | 古い履歴URL |
| `newHistoryFragment` | 新しいフラグメント |
| `oldHistoryFragment` | 古いフラグメント |
| `historySource` | ソース |

**動画関連:**

| type | 説明 |
|------|------|
| `videoProvider` | プロバイダ |
| `videoUrl` | URL |
| `videoTitle` | タイトル |
| `videoDuration` | 長さ |
| `videoPercent` | 再生率 |
| `videoStatus` | ステータス |
| `videoCurrentTime` | 現在時刻 |
| `videoVisible` | 表示状態 |

**要素の表示関連:**

| type | 説明 |
|------|------|
| `elementVisibilityRatio` | 表示率 |
| `elementVisibilityTime` | 表示時間 |
| `elementVisibilityFirstTime` | 初回表示時刻 |
| `elementVisibilityRecentTime` | 直近表示時刻 |

**エラー関連:**

| type | 説明 |
|------|------|
| `errorMessage` | エラーメッセージ |
| `errorUrl` | エラーURL |
| `errorLine` | 行番号 |

**その他:**

| type | 説明 |
|------|------|
| `debugMode` | デバッグモード |
| `randomNumber` | 乱数 |
| `containerId` | コンテナID |
| `containerVersion` | コンテナバージョン |
| `htmlId` | HTML ID |
| `environmentName` | 環境名 |

### 4.8 Parameter

タグ・トリガー・変数のパラメータはすべてこの共通構造を使う。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `type` | enum | パラメータ型 |
| `key` | string | パラメータ名（トップレベルおよびmap内では必須、list内では無視） |
| `value` | string | 値（変数参照 `{{変数名}}` を含められる） |
| `list` | Parameter[] | リスト型の子パラメータ配列 |
| `map` | Parameter[] | マップ型のキー付き子パラメータ配列 |
| `isWeakReference` | boolean | 弱参照（Transformation専用） |

**type の値:**

| type | 説明 | 例 |
|------|------|-----|
| `template` | テンプレート文字列（変数参照可） | `"G-XXXXXXXXXX"`, `"{{DLV - ecommerce}}"` |
| `integer` | 64ビット整数 | `"30000"` |
| `boolean` | 真偽値 | `"true"`, `"false"` |
| `list` | パラメータのリスト（`list` フィールドに格納） | — |
| `map` | キー付きパラメータのマップ（`map` フィールドに格納） | — |
| `triggerReference` | トリガーIDへの参照 | `"1"` |
| `tagReference` | タグ名への参照 | `"GA4 - Config"` |

### 4.9 Folder

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `accountId` | string | GTMアカウントID |
| `containerId` | string | GTMコンテナID |
| `folderId` | string | フォルダの一意ID |
| `name` | string | フォルダ名 |
| `fingerprint` | string | ハッシュ値 |

### 4.10 組み込みトリガーID

| 固定ID | トリガー |
|--------|---------|
| `2147479553` | All Pages |
| `2147479573` | Initialization - All Pages |
| `2147479583` | Consent Initialization - All Pages |

**これらの組み込みトリガーIDのみがハードコード可能。** ユーザーが作成したトリガーのIDはコンテナごとに異なる。インポート時にユーザー作成トリガーのIDは自動再採番・更新されるため、JSON内でユーザー作成トリガーのIDはJSON内部の相互参照として一貫性を保てば良い。

### 4.11 インポート時の注意

- `accountId`、`containerId` はインポート先のコンテナに自動置換
- `tagId`、`triggerId`、`variableId`、`folderId` はインポート時に再採番
- `firingTriggerId`、`blockingTriggerId` のID参照も自動更新
- コミュニティテンプレートタグ（`cvt_*`）はインポート先にも同テンプレートが必要
- `fingerprint` はインポート時に再計算

### テンプレートJSON

サイト種別に応じたテンプレートを用意。コミュニティテンプレートの `type` 値（`cvt_*`）はプレースホルダー。インポート先にインストール済みのテンプレートIDに置き換えること。

| テンプレート | プラットフォーム | 用途 |
|---|---|---|
| [gtm-template-corporate.json](./gtm-template-corporate.json) | GA4 + Clarity | コーポレートサイト / ホームページ。スクロール、CTAクリック、電話タップ計測 |
| [gtm-template-lp.json](./gtm-template-lp.json) | GA4 + Clarity + Google Ads | Google Ads向けLP。リード獲得CV（generate_lead）+ スクロール |
| [gtm-template-ec.json](./gtm-template-ec.json) | GA4 + Clarity + Google Ads | ECサイト基本。ecommerceファネル（view_item → add_to_cart → begin_checkout → purchase） |
| [gtm-template-lead-gen.json](./gtm-template-lead-gen.json) | GA4 + Clarity + Google Ads + Meta | リード獲得サイト。複数広告プラットフォームのリードCV + 電話タップ |
| [gtm-template-ec-full.json](./gtm-template-ec-full.json) | GA4 + Clarity + Google Ads + Meta + TikTok + X | EC全部入り。全プラットフォームのecommerce CV + items変換CJS付き |

---

## 5. プラットフォーム別リファレンス

各プラットフォームのイベント定義・パラメータ・GTM設定の詳細は個別マニュアルを参照。

| プラットフォーム | マニュアル | 主な内容 |
|---|---|---|
| Google Analytics 4 | [google-analytics.md](./google-analytics.md) | 推奨イベント、ecommerce、カスタムディメンション、拡張計測 |
| Google Ads | [google-ads.md](./google-ads.md) | コンバージョン設計、Enhanced Conversions、Dynamic Remarketing |
| Meta Pixel | [meta-pixel.md](./meta-pixel.md) | 標準イベント、カスタムイベント、Conversions API |
| TikTok Pixel | [tiktok-pixel.md](./tiktok-pixel.md) | 標準イベント、Events API |
| X Pixel | [x-pixel.md](./x-pixel.md) | 標準イベント、Conversion API |
| Microsoft Clarity | [microsoft-clarity.md](./microsoft-clarity.md) | ヒートマップ、セッション録画、カスタムタグ |

---

## 6. 追加ユースケース

### 6.1 クロスドメイントラッキング

複数ドメイン（例: `example.com` と `shop.example.jp`）をまたぐユーザー行動を同一セッションとして計測する。**GA4管理画面のみで完結し、GTM側の設定は不要。**

**設定:**
1. GA4管理画面 → データストリーム → Googleタグ → タグ設定を行う → **ドメインの設定** → 対象ドメインをすべて追加
2. 必要に応じて「除外する参照のリスト」に決済代行サービス等を追加
3. 動作確認: ドメイン間遷移でURLに `_gl=` パラメータが付与されること、GA4 DebugViewで同一セッションであること

**注意:**
- `<a>` タグのリンククリックにのみ対応。`<form>` 送信やJS遷移では `_gl=` が自動付与されないためカスタム実装が必要
- すべての対象ドメインに同一GA4測定IDのGTMスニペットが設置されていること
- サブドメインはデフォルトで同一ドメイン扱い（設定不要）

### 6.2 内部トラフィック除外

#### 方法A: IPアドレス除外（固定IPオフィス向け）

GA4管理画面 → Googleタグ → 内部トラフィックの定義 → オフィスIPを追加。GA4のデータフィルタでまず「テスト」→ 確認後「有効」に変更（有効化後は除外データの復元不可）。

#### 方法B: Cookie方式（リモートワーク・動的IP対応）

1. **Cookie設定タグ**（カスタムHTML）: 特別なURL（`?set_internal=true`）アクセス時に `is_internal=true` Cookieを設定（90日有効）
2. **Cookie読み取り変数**: `Cookie - is_internal`
3. **ルックアップテーブル変数**: `is_internal=true` → `traffic_type=internal`
4. **Google タグの設定パラメータ**に `traffic_type` を追加
5. GA4のデータフィルタを有効化（方法Aと同手順）

社内メンバーに `https://example.com/?set_internal=true` をブックマークしてもらう（90日ごとに再アクセス）。

#### 方法C: ステージング環境除外

ブロッキングトリガー `Blocking - Staging Domain`（Page Hostname = `staging.example.com`）をGA4タグに設定。

### 6.3 ファイルダウンロード計測

**GA4拡張計測機能（推奨）:** GA4のデータストリーム設定で「ファイルのダウンロード」をオンにすると、`file_download` イベントが自動収集される。対象拡張子: `pdf, xls, xlsx, doc, docx, txt, rtf, csv, exe, key, pps, ppt, pptx, 7z, pkg, rar, gz, zip, avi, mov, mp4, mpe, mpeg, wmv, mid, midi, mp3, wav, wma`。パラメータ: `file_extension`, `file_name`, `link_text`, `link_url`。

**GTMカスタム計測（拡張子追加や特定ページ限定が必要な場合）:**
- トリガー `Link Click - File Download`: リンクのみ、Click URL が `\.(pdf|docx?|xlsx?|pptx?|csv|zip|rar)$` に正規表現一致
- タグ `GA4 - Event - file_download`: パラメータに `file_name={{Click URL}}`, `link_text={{Click Text}}`
- **GTMカスタム計測を使う場合は拡張計測のファイルダウンロードをオフにして重複を防ぐ**

### 6.4 外部リンククリック計測

**GA4拡張計測機能（推奨）:** 「離脱クリック」をオンにすると、`click` イベント（`outbound: true`）が自動収集される。パラメータ: `link_classes`, `link_domain`, `link_id`, `link_url`, `outbound`。

**GTMカスタム計測（特定の外部リンクのみ計測したい場合）:**
- トリガー `Link Click - Outbound`: リンクのみ、Click URL が自サイトドメインを含まない
- タグ `GA4 - Event - outbound_click`: パラメータに `link_url={{Click URL}}`, `link_text={{Click Text}}`
- **GTMカスタム計測を使う場合は拡張計測の「離脱クリック」をオフにして重複を防ぐ**

### 6.5 電話タップ・メールリンク計測

**電話タップ:**
- トリガー `Link Click - Phone Call`: リンクのみ、Click URL が `tel:` で始まる
- タグ `GA4 - Event - phone_call_click`
- **PII注意:** `{{Click URL}}` をそのまま送信すると生の電話番号がGA4に記録される（PII送信禁止）。代わりに配置場所（`header`, `footer`, `contact_page` 等）を送信。HTML側に `data-tracking-section` 属性を設定し、カスタムJS変数で取得する

```javascript
// CJS - Phone Call Location
function() {
  var el = {{Click Element}};
  if (!el) return 'unknown';
  var section = el.closest('[data-tracking-section]');
  return section ? section.getAttribute('data-tracking-section') : 'other';
}
```

```html
<header data-tracking-section="header">
  <a href="tel:03-1234-5678">お電話はこちら</a>
</header>
```

**メールリンク:** 同パターンで `mailto:` も計測可能。トリガー条件を `mailto:` で始まるに変更、イベント名 `email_link_click`、パラメータに配置場所。`{{Click URL}}` の直接送信はPII送信にあたるため禁止。

---

## 7. 運用ルール

### バージョン管理

GTMのバージョン（公開履歴）はロールバック可能な変更履歴として機能する。

```
バージョン名: 変更内容の要約（1行）
説明:
- 誰が: 担当者名
- 何を: 追加・変更・削除した内容
- なぜ: 変更の理由・背景
```

### ワークスペース

チームで運用する場合はワークスペースを分けて作業する。命名: `[プロジェクト名] - [担当者/チーム名]`

### パフォーマンス

- タグ追加時に **PageSpeed Insights** で影響計測
- カスタムHTMLタグは最小限にする
- 同一プラットフォームの重複タグを避ける

---

## 8. チェックリスト

### 新規コンテナ作成時

- [ ] GTMアカウントとコンテナを作成（1社1アカウント、1サイト1コンテナ）
- [ ] GTMスニペットをHTML `<head>` と `<body>` に設置
- [ ] フォルダを作成: `_Global`, `GA4`, 使用する各プラットフォーム
- [ ] 定数変数を作成: `Const - GA4 Measurement ID` 等
- [ ] Google タグ（GA4 - Config）を Initialization - All Pages で設定
- [ ] Google Ads使用時はコンバージョンリンカーを Initialization - All Pages で設定
- [ ] 各プラットフォームのベースタグを All Pages で設定
- [ ] すべてのタグ・トリガー・変数を命名規則に従い命名
- [ ] すべてのタグ・トリガー・変数をフォルダに格納

### 公開前

- [ ] GTMプレビューモードで全タグの発火タイミング確認
- [ ] GA4 DebugView でイベントが正しく記録されていること
- [ ] 各ヘルパーツール（Meta Pixel Helper, Tag Assistant等）で確認
- [ ] `page_view` の二重計測がないこと
- [ ] PIIがイベントパラメータに含まれていないこと
- [ ] 意図しないページでタグが発火していないこと
- [ ] ブロッキングトリガーが正しく機能していること
- [ ] CVイベントのパラメータ（value, currency, transaction_id等）が正しいこと
- [ ] バージョン名と説明を記載

### 命名・構造

- [ ] タグ: `[プラットフォーム] - [タイプ] - [詳細]`
- [ ] トリガー: `[トリガータイプ] - [詳細]`
- [ ] 変数: `[変数タイプ] - [詳細]`
- [ ] 未分類のタグ・トリガー・変数がないこと
- [ ] 同じ条件のトリガーが重複していないこと（共有トリガー使用）
- [ ] 共有トリガーが `_Global` フォルダに格納されていること

---

## 9. デバッグ

| ツール | 用途 |
|--------|------|
| GTM プレビューモード | タグ発火確認、トリガー条件検証 |
| GA4 DebugView | GA4イベントのリアルタイム確認 |
| Meta Pixel Helper（Chrome拡張） | Meta Pixel発火確認 |
| TikTok Pixel Helper（Chrome拡張） | TikTok Pixel発火確認 |
| X Pixel Helper（Chrome拡張） | X Pixel発火確認 |
| Tag Assistant | Google タグ全般の検証 |

**公開前は必ずプレビューモードでテストする。** 特にトリガー条件の確認と、意図しないページでの発火がないかを検証する。

---

## 参考リンク

- [Google - Tag Manager API v2 Developer Guide](https://developers.google.com/tag-platform/tag-manager/api/v2/devguide)
- [Google - Container export and import](https://support.google.com/tagmanager/answer/6106997?hl=en)
- [Google - Tag Manager API v2 - ContainerVersion](https://developers.google.com/tag-platform/tag-manager/api/reference/rest/v2/accounts.containers.versions)
- [Google - Tag Manager API v2 - Tag](https://developers.google.com/tag-platform/tag-manager/api/reference/rest/v2/accounts.containers.workspaces.tags)
- [Google - Tag Manager API v2 - Trigger](https://developers.google.com/tag-platform/tag-manager/api/v2/reference/accounts/containers/workspaces/triggers)
- [Google - Tag Manager API v2 - Variable](https://developers.google.com/tag-platform/tag-manager/api/reference/rest/v2/accounts.containers.workspaces.variables)
- [Google - Tag Manager API v2 - Parameter](https://developers.google.com/tag-platform/tag-manager/api/reference/rest/v2/Parameter)
- [Google - BuiltInVariable Types](https://developers.google.com/tag-platform/tag-manager/api/reference/rest/v2/accounts.containers.versions#BuiltInVariable)
- [Google - コンテナを整理する](https://support.google.com/tagmanager/answer/6261285?hl=ja)
- [Google - クロスドメイン測定](https://support.google.com/analytics/answer/10071811?hl=ja)
- [Google - 内部トラフィック除外](https://support.google.com/analytics/answer/10104470?hl=en)
