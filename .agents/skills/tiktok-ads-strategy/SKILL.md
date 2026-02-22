---
name: tiktok-ads-strategy
description: "TikTok広告の運用戦略を立案し、最適な広告タイプの選定からキャンペーン設計、クリエイティブ設計、運用仕様書の作成までを支援する。ユーザーが以下のいずれかに言及した場合に使用する：「TikTok広告の戦略を立てたい」「TikTok広告を始めたい」「TikTok広告のキャンペーンを設計して」「TikTok広告のクリエイティブを作りたい」「TikTok Adsの運用指示書を作って」「TikTokで集客したい」「Spark Adsの設計」「TopViewの戦略」「ブランドハッシュタグチャレンジの設計」「TikTok Shopの広告」「GMV Maxの設計」「TikTok広告の改善」「TikTok広告のタイプを選びたい」「TikTokの動画広告戦略」「TikTok広告の仕様書」「TikTok広告の設計書」「TikTok広告戦略書」「TikTokリード広告」「TikTokカルーセル広告」「TikTok検索広告」「TikTok広告のクリエイティブ仕様」「TikTokのR&F」「TikTok予約型広告」"
---

# TikTok Ads 戦略・設計スキル

TikTok広告の戦略立案から仕様書作成までを一貫して支援する。17種類の広告タイプから最適な組み合わせを選定し、「Don't Make Ads, Make TikToks」の原則に基づくクリエイティブ設計と運用設計を行う。

## ワークフロー

```
Step 1: 情報収集         → ビジネス情報・目的・予算・ターゲットを整理
    ↓
Step 2: 広告タイプ選定    → 17種類から目的・予算に最適なタイプを選定
    ↓
Step 3: 戦略・クリエイティブ設計  → キャンペーン構造・ターゲティング・クリエイティブを設計
    ↓
Step 4: 仕様書作成        → 運用仕様書・クリエイティブ仕様書を出力
```

---

## Step 1: 情報収集

`contexts/` ディレクトリに既存の情報がある場合はまず参照する。不足する情報はユーザーにヒアリングする。

### 必須情報

| カテゴリ | 確認事項 |
|---------|---------|
| ビジネス概要 | 業種、商品・サービス内容、ターゲット層、USP |
| 広告目的 | 認知拡大 / トラフィック / コンバージョン / アプリインストール / リード獲得 / EC売上 |
| 予算 | 月間予算、日予算の目安（最低: キャンペーン$50/日、広告グループ$20/日） |
| ターゲット | 年齢、性別、地域、興味関心カテゴリ |
| KPI | 目標CPA / ROAS / CPL / CPI / CPM など |
| クリエイティブ素材 | 既存動画・画像の有無、UGC活用の可否、インフルエンサー起用の可否 |

### 状況把握（あれば）

| カテゴリ | 確認事項 |
|---------|---------|
| 既存運用 | 過去のTikTok広告実績（CTR, CVR, CPA, ROAS） |
| 他媒体実績 | Google / Meta / LINE など他媒体の運用実績 |
| TikTokアカウント | ビジネスアカウントの有無、フォロワー数、オーガニック投稿の状況 |
| TikTok Shop | TikTok Shop利用の有無、商品カタログの有無 |
| 競合 | TikTokでの競合広告の状況 |
| 法規制 | 景表法・薬機法・ステマ規制（2023年10月〜）への対応状況 |

---

## Step 2: 広告タイプ選定

TikTok広告は **オークション型（運用型）** と **予約型** の2つの購入方式がある。

| 方式 | 特徴 | 最低予算 | 適したケース |
|-----|------|---------|-------------|
| オークション型 | セルフサーブ、柔軟な予算調整、パフォーマンス最適化 | $20/日〜 | パフォーマンス重視、テスト、中小予算 |
| 予約型 | 営業担当経由、固定CPM、配信保証 | $45,000〜 | ブランディング、大規模リーチ、カテゴリ独占 |

### 広告タイプ早見表

