# Microsoft Clarity - GTM実装マニュアル

> 最新仕様は [Microsoft Learn - Clarity](https://learn.microsoft.com/en-us/clarity/) で要確認。

---

## 1. コア機能

### 1.1 Session Recordings（セッション録画）

DOMとユーザーアクション（マウス移動・クリック・スクロール・タップ）を記録し、リプレイ再生する。動画ストリームではなくDOM再構成方式。

- **Clarity Highlights**: 長い録画から重要なインタラクションを短いクリップとして自動抽出
- **Clarity Notes**: 録画の特定タイミングにコメント付与
- **Visitor Profile**: 特定ユーザーのセッション履歴を横断閲覧
- **ライブセッション**: 最大100セッション同時視聴

### 1.2 Heatmaps（ヒートマップ）

| 種類 | 内容 |
|------|------|
| **Click Heatmaps** | クリック（タップ）された要素の可視化 |
| **Scroll Heatmaps** | スクロール到達率の表示 |
| **Area Heatmaps** | 選択エリア内のクリック数・分布率 |

- PC / Tablet / Mobile の3デバイスで自動生成・比較可能
- 動的要素（ドロップダウン、ポップアップ等）にも対応
- **Heatmap Insights**: Copilotが自動要約

### 1.3 Dashboard

- **Smart Events**: 主要アクションの自動検出（Purchase, Add to Cart, Sign Up 等9種）
- **Funnels**: コードなしでファネル構築
- **JavaScript Errors**: エラー総数と内訳、Click Errors
- **Bot Activity**: AIクローラー・ボットアクセスの可視化
- **E-Commerce Insights**: Shopify連携による購入・チェックアウト離脱分析

### 1.4 AI / Copilot

- **Copilot Chat**: 自然言語でダッシュボードデータに質問
- **Session Summaries**: 最大250セッションをAIが一括分析・パターンサマリー生成
- **Heatmap Insights**: ヒートマップの自動解析レポート

---

## 2. メトリクス

### Semantic Metrics（フラストレーション指標）

| メトリクス | 定義 |
|-----------|------|
| **Dead Clicks** | クリック後、一定時間内にフィードバックがないクリック |
| **Rage Clicks** | 短時間に同じ狭いエリアで繰り返しクリック |
| **Excessive Scrolling** | スクロール量が平均より著しく多い |
| **Quick Backs** | 別ページ遷移後、短時間で元ページに戻る |

### Performance Metrics（Core Web Vitals）

| メトリクス | 良好 | 要改善 | 不良 |
|-----------|------|--------|------|
| Performance Score | 81-100 | 51-80 | 0-50 |
| LCP | 2.5秒以下 | 4秒以下 | 4秒超 |
| INP | 200ms以下 | 500ms以下 | 500ms超 |
| CLS | 0.1以下 | 0.25以下 | 0.25超 |

### Smart Events（自動検出）

代表的な自動検出イベント:

| イベント名 | 説明 |
|-----------|------|
| **Purchase** | 購入完了 |
| **Add to Cart** | カート追加 |
| **Begin Checkout** | チェックアウト開始 |
| **Contact Us** | 問い合わせ |
| **Submit Form** | フォーム送信 |
| **Request Quote** | 見積もり依頼 |
| **Sign Up** | 新規登録 |
| **Login** | ログイン |
| **Download** | ダウンロード |

> イベントの種類・数はUI更新で変わることがある。Settings > Smart Events の現行UIを正とすること。

Smart Eventsの種類: **Button Clicks** / **API events**（`clarity("event", name)`） / **Auto events**（自動検出） / **Page visits**。カスタムSmart Eventsはノーコードで作成可能（上限はUIで確認）。

### フィルタリング（30種以上）

| グループ | 主なフィルター |
|---------|-------------|
| **User Info** | 期間、曜日、Device、Browser、OS、Location（国/州/市）、User Type（新規/リピーター） |
| **User Actions** | Insights（Rage/Dead/Excessive/Quick Backs）、Clicked text、Scroll depth、Smart Events、Funnels |
| **Path** | Entry URL、Exit URL、Visited URL（正規表現対応） |
| **Traffic** | Referring site、Source、Medium、Campaign、Channel |
| **Performance** | Performance Score、LCP、INP、CLS |
| **Product** | Price、Brand、Product name、Availability、Rating |
| **Session** | Duration、Click count、Page count |
| **Page** | Duration、Click count、JS errors、Page size、Screen resolution |
| **Custom** | Custom tags、Custom User ID、Custom Session ID、Custom Page ID |

複数フィルターの組み合わせを**Segment**として保存・再利用可能。

---

## 3. 制限事項とデータ保持

### 主な制限

> 数値上限はUI更新や契約条件で変わることがある。現行UIの表示を正とすること。

| 項目 | 制限 |
|------|------|
| セッション録画数 | 1プロジェクト/日あたり最大100,000（超過分はサンプリング） |
| ヒートマップ | 1ヒートマップあたり最大100,000 PV |
| ライブセッション | 最大100セッション |
| Custom Tags | 1ページあたり最大128タグ、各タグ最大255文字。タグ種類（キーの種類）自体はプロジェクト全体で無制限 |
| GA4連携 | 1プロジェクトにつき1つのweb propertyのみ |

### データ保持期間

| データ種類 | 保持期間 |
|-----------|---------|
| 通常のセッション録画 | 30日間 |
| Favorite / ラベル付き録画 | 最大13ヶ月 |
| ランダムサンプル録画 | 最大13ヶ月 |
| ヒートマップデータ | 最大13ヶ月 |

---

## 4. GTM構成

### タグ

| タグ名 | テンプレート | トリガー | 備考 |
|--------|------------|---------|------|
| Clarity Tag | Microsoft Clarity - Official（Community Template） | All Pages | Project IDのみ必須 |

### テンプレート設定項目

| フィールド | 説明 | 必須 |
|-----------|------|------|
| **Clarity Project ID** | プロジェクトの固有ID | Yes |
| **Custom ID** | ユーザー一意識別ID | No |
| **Custom Session ID** | カスタムセッションID | No |
| **Custom Page ID** | カスタムページID | No |
| **Friendly name** | ダッシュボード表示用のユーザー名 | No |
| **Custom tag Key** | カスタムタグのキー | No |
| **Custom tag Value** | カスタムタグの値（複数追加可） | No |

### 変数

| 変数名 | 種類 | 値 |
|--------|------|---|
| `Clarity Project ID` | 定数 | （Project ID） |

### SPA対応

ClarityはSPA環境でもルート変更を自動検出する。ただし検出が不完全な場合（Visited URLが分割されない等）は、Custom Tagでルートを付与してセッション・録画のフィルタに使う:

```javascript
// History Changeトリガー等で発火
clarity("set", "route", location.pathname);
```

> `clarity("event", ...)` はイベントとして記録されるだけでURL分割にはならないため、ルート識別にはCustom Tagを使用する。

---

## 5. Client API

### JavaScript API

| API | 構文 | 用途 |
|-----|------|------|
| **Custom Tags** | `clarity("set", key, value)` | セッションにカスタムタグを付与。key/value: string（max 255文字）、valueはstring[]も可。1ページ最大128タグ |
| **Identify** | `clarity("identify", customId, sessionId, pageId, friendlyName)` | ユーザー識別（デバイス横断追跡）。customIdのみ必須 |
| **Event** | `clarity("event", eventName)` | カスタムイベント送信 |
| **Upgrade** | `clarity("upgrade", reason)` | セッションの優先録画（日次上限超過時のサンプリング対策） |
| **ConsentV2** | `clarity("consentv2", {ad_Storage, analytics_Storage})` | Cookie同意状態の送信 |

### HTML属性

| 属性 | 用途 |
|------|------|
| `data-clarity-mask="true"` | 要素とその子要素をマスク |
| `data-clarity-unmask="true"` | 要素とその子要素のマスクを解除 |

> `data-clarity-mask="false"` は効果なし。アンマスクには `data-clarity-unmask="true"` を使用。

### PII（個人情報）の注意

Custom Tags・Event・Identify APIに**メールアドレス・電話番号・氏名等のPIIを直接渡さない**こと。Clarityはマスキング機能でDOM上のPIIを保護するが、API経由で明示的に送信されたデータはマスク対象外。ユーザー識別が必要な場合はIdentify APIにハッシュ化済みIDや内部IDを使用する。

### clarity-events コミュニティテンプレート

GitHub: `mbaersch/clarity-events`。既存のClarityタグとは別タグとして追加し、Event送信・Custom Tags・Session Upgrade・Consent管理をGTM UI上で設定可能。基本タグが既にインストールされていることが前提。

---

## 6. 同意管理（Consent Mode）

### Clarityが設定するCookie

| Cookie名 | 目的 | 種類 | 保持期間 |
|----------|------|------|---------|
| `_clck` | Clarity User IDと設定を保持 | First-party | 1年 |
| `_clsk` | 複数PVを1セッション録画に接続 | First-party | 1日 |
| `CLID` | サイト横断で初回訪問を識別 | Third-party | 1年 |
| `ANONCHK` | MUIDがANIDに転送されたかを示す（常に0） | Third-party | セッション |
| `MR` | MUIDの更新が必要かを示す | Third-party | 7日 |
| `MUID` | Microsoftサイト訪問のユニークブラウザ識別 | Third-party | 1年 |
| `SM` | Microsoftドメイン間のMUID同期 | Third-party | セッション |

> Cookieバナー・プライバシーポリシーの記載時にはこの一覧を参照。保持期間は変更される可能性があるため、[Clarity Cookies](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-cookies) で最新値を確認。

### 同意制御の仕組み

Clarityは `analytics_storage` シグナルを見てCookie設定と機能を制御する:
- **Granted**: Cookieありで完全な分析機能を提供
- **Denied**: Cookieless収集モード（セッション跨ぎ追跡不可、基本データのみ収集）

`ad_storage` はMicrosoft Advertisingへのデータ共有に使われる。Clarity自体はMicrosoft Adsとデータ共有しない。

EEA/UK/CH からのアクセスでは、同意シグナルがない限りClarityはCookieを設定しない（デフォルトDenied）。

### 同意シグナルの送信方法

| 方法 | 説明 |
|------|------|
| **Google Consent Mode (GCM) 自動連携** | GCMを既に使用していれば**追加設定不要**。Clarityが `analytics_storage` / `ad_storage` シグナルを自動読取 |
| **対応CMP** | CookieYes等の対応CMP経由で自動連携 |
| **ConsentV2 API** | `clarity('consentv2', { ad_Storage: "granted", analytics_Storage: "granted" })` で手動送信 |

> ConsentV2 APIのキー名は `ad_Storage` / `analytics_Storage`（Sが大文字）。

### 同意状態ごとの挙動

| 状態 | Cookie | セッション追跡 | 録画 | Heatmap | ダッシュボード指標 |
|------|--------|--------------|------|---------|-----------------|
| Granted | 設定される | 跨ぎ追跡可 | 完全 | 完全 | 完全 |
| Denied | 設定されない | PVごとに一意ID（跨ぎ不可） | 制限付き | 制限付き | 基本データのみ |

### 「Cookies OFF」設定について

Clarity Settings > Setup の「Cookies」をOFFにすると、**同意状態に関わらず全ユーザーを常時cookielessモードにする**。これはGCM/ConsentV2とは別の強い設定であり、通常はGCM連携で十分。全ユーザーをcookielessにしたい特殊なポリシーの場合のみ使用する。

### GTMでの同意管理構成

GCMを既に使用している場合は追加設定不要。手動実装の場合は2タグ構成:

1. **Clarity基本タグ**: All Pagesトリガー
2. **Consent送信タグ**: Cookie同意後のCustom Eventトリガーで `clarity('consentv2', ...)` を実行

---

## 7. Masking（コンテンツマスキング）

| モード | 動作 | 推奨シーン |
|-------|------|----------|
| **Strict** | 全コンテンツをマスク | 金融・医療・法律など高プライバシー要件 |
| **Balanced**（デフォルト） | 数字とメールアドレスのみマスク | ほとんどのWebサイト |
| **Relaxed** | マスクなし | 公開情報のみのサイト |

- 入力ボックスとドロップダウンは**全モードで常にマスク**（変更不可）
- マスクされたデータはClarityサーバーに送信されない
- 設定変更は新しいRecordingにのみ適用（遡及なし）、反映まで最大1時間

---

## 8. GA4連携

### セットアップ

**自動連携（推奨）**: Clarity Settings > Setup > Google Analytics integration で GA4プロパティを選択。データ反映まで**24時間以上**必要。

**手動連携**: Account ID、Measurement ID（`G-`で始まる）、Property ID を入力。

### 連携後にできること

- GA4のトラフィックデータ（セッション、PV等）がClarityダッシュボード内に表示される
- GA4の離脱ポイント → Clarityの録画・ヒートマップで「なぜ」を深掘りする統合分析が可能

> **Playback URL連携について**: 以前はGA4のCustom DimensionにClarity Playback URLが自動送信されていたが、High Cardinality問題等により連携範囲が変更されている。現行の連携機能は [GA4 Integration](https://learn.microsoft.com/en-us/clarity/ga-integration/ga4-integration) およびClarity UIで確認すること。

### 注意点

- 1プロジェクトにつき1つのGA4 web propertyのみ連携可能
- GA4のセグメント機能はClarity内では非対応
- データ反映には最低24時間必要

---

## 9. 推奨設定

| 項目 | 推奨 | 理由 |
|------|------|------|
| インストール方法 | GTM Community Template | Custom optionsの柔軟性と管理のしやすさのバランスが最良 |
| Masking mode | Balanced | 数値・メールを自動マスクしつつ、テキストは可読 |
| Bot detection | ON | 不正トラフィックを自動除外 |
| Consent Mode | GCM連携またはConsentV2 APIで同意制御 | GDPR/ePrivacy準拠。「Cookies OFF」は全ユーザー常時cookielessにしたい場合のみ |
| IP Blocking | オフィスIP・開発者IPをブロック | 内部トラフィック除外 |
| GA4連携 | 有効 | GA4トラフィックデータをClarity内で参照可能。連携範囲は現行UIで確認 |
| Smart Events | 自動検出イベントを確認・カスタマイズ | ノーコードで主要アクションを追跡 |

---

## 10. 参考リンク

- [Microsoft Clarity 公式](https://clarity.microsoft.com/)
- [Microsoft Learn - Clarity](https://learn.microsoft.com/en-us/clarity/)
- [GTM インストールガイド](https://learn.microsoft.com/en-us/clarity/third-party-integrations/google-tag-manager)
- [Client API リファレンス](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-api)
- [Custom Tags](https://learn.microsoft.com/en-us/clarity/filters/custom-tags)
- [Masking](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-masking)
- [Consent Mode](https://learn.microsoft.com/en-us/clarity/setup-and-installation/consent-mode)
- [GA4 Integration](https://learn.microsoft.com/en-us/clarity/ga-integration/ga4-integration)
- [Smart Events](https://learn.microsoft.com/en-us/clarity/setup-and-installation/smart-events)
- [Clarity GTM テンプレート (GitHub)](https://github.com/microsoft/clarity-gtm-template)
- [clarity-events テンプレート (GitHub)](https://github.com/mbaersch/clarity-events)
