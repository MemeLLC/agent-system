# Agent System - マーケティング・開発統合エージェント

マーケティング、開発、デザイン、クリエイティブなど、ビジネスの全モジュールを支援するAIエージェントシステムです。Claude Code と Codex の両方で動作します。

## 📋 概要

- **専門スキル** - マーケティング、SEO、CRO、広告、コンテンツ、分析など
- **マルチプラットフォーム** - Claude Code と Codex で同じスキルを利用可能
- **日本語対応** - 日本語ユーザーのための包括的な指示書

## 🚀 クイックスタート

### 1. 環境設定

```bash
# APIキーを .env に設定
cp .env.example .env
# .env を編集して以下のキーを入力
# - GEMINI_API_KEY
# - XAI_API_KEY
```

### 2. Claude Code での利用

Claude Code を開くと、自動的に以下が読み込まれます：

- `.claude/CLAUDE.md` → プロジェクト指示書
- `.claude/skills/` → 各種スキル定義
- `.claude/tools/` → ツール連携ガイド

その後、スキルを呼び出してください：

```
/copywriting          # コピーライティング
/seo-audit            # SEO診断
/market-research      # 市場調査
/product-marketing-context  # プロダクト文脈設定
```

### 3. Codex での利用

`.codex/` にアクセスすると、同じスキルとツールが利用可能です。

## 📁 プロジェクト構造

```
agent-system/
├── .agents/                    # エージェントシステム本体（Single Source of Truth）
│   ├── INSTRUCTIONS.md         # 共通指示書・スキル一覧
│   ├── skills/                 # 26のマーケティング・クリエイティブスキル
│   └── tools/                  # 外部ツール連携ガイド
│
├── contexts/                   # 事業に関する情報
│   ├── research/               # 市場調査・競合分析
│   ├── strategy/               # 戦略ドキュメント
│   └── meetings/               # 会議ドキュメント
│
├── apps/                       # プログラミング成果物
│   └── <app-name>/             # LP、Webアプリ、ホームページなど
│
├── .claude/                    # Claude Code 設定
├── .codex/                     # Codex 設定
└── README.md                   # このファイル
```

## 🛠 各種スキル

### 基盤・準備 (3)
- `product-marketing-context` - プロダクト文脈設定
- `market-research` - 市場調査
- `x-search-grok` - X/Twitter リアルタイム検索

### コピーライティング・コンテンツ (5)
- `copywriting` - マーケティングコピー作成
- `copy-editing` - コピー編集・改善
- `content-strategy` - コンテンツ戦略設計
- `social-content` - SNS投稿作成
- `email-sequence` - メールシーケンス設計

### SEO・検索 (4)
- `seo-audit` - SEO診断
- `programmatic-seo` - 大量SEOページ生成
- `schema-markup` - 構造化データ実装
- `competitor-alternatives` - 競合比較ページ

### CRO (4)
- `page-cro` - ページ最適化
- `form-cro` - フォーム最適化
- `popup-cro` - ポップアップ最適化
- `ab-test-setup` - A/B テスト設計

### 広告・有料施策 (1)
- `paid-ads` - 広告キャンペーン設計

### 戦略・アイデア (5)
- `marketing-ideas` - マーケティング手法提案
- `marketing-psychology` - 心理学的原則の応用
- `pricing-strategy` - 価格設定戦略
- `launch-strategy` - プロダクトローンチ戦略
- `landing-page-composition` - LP構成設計

### 計測・分析 (1)
- `analytics-tracking` - トラッキング設定

### クリエイティブ (2)
- `image-generation` - AI画像生成
- `remotion-best-practices` - Remotion動画制作

### メタ (1)
- `skill-creator` - 新スキル作成・拡張

詳細は [`.agents/INSTRUCTIONS.md`](./.agents/INSTRUCTIONS.md) を参照。

## 🔗 16個のツール連携

| カテゴリ | ツール |
|---|---|
| **Analytics** | GA4, Adobe Analytics |
| **SEO** | Google Search Console |
| **CRM** | HubSpot, Salesforce |
| **Payments** | Stripe |
| **Email** | Mailchimp, Resend |
| **Ads** | Google Ads, Meta Ads, LinkedIn Ads, TikTok Ads |
| **Automation** | Zapier |
| **Commerce** | Shopify |
| **CMS** | WordPress |