#### ■ フィード内広告

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| In-Feed Ads | オークション | CV/トラフィック/認知 | $20/日〜 | [in-feed-ads.md](references/in-feed-ads.md) |
| Spark Ads | オークション | エンゲージメント/CV | $20/日〜 | [spark-ads.md](references/spark-ads.md) |
| Carousel Ads | オークション | EC/アプリ | $20/日〜 | [carousel-ads.md](references/carousel-ads.md) |

#### ■ プレミアムリーチ（全画面・優先表示）

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| TopView | 予約 | ブランド認知（最大インパクト） | $50,000〜/日 | [topview.md](references/topview.md) |
| Brand Takeover | 予約 | ブランド認知（カテゴリ独占） | $50,000〜/日 | [brand-takeover.md](references/brand-takeover.md) |
| Top Feed | 予約(R&F) | ブランド認知（In-Feed最上位） | 固定CPM | [top-feed.md](references/top-feed.md) |

#### ■ ブランドエンゲージメント

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| Reach & Frequency | 予約 | リーチ/フリークエンシー制御 | 固定CPM | [reach-and-frequency.md](references/reach-and-frequency.md) |
| Branded Hashtag Challenge | 予約 | UGC/大規模エンゲージメント | $150,000+ | [branded-hashtag-challenge.md](references/branded-hashtag-challenge.md) |
| Branded Effects | 予約 | インタラクティブ体験 | $45,000〜 | [branded-effects.md](references/branded-effects.md) |
| Branded Mission | 予約 | UGCクラウドソーシング | $50,000+ | [branded-mission.md](references/branded-mission.md) |

#### ■ 検索広告

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| Search Ads | オークション | 検索意図CV | $30/日〜 | [search-ads.md](references/search-ads.md) |

#### ■ コマース（EC・ショッピング）

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| Video Shopping Ads (VSA) | オークション | EC売上 | 柔軟 | [video-shopping-ads.md](references/video-shopping-ads.md) |
| Dynamic Showcase Ads (DSA) | オークション | リターゲティング | $500/キャンペーン〜 | [dynamic-showcase-ads.md](references/dynamic-showcase-ads.md) |
| GMV Max | 自動最適化 | EC売上最大化 | AOV×10/日 | [gmv-max.md](references/gmv-max.md) |

#### ■ リード・メッセージ・インタラクティブ

| 広告タイプ | 方式 | 主な目的 | 予算目安 | リファレンス |
|-----------|------|---------|---------|------------|
| Lead Generation Ads | オークション | リード獲得 | $20/日〜 | [lead-generation-ads.md](references/lead-generation-ads.md) |
| Messaging Ads | オークション | 会話/リード（東南アジア中心） | $20/日〜 | [messaging-ads.md](references/messaging-ads.md) |
| Playable Ads | オークション(Pangle) | アプリインストール | 柔軟 | [playable-ads.md](references/playable-ads.md) |

### 各広告タイプの活用シーン

#### ■ フィード内広告

**In-Feed Ads** — 最も汎用的な広告タイプ。迷ったらまずこれから始める。
- TikTok広告を初めて運用する場合のファーストチョイス
- コンバージョン（購入・登録・問い合わせ）を直接獲得したい場合
- A/Bテストで複数のクリエイティブ・ターゲティングを検証したい場合
- 少額予算（$20/日〜）でパフォーマンスを試したい場合
- Smart+と組み合わせて自動最適化を活用したい場合

**Spark Ads** — 既存のオーガニック投稿やクリエイター投稿を広告として配信したい場合。
- オーガニックで好反応だった投稿（高い完了率・エンゲージメント）を広告に転用したい場合
- クリエイター/インフルエンサーの投稿をそのまま広告配信したい場合（認証コードで連携）
- 「広告っぽさ」を排除し、ネイティブな見た目で配信したい場合
- エンゲージメント（いいね・コメント・シェア）をオーガニック投稿に蓄積させたい場合
- In-Feed Ads比で CVR +69%、エンゲージメント +142% のパフォーマンスを狙いたい場合

