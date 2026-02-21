# 競合分析 調査ガイド

## 目次

1. [競合の特定](#1-競合の特定)
2. [競合企業の基本情報](#2-競合企業の基本情報)
3. [Google検索での競合比較](#3-google検索での競合比較)
4. [広告運用の調査](#4-広告運用の調査)

---

各項目で最低2〜3回の異なるクエリで検索すること。検索言語はビジネスのターゲット市場・展開地域に合わせる。

## 1. 競合の特定

**調べること:**
- 直接競合（同じ課題を同じ方法で解決するサービス・企業）
- 間接競合（同じ課題を別の方法で解決するサービス・企業）
- 直接競合3〜5社、間接競合2〜3社をリストアップする

**クエリ例:**
- `"[サービス名] 競合"`
- `"[サービス名] alternatives"`
- `"[業種] 比較 ランキング"`
- `"[業種] カオスマップ"`
- `"[サービス名] vs"`

## 2. 競合企業の基本情報

各競合について以下の情報を調査する。

**調べること:**
- 売上規模（年商、売上高）
- 従業員数
- 展開しているビジネスの内容（サービス概要、主力商品、ターゲット層）
- 代表者の名前
- ホームページのURL
- LP（ランディングページ）のURL

**クエリ例:**
- `"[競合名] 会社概要"`
- `"[競合名] 売上 従業員数"`
- `"[競合名] 代表"`
- `"[競合名] 企業情報"`
- `site:[競合ドメイン] company` / `site:[競合ドメイン] about`

**情報源の優先順:**
- 競合の公式サイト（会社概要ページ、IR情報）
- 企業データベース（マイナビ、Wantedly、INITIAL、Crunchbase など）
- 上場企業の場合はIR資料（有価証券報告書、決算資料）
- プレスリリース（PR TIMES など）

**注意:**
- 各社の公式サイトをWebFetchで確認し、会社概要ページから基本情報を取得する
- 非公開企業の場合、売上規模は推定値でも可（推定であることを明記する）

## 3. Google検索での競合比較

`playwright-browser` スキルを使い、主要キーワードでのGoogle検索結果を取得して自社と競合の順位を比較する。

**調べること:**
- 主要キーワードでの自社・各競合の検索順位
- 各キーワードの検索結果上位を占めているサイトの傾向
- 広告枠での自社・競合の出稿状況
- リッチリザルト（FAQ、レビュー等）の表示有無

**キーワード選定:**

業界・サービスカテゴリから5〜10個を選定する。`business-profile` が完了している場合はそこから引き継ぐ。

| カテゴリ | クエリ例 |
|---------|---------|
| サービスカテゴリ | `[業種] サービス`, `[提供内容] ツール` |
| 比較・検討系 | `[業種] 比較`, `[サービスカテゴリ] おすすめ` |
| 課題・ニーズ系 | `[顧客の課題] 解決`, `[ニーズ] 方法` |
| 地域系（該当する場合） | `[地域名] [サービスカテゴリ]` |

**調査手順:**

各キーワードについてテキスト結果の取得とスクリーンショット撮影を行う。

```bash
# テキスト結果の取得（上位10件）
node $SKILL_DIR/../playwright-browser/scripts/browser.mjs search "[キーワード]" --results 10

# 検索結果画面のスクリーンショット
node $SKILL_DIR/../playwright-browser/scripts/browser.mjs interact "https://www.google.com/search?q=[キーワード]&hl=ja&gl=jp" \
  --actions '[{"action":"wait","timeout":2000},{"action":"screenshot","path":"research/screenshots/competitor-analysis/serp-[keyword-slug].png"}]'
```

**結果の記録:**
- キーワードごとに自社・各競合の順位を一覧テーブルにまとめる
- 1ページ目（上位10件）に入っていない場合は「圏外」と記載
- 広告枠に自社・競合が出稿しているかも記録する

## 4. 広告運用の調査

`playwright-browser` スキルで広告ライブラリにアクセスし、各競合の広告運用状況を調査する。

**調べること:**
- 各競合がどのようなLPを出しているか（LP URL、構成、訴求ポイント）
- 広告クリエイティブの内容（コピー、ビジュアル、CTA）
- 出稿プラットフォーム（Meta、Google、TikTok など）
- 広告の出稿量・掲載期間

**調査ツール:**
- Meta広告ライブラリ — 各競合名で検索
- Google広告の透明性センター — 各競合名で検索
- TikTok Top Ads — 業界関連の広告パフォーマンス上位を確認
- TikTokキーワードインサイト — 競合が使用しているキーワードを確認

**スクリーンショットの撮影:**

広告クリエイティブとLPは `playwright-browser` スキルの screenshot コマンドで撮影する。

```bash
# 広告ライブラリの検索結果画面
node .agents/skills/playwright-browser/scripts/cli.mjs screenshot <広告ライブラリURL> --output research/screenshots/competitor-analysis/[競合名]-ad-01.png

# 競合のLP（ページ全体）
node .agents/skills/playwright-browser/scripts/cli.mjs screenshot <LP URL> --output research/screenshots/competitor-analysis/[競合名]-lp-01.png --full-page

# 競合のホームページ
node .agents/skills/playwright-browser/scripts/cli.mjs screenshot <HP URL> --output research/screenshots/competitor-analysis/[競合名]-hp-01.png --full-page
```

**注意:**
- 広告のURL、LP URLは必ず記録する
- スクリーンショットは `research/screenshots/competitor-analysis/` に保存する
- マークダウンレポート内でスクリーンショットのパスを記載し、どの画像が何を撮影したものか明記する
