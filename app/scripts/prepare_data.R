# ========================================
# データ準備スクリプト
# ========================================

# 必要なライブラリのロード
library(dplyr)
library(readr)
library(sf)
library(jsonlite)
library(RPostgres)
library(DBI)

# 出力ディレクトリの作成
dir.create("../data", showWarnings = FALSE)

# ========================================
# 都道府県別人口データの作成
# ========================================
# 実際のデータはこのようなサンプルを使用
population_data <- data.frame(
  prefecture = c(
    "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
    "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
    "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
    "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
  ),
  region = c(
    "北海道", "東北", "東北", "東北", "東北", "東北", "東北",
    "関東", "関東", "関東", "関東", "関東", "関東", "関東",
    "中部", "中部", "中部", "中部", "中部", "中部", "中部",
    "中部", "中部", "近畿", "近畿", "近畿", "近畿", "近畿",
    "近畿", "近畿", "中国", "中国", "中国", "中国", "中国",
    "四国", "四国", "四国", "四国", "九州", "九州", "九州",
    "九州", "九州", "九州", "九州", "沖縄"
  ),
  population = c(
    5320000, 1246000, 1227000, 2306000, 966000, 1078000, 1846000,
    2860000, 1934000, 1942000, 7350000, 6259000, 14049000, 9237000,
    2223000, 1044000, 1138000, 768000, 811000, 2049000, 1987000,
    3644000, 7552000, 1781000, 1414000, 2583000, 8809000, 5466000,
    1330000, 925000, 556000, 674000, 1890000, 2804000, 1358000,
    728000, 956000, 1339000, 698000, 5104000, 815000, 1327000,
    1748000, 1135000, 1073000, 1599000, 1454000
  ),
  area = c(
    83424, 9646, 15275, 7282, 11638, 9323, 13784,
    6097, 6408, 6362, 3798, 5158, 2194, 2416,
    12584, 4248, 4186, 4190, 4465, 13105, 10621,
    7777, 5172, 5774, 4017, 4612, 1905, 8401,
    3691, 4725, 3507, 6708, 7115, 8479, 6112,
    4147, 1877, 5676, 7104, 4987, 2441, 4133,
    7409, 6341, 7735, 9187, 2281
  )
)

# 人口密度を計算
population_data <- population_data %>%
  mutate(density = population / area)

# CSVとして保存
write_csv(population_data, "../data/population.csv", append = FALSE)

# ========================================
# 施設データの作成（架空データ）
# ========================================
set.seed(123)  # 再現性のため

# 架空の施設データを作成
facility_types <- c("病院", "学校", "公園", "図書館", "美術館", "体育館", "市役所", "警察署", "消防署")
facility_count <- 500  # 施設の数

# 緯度経度の範囲（日本）
lat_range <- c(30.0, 45.5)  # 緯度範囲
lng_range <- c(128.0, 146.0)  # 経度範囲

# 架空の施設データを生成
facilities_data <- data.frame(
  name = paste0("施設", 1:facility_count),
  type = sample(facility_types, facility_count, replace = TRUE),
  latitude = runif(facility_count, lat_range[1], lat_range[2]),
  longitude = runif(facility_count, lng_range[1], lng_range[2]),
  address = paste0("○○県△△市××町", sample(1:100, facility_count, replace = TRUE), "番地")
)

# 座標から都道府県を割り当て（簡易版）
# 実際には地理空間演算が必要ですが、ここでは簡易的に実装
assign_prefecture <- function(lat, lng) {
  # 緯度経度から大まかな地域を推定
  prefectures <- population_data$prefecture
  
  if (lat > 43) {
    return("北海道")
  } else if (lng < 131) {
    return(sample(c("福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県"), 1))
  } else if (lat < 34) {
    if (lng > 134) {
      return(sample(c("高知県", "徳島県", "愛媛県", "香川県"), 1))
    } else {
      return("沖縄県")
    }
  } else if (lat > 40) {
    return(sample(c("青森県", "岩手県", "秋田県"), 1))
  } else if (lat > 37.5) {
    return(sample(c("宮城県", "山形県", "福島県", "新潟県"), 1))
  } else if (lat > 36 && lng > 138) {
    return(sample(c("茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県"), 1))
  } else if (lat > 34 && lng > 136) {
    return(sample(c("富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県"), 1))
  } else {
    return(sample(c("三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県"), 1))
  }
}

# 都道府県を割り当て
facilities_data$prefecture <- mapply(assign_prefecture, facilities_data$latitude, facilities_data$longitude)

# CSVとして保存
write_csv(facilities_data, "../data/facilities.csv", append = FALSE)

# ========================================
# 日本の地理データを作成/取得
# ========================================
# 注：実際の地理データは例えば国土地理院のデータを使用するなど適切なソースから取得

# 簡易的な地理データの作成（実際のプロジェクトでは正確なデータを使用）
# GeoJSONデータのサンプル（非常に簡略化）
japan_prefectures <- '
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "prefecture": "北海道"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[141.5, 45.5], [145.5, 45.5], [145.5, 41.5], [141.5, 41.5], [141.5, 45.5]]]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "prefecture": "東京都"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[139.5, 35.8], [140.0, 35.8], [140.0, 35.5], [139.5, 35.5], [139.5, 35.8]]]
      }
    }
  ]
}
'

# 実際には47都道府県すべてのデータが必要です
# このスクリプトでは2つの例だけを示しています
# GeoJSONとして保存
write(japan_prefectures, "../data/japan_prefectures.geojson")

# ========================================
# データベースへの投入（PostgreSQLの例）
# ========================================
# 環境変数からDB接続情報を取得またはデフォルト値を使用
db_host <- Sys.getenv("DB_HOST", "postgres")
db_name <- Sys.getenv("DB_NAME", "shinyapp")
db_user <- Sys.getenv("DB_USER", "postgres")
db_password <- Sys.getenv("DB_PASSWORD", "postgres")
db_port <- as.numeric(Sys.getenv("DB_PORT", "5432"))

# DB接続を試みる
tryCatch({
  # DB接続
  con <- dbConnect(
    Postgres(),
    host = db_host,
    dbname = db_name,
    user = db_user,
    password = db_password,
    port = db_port
  )
  
  # テーブルが存在する場合は削除
  if (dbExistsTable(con, "prefectures")) {
    dbRemoveTable(con, "prefectures")
  }
  if (dbExistsTable(con, "facilities")) {
    dbRemoveTable(con, "facilities")
  }
  
  # テーブル作成と投入
  dbWriteTable(con, "prefectures", population_data)
  dbWriteTable(con, "facilities", facilities_data)
  
  # 接続を閉じる
  dbDisconnect(con)
  
  cat("データベースへの投入が完了しました。\n")
}, error = function(e) {
  cat("データベース接続またはデータ投入に失敗しました。CSVからデータをロードします。\n")
  cat("エラー内容:", e$message, "\n")
})

cat("データ準備が完了しました。\n")