**Carousel Ads** — 複数の商品・ステップ・特徴を1つの広告で見せたい場合。
- ECで複数商品を1つの広告でカタログ的に紹介したい場合
- ステップバイステップの使い方・ビフォーアフターを画像で見せたい場合
- 動画素材がなく、画像のみで広告を作成したい場合
- アプリの複数機能・画面を順番に紹介したい場合

#### ■ プレミアムリーチ（全画面・優先表示）

**TopView** — 最大インパクトで認知を取りたい場合。TikTok広告の中で最も高いCTR（12-16%）。
- 新商品・新ブランドのローンチで一気に認知を獲得したい場合
- 大型キャンペーン・セールイベントの告知（ブラックフライデー、新年等）
- テレビCM的な大規模リーチが必要だが、デジタルで実施したい場合
- ブランドリコールを最大化したい場合（他フォーマット比 1.5倍）
- 予算: $50,000〜$150,000/日が確保できる場合

**Brand Takeover** — カテゴリ独占で競合を排除したい場合。
- 1日1カテゴリ1社限定の独占枠で、競合に一切表示させたくない場合
- 3-5秒の短尺で瞬間的にメッセージを届けたい場合（セール告知、アプリDL誘導等）
- TopViewと組み合わせて、起動直後に全面ジャックしたい場合
- 予算: $50,000〜$100,000/日が確保できる場合

**Top Feed** — In-Feedの最上位枠を確保したい場合。
- TopViewほどの予算はないが、フィード内で最も目立つ位置に表示したい場合
- R&F（Reach & Frequency）購入で確実にリーチとフリークエンシーを制御したい場合
- 3週間以上の中長期ブランディングキャンペーンを実施する場合
- 最低10万リーチ以上の規模感がある場合

#### ■ ブランドエンゲージメント

**Reach & Frequency** — リーチとフリークエンシーを事前に確定して配信したい場合。
- 配信量を事前に保証し、固定CPMで予算管理をしたい場合
- フリークエンシー制御（週2-3回）で最適な接触回数を維持したい場合
- シーケンス配信で「ストーリーを段階的に伝える」ブランドキャンペーンを実施する場合
- 複数クリエイティブをローテーションして配信したい場合（10本以上推奨）
- TopView/Brand Takeover後のフォローアップ認知施策として

**Branded Hashtag Challenge** — ユーザー参加型の大規模バズを起こしたい場合。
- UGC（ユーザー生成コンテンツ）を大量に生み出し、バイラル効果を狙う場合
- ブランドの世界観をユーザーに体験・共有してもらいたい場合
- インフルエンサーシーディング → 一般ユーザー拡散の流れを設計する場合
- メディアンエンゲージメント率 17.5%。予算 $150,000+（インフルエンサー費含む実質 $200,000-$500,000）

**Branded Effects** — ARフィルター・エフェクトでインタラクティブなブランド体験を作りたい場合。
- ユーザーが「遊ぶ」ことでブランドに触れる体験を作りたい場合（化粧品の試着、ゲーミフィケーション等）
- Branded Hashtag Challengeと組み合わせて参加率を高めたい場合
- 2D / 3D / ゲーム型（GBE）から選択。Effect Houseで制作
- 予算: $45,000〜$200,000（10-30日間）

**Branded Mission** — クリエイターからUGCを募集し、優秀な作品を広告配信したい場合。
- クリエイター（1,000フォロワー以上）にお題を出し、動画を集めたい場合
- 集まったUGCの中から優秀作品を選んでIn-Feed広告として配信する場合
- 1回のキャンペーンで半年分のクリエイティブ素材を獲得したい場合
- 予算: $50,000+。20カ国で利用可能（日本含む）

#### ■ 検索広告

**Search Ads** — TikTok内の検索行動をコンバージョンに繋げたい場合。
- ユーザーが能動的に検索するキーワードに対して広告を表示したい場合（検索意図が高い）
- 既存のIn-Feed広告に「自動検索配置」をONにするだけでも効果あり（70%の広告グループで効率改善）
- Google検索広告のようなキーワード管理（ブロード/フレーズ/完全一致）をTikTokでも行いたい場合
- テスト予算: $30/日〜、5-7日間のテスト期間推奨

#### ■ コマース（EC・ショッピング）

