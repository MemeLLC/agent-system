---
name: remotion-best-practices
description: Remotionのベストプラクティス - Reactでの動画制作
metadata:
  tags: remotion, video, react, animation, composition
---

## 使用タイミング

Remotionのコードを扱う際に、ドメイン固有の知識を得るためにこのスキルを使用してください。

## キャプション

キャプションや字幕を扱う場合は、[./rules/subtitles.md](./rules/subtitles.md) ファイルを読み込んで詳細を確認してください。

## FFmpegの使用

動画のトリミングや無音検出など、一部の動画操作にはFFmpegを使用する必要があります。[./rules/ffmpeg.md](./rules/ffmpeg.md) ファイルを読み込んで詳細を確認してください。

## オーディオビジュアライゼーション

オーディオのビジュアライズ（スペクトラムバー、波形、低音反応エフェクトなど）が必要な場合は、[./rules/audio-visualization.md](./rules/audio-visualization.md) ファイルを読み込んで詳細を確認してください。

## 使い方

個別のルールファイルを読んで、詳細な説明とコード例を確認してください：

- [rules/3d.md](rules/3d.md) - Three.jsとReact Three Fiberを使用したRemotionでの3Dコンテンツ
- [rules/animations.md](rules/animations.md) - Remotionの基本的なアニメーションスキル
- [rules/assets.md](rules/assets.md) - Remotionへの画像、動画、音声、フォントのインポート
- [rules/audio.md](rules/audio.md) - Remotionでの音声とサウンドの使用 - インポート、トリミング、音量、速度、ピッチ
- [rules/calculate-metadata.md](rules/calculate-metadata.md) - コンポジションの長さ、サイズ、プロパティの動的設定
- [rules/can-decode.md](rules/can-decode.md) - Mediabunnyを使用してブラウザで動画をデコードできるかチェック
- [rules/charts.md](rules/charts.md) - Remotionのチャートとデータビジュアライゼーションパターン（棒グラフ、円グラフ、折れ線グラフ、株価チャート）
- [rules/compositions.md](rules/compositions.md) - コンポジション、スティル、フォルダ、デフォルトプロパティ、動的メタデータの定義
- [rules/extract-frames.md](rules/extract-frames.md) - Mediabunnyを使用して特定のタイムスタンプで動画からフレームを抽出
- [rules/fonts.md](rules/fonts.md) - RemotionでのGoogleフォントとローカルフォントの読み込み
- [rules/get-audio-duration.md](rules/get-audio-duration.md) - Mediabunnyを使用して音声ファイルの長さを秒単位で取得
- [rules/get-video-dimensions.md](rules/get-video-dimensions.md) - Mediabunnyを使用して動画ファイルの幅と高さを取得
- [rules/get-video-duration.md](rules/get-video-duration.md) - Mediabunnyを使用して動画ファイルの長さを秒単位で取得
- [rules/gifs.md](rules/gifs.md) - Remotionのタイムラインと同期したGIFの表示
- [rules/images.md](rules/images.md) - Imgコンポーネントを使用したRemotionでの画像埋め込み
- [rules/light-leaks.md](rules/light-leaks.md) - @remotion/light-leaksを使用したライトリークオーバーレイエフェクト
- [rules/lottie.md](rules/lottie.md) - RemotionでのLottieアニメーションの埋め込み
- [rules/measuring-dom-nodes.md](rules/measuring-dom-nodes.md) - RemotionでのDOM要素サイズの計測
- [rules/measuring-text.md](rules/measuring-text.md) - テキストサイズの計測、コンテナへのテキストフィット、オーバーフローチェック
- [rules/sequencing.md](rules/sequencing.md) - Remotionのシーケンスパターン - 遅延、トリミング、アイテムの長さ制限
- [rules/tailwind.md](rules/tailwind.md) - RemotionでのTailwindCSSの使用
- [rules/text-animations.md](rules/text-animations.md) - Remotionのタイポグラフィとテキストアニメーションパターン
- [rules/timing.md](rules/timing.md) - Remotionの補間カーブ - リニア、イージング、スプリングアニメーション
- [rules/transitions.md](rules/transitions.md) - Remotionのシーントランジションパターン
- [rules/transparent-videos.md](rules/transparent-videos.md) - 透明度付き動画のレンダリング
- [rules/trimming.md](rules/trimming.md) - Remotionのトリミングパターン - アニメーションの開始部分または終了部分のカット
- [rules/videos.md](rules/videos.md) - Remotionでの動画埋め込み - トリミング、音量、速度、ループ、ピッチ
- [rules/parameters.md](rules/parameters.md) - Zodスキーマを追加して動画をパラメータ化
- [rules/maps.md](rules/maps.md) - Mapboxを使用したマップの追加とアニメーション
- [rules/voiceover.md](rules/voiceover.md) - ElevenLabs TTSを使用したRemotionコンポジションへのAI生成ナレーションの追加