各連携の詳細は [`.agents/tools/integrations/`](./.agents/tools/integrations/) を参照。

## 📊 よくある組み合わせ

### 新規プロダクト立ち上げ
```
product-marketing-context
  → market-research
  → pricing-strategy
  → launch-strategy
```

### LPで集客
```
landing-page-composition
  → copywriting
  → page-cro
  → analytics-tracking
```

### SEOで集客
```
content-strategy
  → seo-audit
  → programmatic-seo
  → schema-markup
```

### 広告で集客
```
paid-ads
  → landing-page-composition
  → copywriting
  → ab-test-setup
```

### 既存ページ改善
```
page-cro
  → copy-editing
  → ab-test-setup
  → analytics-tracking
```

詳細は [`.agents/INSTRUCTIONS.md`](./.agents/INSTRUCTIONS.md) の「よくある組み合わせ」セクションを参照。

## 🎯 contexts/ の使い方

事業に関する情報を項目ごとに整理します：

### research/
市場調査、競合分析、価格調査、法規制調査などの成果物

### strategy/
マーケティング戦略、ポジショニング、プロダクト戦略などの文書

### meetings/
会議ドキュメント、意思決定の記録

例：
```
contexts/
├── research/
│   ├── market-analysis-2026.md
│   ├── competitor-study.md
│   └── pricing-research.md
├── strategy/
│   ├── go-to-market.md
│   └── product-positioning.md
└── meetings/
    └── 2026-02-strategy-meeting.md
```

## 💻 dev/ の使い方

プログラミング成果物を格納します（LP、Webアプリ、ホームページ、APIサーバーなど）。各アプリは独立したディレクトリとして管理します：

```
dev/
├── apps/
│   └── lp-main/
│       ├── package.json
│       ├── src/
│       └── README.md
│   └── server/
│       ├── package.json
│       ├── src/
│       └── README.md
```

## ⚙️ 設定ファイル

### .claude/settings.json
Claude Code の権限・フック設定

### .codex/config.toml
Codex のモデル・承認ポリシー設定

### .env
APIキー（`.gitignore` で管理）
- `GEMINI_API_KEY` - 画像生成用
- `XAI_API_KEY` - X/Twitter 検索用
- `PAGE_SPEED_INSIGHTS_API_KEY` - ページ速度インサイト用

## 📝 スキルの実行方法

### 方法1: スキルを直接呼び出す

```
/copywriting
/seo-audit
/market-research
```

スキルを実行すると、詳細なプロンプトと手順が表示されます。

### 方法2: 複数スキルを組み合わせる

「よくある組み合わせ」のフローに従って、複数スキルを順序立てて実行します。

### 方法3: 既存の contexts/ を参照する

スキル実行時に `contexts/research/` や `contexts/strategy/` のドキュメントを参照することで、より精密な実行が可能になります。

## 🔄 Single Source of Truth 設計

- **`.agents/`** - 実体（26スキル、16ツール連携）
- **`.claude/`** - シンボリックリンク経由で `.agents/` を参照
- **`.codex/`** - シンボリックリンク経由で `.agents/` を参照

変更は `.agents/` に集中させることで、Claude Code と Codex の両方に即座に反映されます。

## 🔐 セキュリティ

- `.env` は `.gitignore` で管理（APIキー保護）
- `.claude/` と `.codex/` の設定ファイルは安全に保管
- contexts/ の機密情報は組織ポリシーに従って管理してください

## 📚 参考資料

- [`.agents/INSTRUCTIONS.md`](./.agents/INSTRUCTIONS.md) - 共通指示書
- [`.agents/skills/`](./.agents/skills/) - 各スキルの詳細

## 🤝 貢献

新しいスキルを作成する場合は、`skill-creator` スキルを使用してください。

---

**Last Updated:** 2026-02-14
**Version:** 1.0
**Platform:** Claude Code, Codex