**Video Shopping Ads (VSA)** — TikTok Shopで商品を直接販売したい場合。
- TikTok Shop連携で、動画内から直接購入導線を作りたい場合
- 商品タグ付き動画で「見て→買う」の体験を提供したい場合
- ⚠️ 2025年8月以降、GMV Maxに統合予定。新規はGMV Maxを推奨

**Dynamic Showcase Ads (DSA)** — 商品カタログからパーソナライズド広告を自動生成したい場合。
- 閲覧履歴・カート放棄に基づくリターゲティング広告を自動配信したい場合
- 大量の商品SKUを個別にクリエイティブ作成するのが現実的でない場合
- ⚠️ 新規作成不可（VSAに統合済み）。既存運用のみ

**GMV Max** — TikTok Shopの売上を全自動で最大化したい場合。2025年7月以降のデフォルト。
- TikTok Shopの全チャネル（フィード・検索・Shopタブ・Pangle）を一括で最適化したい場合
- ターゲティング・クリエイティブ・入札を全てAIに任せたい場合
- ROI保護機能（実績ROIが目標の90%を下回った場合に自動クレジット）を活用したい場合
- 前提: TikTok Shopアカウント必須、日次20注文以上でROI保護適用
- LIVE GMV Max: ライブコマースのトラフィック最適化に特化

#### ■ リード・メッセージ・インタラクティブ

**Lead Generation Ads** — LP不要でTikTokアプリ内でリード情報を取得したい場合。
- インスタントフォーム（アプリ内フォーム）で離脱率を最小化したい場合
- 自動入力（名前・メール・電話番号）でフォーム完了率を上げたい場合
- B2B: ホワイトペーパーDL、ウェビナー登録、デモ依頼の獲得
- B2C: 見積もり依頼、来店予約、無料体験申込み
- 条件分岐ロジックで質問をパーソナライズしたい場合

**Messaging Ads** — 1対1のチャット会話でリード育成・販売をしたい場合。
- DM（ダイレクトメッセージ）でパーソナライズドな接客をしたい場合
- 美容・不動産・教育など、個別相談が購買に繋がる業種
- 3分以内の返信でエンゲージメント率 2.2倍
- ⚠️ Direct Messaging Adsは東南アジア6カ国限定（日本未対応）。日本からはInstant Messaging Ads（WhatsApp/Messenger連携）のみ

**Playable Ads** — ゲームアプリのインストールを促進したい場合。
- HTML5のインタラクティブ体験（ミニゲーム等）を広告内で提供する場合
- モバイルゲーム（最適）、マンガアプリ、ストリーミングアプリ向け
- 標準モバイル広告比 CVR +123%、CPI -11%
- ⚠️ Pangle配信が必須（TikTok本体には表示されない）

### ビジネス目的別の推奨構成

| ビジネスタイプ | 推奨広告タイプ | 備考 |
|-------------|-------------|------|
| EC（中小規模） | In-Feed + Spark + VSA or GMV Max | Smart+併用推奨。UGC活用でCVR向上 |
| EC（大規模） | TopView + R&F + GMV Max + Spark | ブランディング×パフォーマンスの併用 |
| アプリ（ゲーム） | In-Feed + Playable + Smart+ App | AEO: 90インストール/日目標、Pangle活用 |
| アプリ（非ゲーム） | In-Feed + Spark + Smart+ App | UGCレビュー系クリエイティブが有効 |
| リード獲得（B2B） | In-Feed + Lead Gen + Search | インスタントフォーム、教育コンテンツ中心 |
| リード獲得（B2C） | Spark + Lead Gen + Messaging | UGC + インスタントフォームの組み合わせ |
| ブランド認知（大規模） | TopView + HTC + Branded Effects + R&F | 予約型中心、インフルエンサーシーディング必須 |
| ブランド認知（中規模） | R&F + Spark + Top Feed | 固定CPMでフリークエンシー制御 |
| 店舗集客 | In-Feed + Spark + Search | ローカルターゲティング、$20/日〜 |

### 予算別の推奨

