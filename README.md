# R Shiny ハンズオン

このリポジトリは、R Shinyの基礎からインタラクティブな可視化、地理データの表示までを学べるハンズオンです。

## 概要

このワークショップでは、以下の内容を学ぶことができます：

- R Shinyの基本構造と開発環境のセットアップ
- 基本的なデータ可視化（ggplot2）
- インタラクティブな可視化（plotly, DT）
- 地理データの可視化（leaflet）
- ダッシュボードUI設計(bs4Dash)

## 前提条件

以下のいずれかの環境を想定：

1. **Dockerを使用する方法（推奨）**
   - Dockerがインストールされていること
   - Dockerがインストール方法については公式ページを参照してください

2. **ローカルRStudioを使用する方法**
   - R 4.0以上
   - RStudio

## インストール方法

### 1. Dockerを使用する方法（推奨）

1. このリポジトリをクローンします：

```bash
git clone git@github.com:de-developer-1/R-Shiniy-Hands-On-For-Beginner.git
cd R-Shiniy-Hands-On-For-Beginner
```

2. Docker Composeでコンテナを起動します：

```bash
docker-compose up -d
```

3. ブラウザで以下のURLにアクセスします：

- RStudio Server: http://localhost:8787
  - ユーザー名: `rstudio`
  - パスワード: `password`

- Shiny アプリケーション: http://localhost:3838/app/

### 2. ローカルRStudioを使用する方法

1. このリポジトリをクローンします：

```bash
git clone git@github.com:de-developer-1/R-Shiniy-Hands-On-For-Beginner.git
cd R-Shiniy-Hands-On-For-Beginner
```

2. 必要なパッケージをインストールします：

```r
install.packages(c(
  "shiny", 
  "ggplot2", 
  "dplyr", 
  "readr", 
  "DT", 
  "plotly", 
  "leaflet", 
  "RColorBrewer", 
  "scales", 
  "sf", 
  "bs4Dash", 
  "pool", 
  "RPostgres", 
  "jsonlite"
))
```

3. データ準備スクリプトを実行します：

```r
setwd("app/scripts")
source("prepare_data.R")
```

4. アプリケーションを実行します：

```r
setwd("app")
shiny::runApp()
```

## アプリケーションの構成

このShinyアプリケーションでは以下の3つのタブを構成しています。：

1. **基本可視化タブ**
   - ggplot2を使った基本的なグラフ表示
   - グラフの種類を切り替え可能（棒グラフ、折れ線グラフ、散布図、箱ひげ図）
   - 各グラフのコードサンプルを表示

2. **インタラクティブタブ**
   - plotlyを使ったインタラクティブなグラフ
   - DTパッケージを使ったインタラクティブなデータテーブル
   - ソート、検索、ページングなどの機能

3. **地理データタブ**
   - leafletを使った地図上での都道府県データの可視化
   - 人口または施設数を地図上に表示
   - クリック時のポップアップ表示

## リポジトリ構成

```
R-Shiniy-Hands-On-For-Beginner/
├── .gitignore
├── README.md               # インストールと使用方法の説明
├── docker-compose.yml      # Docker環境構成ファイル
├── Dockerfile              # R+RStudioのDockerイメージ定義
├── app/                    # Shinyアプリケーション
│   ├── app.R              # メインアプリケーションコード
│   ├── data/              # サンプルデータ
│   │   ├── population.csv  # 都道府県別人口データ
│   │   ├── facilities.csv  # 施設データ
│   │   └── japan_prefectures.geojson  # 都道府県の地理データ
│   ├── scripts/
│   │   └── prepare_data.R  # データ準備スクリプト
│   └── www/               # 静的ファイル（CSS、JS、画像など）
│       └── custom.css     # カスタムスタイルシート
└── setup/
    └── init.sql           # データベース初期化SQL
```

## 学習方法

1. まず、アプリケーションを起動して各タブの機能を試してみてください。
2. `app.R`ファイルを開き、コードの構造を確認します。
3. 各タブ内のコードサンプルを参考に、Shinyの仕組みを理解しましょう。
4. 練習として、新しい可視化やインタラクティブ機能を追加してみてください。

## トラブルシューティング

- **Q: Dockerコンテナが起動しない**
  - A: Docker Desktopが起動しているか確認し、メモリ割り当てを増やしてみてください。

- **Q: パッケージのインストールでエラーが発生する**
  - A: Rのバージョンを確認し、必要に応じて依存ライブラリをインストールしてください。

- **Q: 地図データが表示されない**
  - A: インターネット接続を確認し、leafletのマップタイルがロードできているか確認してください。