| 月予算 | 推奨構成 |
|-------|---------|
| 〜$1,000 | In-Feed or Spark（1キャンペーン、2-3広告グループ） |
| $1,000〜$5,000 | In-Feed + Spark + Search（テスト→スケール構成） |
| $5,000〜$20,000 | 上記 + Lead Gen or VSA（目的別に追加） |
| $20,000〜$50,000 | Smart+ 併用、複数目的のキャンペーン運用 |
| $50,000+ | 予約型（TopView/R&F）+ オークション型の併用 |

### 選定後のアクション

広告タイプを選定したら、以下をユーザーに提示して合意を取る：

1. 選定した広告タイプとその理由
2. 各タイプの想定予算配分
3. キャンペーン目的と最適化イベント
4. 想定KPI（CPM / CPC / CPA / ROAS の目安）

---

## Step 3: 戦略・クリエイティブ設計

キャンペーン構造、ターゲティング、入札、クリエイティブを設計する。詳細は以下のリファレンスを参照。

- キャンペーン構造・ターゲティング・入札・スケーリング → [campaign-strategy.md](references/campaign-strategy.md)
- クリエイティブの原則・動画構成・ツール・日本市場 → [creative-fundamentals.md](references/creative-fundamentals.md)
- 各広告タイプ固有の設計 → Step 2 の各リファレンスファイル

### 3-1. キャンペーン構造設計

- **3層構造**: キャンペーン（戦略）→ 広告グループ（戦術）→ 広告（実行）
- **テスト vs スケール分離**: ABO（テスト用 20-30%予算）→ CBO（スケール用 70-80%予算）
- **Smart+**: 月$1,500以上の予算で手動比較を推奨。80%のケースで手動を上回る
- **ラーニングフェーズ**: 50コンバージョン/7日。予算 = 目標CPA × 20（最低）〜 × 50（理想）

### 3-2. ターゲティング設計

- **2025年のトレンド**: ブロードターゲティングが主流（狭いターゲティング比 CPA -15%, CVR +20%）
- **リターゲティング**: カート放棄7日、一般訪問者30-60日、高額商品60-180日
- **類似オーディエンス**: 購入者 > カート追加 > リード > 高エンゲージ視聴者 > 全訪問者

### 3-3. クリエイティブ設計の原則

**「Don't Make Ads, Make TikToks」** — TikTokのネイティブコンテンツに溶け込むクリエイティブが最も効果的。

- **UGC**: プロ制作比 +22% 効果、+55% ROI。79%のユーザーがUGCで購買を決定
- **最初の3秒**: 視聴完了率の71%を決定。3秒視聴者の45%が30秒以上視聴
- **動画構成**: フック(0-3秒) → ボディ(10-20秒) → CTA(3-5秒)
- **クリエイティブ疲労**: Metaの4倍速（高予算で3日 vs Meta 2週間）。3-5日ごとのマイクロリフレッシュ推奨
- **音声**: 68%のユーザーが音楽付きTikTokをより記憶。CML（商用音楽ライブラリ）使用

### 3-4. 命名規則

キャンペーン・広告グループ・広告に統一的な命名規則を設定する。

```
キャンペーン: {目的}_{広告タイプ}_{ターゲット}_{地域}
広告グループ: {ターゲティング種別}_{詳細}_{入札戦略}
広告: {クリエイティブ種別}_{内容}_{バージョン}

例:
CV_InFeed_Broad_JP
Interest_Beauty25-34_CostCap
UGC_ProductReview_v1
```

---

## Step 4: 仕様書作成

選定した広告タイプごとに、以下のリファレンスを参照して仕様書を作成する。

### リファレンス一覧

| カテゴリ | リファレンス | 主な設計項目 |
|---------|------------|-------------|
| In-Feed Ads | [in-feed-ads.md](references/in-feed-ads.md) | フック設計、テストフレームワーク、テキストオーバーレイ |
| Spark Ads | [spark-ads.md](references/spark-ads.md) | 投稿選定基準、認証コード、オーガニック連携 |
| TopView | [topview.md](references/topview.md) | 2段階構成、フルスクリーン演出、高ビットレート |
| Brand Takeover | [brand-takeover.md](references/brand-takeover.md) | 3-5秒設計、カテゴリ独占、テキストオーバーレイ |
| Top Feed | [top-feed.md](references/top-feed.md) | In-Feed最上位、R&F購入、音声設計 |
| Reach & Frequency | [reach-and-frequency.md](references/reach-and-frequency.md) | フリークエンシー制御、シーケンス配信 |
| Branded Hashtag Challenge | [branded-hashtag-challenge.md](references/branded-hashtag-challenge.md) | ハッシュタグ設計、シーディング、参加設計 |
| Branded Effects | [branded-effects.md](references/branded-effects.md) | エフェクト種別、Effect House、ゲーミフィケーション |
| Branded Mission | [branded-mission.md](references/branded-mission.md) | UGCクラウドソーシング、クリエイター要件 |
| Carousel Ads | [carousel-ads.md](references/carousel-ads.md) | 画像構成、ストーリー設計、BGM |
| Search Ads | [search-ads.md](references/search-ads.md) | キーワード設計、3フェーズ戦略 |
| Video Shopping Ads | [video-shopping-ads.md](references/video-shopping-ads.md) | 商品表示、TikTok Shop連携 |
| Dynamic Showcase Ads | [dynamic-showcase-ads.md](references/dynamic-showcase-ads.md) | カタログ連携、リターゲティング |
| GMV Max | [gmv-max.md](references/gmv-max.md) | 自動最適化、LIVE連携、移行スケジュール |
| Lead Generation Ads | [lead-generation-ads.md](references/lead-generation-ads.md) | インスタントフォーム、条件分岐 |
| Playable Ads | [playable-ads.md](references/playable-ads.md) | HTML5設計、Pangle配信 |
| Messaging Ads | [messaging-ads.md](references/messaging-ads.md) | DM設計、ウェルカムメッセージ |
| キャンペーン戦略 | [campaign-strategy.md](references/campaign-strategy.md) | 構造設計、ターゲティング、入札、スケーリング |
| クリエイティブ基礎 | [creative-fundamentals.md](references/creative-fundamentals.md) | 動画構成、ツール、日本市場、運用 |
| 出力テンプレート | [output-templates.md](references/output-templates.md) | 仕様書テンプレート |

### 仕様書に含めるべき項目

1. **戦略サマリ**: 広告目的、ターゲット、予算配分、KPI目標
2. **キャンペーン構造表**: キャンペーン/広告グループ/広告の階層と命名規則
3. **広告タイプ別設計**: 選定した各タイプの詳細設計（ターゲティング、入札、配置）
4. **クリエイティブ仕様**: フォーマット、サイズ、尺、フック設計、テキストオーバーレイ
5. **コピー設計**: キャプション、CTA、テキストオーバーレイのコピー
6. **計測設計**: ピクセル設定、コンバージョンイベント、アトリビューション設定
7. **運用スケジュール**: ローンチ日、テスト期間、スケーリング計画、クリエイティブリフレッシュ周期
8. **KPIベンチマーク**: CTR / CVR / CPA / ROAS の目標値と業界平均

出力テンプレートは [output-templates.md](references/output-templates.md) を参照。

仕様書は `contexts/strategy/` に Markdown ファイルとして保存する。

---

## 関連スキル

| スキル | 使い分け |
|-------|---------|
| **copywriting** | 広告コピー・LP コピーの本格的な作成が必要な場合 |
| **landing-page-composition** | 広告の遷移先 LP の構成設計が必要な場合 |
| **page-cro** | 広告の遷移先ページの CVR 改善が必要な場合 |
| **analytics-tracking** | GA4・GTM・TikTok Pixel の計測設計が必要な場合 |
| **competitor-analysis** | TikTok上の競合広告を詳しく分析したい場合 |
| **image-generation** | 広告用サムネイル・バナー画像を AI で生成したい場合 |
| **google-ads-strategy** | Google 広告と TikTok 広告を併用する場合 |
| **meta-ads-strategy** | Meta 広告と TikTok 広告を併用する場合 |
