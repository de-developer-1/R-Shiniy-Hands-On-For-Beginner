# ========================================
# R Shiny ダッシュボードアプリケーション
# ========================================

# 必要なパッケージの読み込み
library(shiny)
library(bs4Dash)      # モダンなBootstrap 4ベースのダッシュボード
library(ggplot2)      # 基本的な可視化
library(plotly)       # インタラクティブな可視化
library(leaflet)      # 地図可視化
library(DT)           # インタラクティブなデータテーブル
library(dplyr)        # データ操作
library(sf)           # 地理データ処理
library(scales)       # 軸のフォーマット設定
library(RColorBrewer) # カラーパレット
library(pool)         # データベース接続プール

# データベース接続プールを作成（環境変数から接続情報を取得）
# 注：環境変数が設定されてない場合はCSVからロード
setup_db_pool <- function() {
  tryCatch({
    pool <- pool::dbPool(
      RPostgres::Postgres(),
      host = Sys.getenv("DB_HOST", "postgres"),
      dbname = Sys.getenv("DB_NAME", "shinyapp"),
      user = Sys.getenv("DB_USER", "postgres"),
      password = Sys.getenv("DB_PASSWORD", "postgres"),
      port = as.numeric(Sys.getenv("DB_PORT", "5432"))
    )
    return(pool)
  }, error = function(e) {
    message("データベース接続に失敗しました。CSVからデータをロードします。")
    return(NULL)
  })
}
pool <- setup_db_pool()

# データの読み込み
# データベース接続に失敗した場合はCSVからロード
load_data <- function() {
  if (!is.null(pool)) {
    # DBからデータ読み込み
    population_data <- pool %>% 
      dplyr::tbl("prefectures") %>% 
      dplyr::collect()
    
    facilities_data <- pool %>% 
      dplyr::tbl("facilities") %>% 
      dplyr::collect()
  } else {
    # CSVからデータ読み込み
    population_data <- read.csv("data/population.csv", 
                               stringsAsFactors = FALSE, 
                               fileEncoding = "UTF-8")
    
    facilities_data <- read.csv("data/facilities.csv", 
                               stringsAsFactors = FALSE, 
                               fileEncoding = "UTF-8")
  }
  
  # 地理データの読み込み
  japan_map <- sf::st_read("data/japan_prefectures.geojson", quiet = TRUE)
  
  return(list(
    population = population_data, 
    facilities = facilities_data,
    map = japan_map
  ))
}

data <- load_data()

# UI定義
ui <- bs4DashPage(
  dark = FALSE,
  help = FALSE,
  title = "R Shiny ハンズオン",
  
  # ヘッダー部分
  header = bs4DashNavbar(
    title = bs4DashBrand(
      title = "R Shiny ハンズオン",
      color = "primary"
    ),
    skin = "light",
    status = "white",
    border = TRUE,
    rightUi = tagList(
      dropdownMenu(
        type       = "notifications",          # 通知メニュー
        badgeStatus= "warning",                # Badget の色
        icon       = icon("info-circle"),      # アイコン
        headerText = NULL,                     # ヘッダーにテキストを出さない
        # .list  = NULL,                       # プログラム動的生成の場合は .list も可
        notificationItem(
          text   = "このアプリはデモ用です",   # 通知本文
          status = "info",                     # 通知バッジの色
          icon   = icon("info")                # 通知アイコン
        )
      )
    )
  ),
  
  # サイドバー部分
  sidebar = bs4DashSidebar(
    skin = "light",
    status = "primary",
    elevation = 3,
    bs4SidebarMenu(
      id = "sidebar",
      bs4SidebarMenuItem(
        "ホーム",
        tabName = "home",
        icon = icon("home")
      ),
      bs4SidebarMenuItem(
        "基本可視化",
        tabName = "basic",
        icon = icon("chart-bar")
      ),
      bs4SidebarMenuItem(
        "インタラクティブ",
        tabName = "interactive",
        icon = icon("chart-line")
      ),
      bs4SidebarMenuItem(
        "地理データ",
        tabName = "geo",
        icon = icon("map")
      )
    )
  ),
  
  # メインコンテンツ部分
  body = bs4DashBody(
    bs4TabItems(
      # ホームタブ
      bs4TabItem(
        tabName = "home",
        fluidRow(
          bs4Card(
            title = "R Shiny ハンズオンへようこそ",
            status = "primary",
            width = 12,
            solidHeader = TRUE,
            collapsible = FALSE,
            h3("このアプリケーションについて"),
            p("このShinyアプリケーションは、R Shinyの基本的な使い方とインタラクティブな可視化方法を学ぶためのハンズオン教材です。"),
            h4("学習内容"),
            tags$ul(
              tags$li("基本的なデータ可視化（ggplot2）"),
              tags$li("インタラクティブな可視化（plotly, DT）"),
              tags$li("地理データの可視化（leaflet）"),
              tags$li("モダンなダッシュボードUI設計（bs4Dash）")
            ),
            p("左側のサイドバーから各セクションを選択して、学習を始めましょう。")
          )
        ),
        fluidRow(
          bs4InfoBox(
            title = "基本可視化",
            value = "ggplot2",
            icon = icon("chart-bar"),
            color = "info",
            width = 4
          ),
          bs4InfoBox(
            title = "インタラクティブ",
            value = "plotly & DT",
            icon = icon("chart-line"),
            color = "success",
            width = 4
          ),
          bs4InfoBox(
            title = "地理データ",
            value = "leaflet",
            icon = icon("map"),
            color = "warning",
            width = 4
          )
        )
      ),
      
      # 基本可視化タブ
      bs4TabItem(
        tabName = "basic",
        fluidRow(
          bs4Card(
            title = "基本的な可視化（ggplot2）",
            width = 12,
            status = "info",
            solidHeader = TRUE,
            p("ggplot2を使って基本的なグラフを作成します。色々な種類のグラフを試してみましょう。"),
            selectInput("plotType", "グラフの種類:", 
                        choices = c("棒グラフ", "折れ線グラフ", "散布図", "箱ひげ図"),
                        selected = "棒グラフ"),
            plotOutput("basicPlot")
          )
        ),
        fluidRow(
          bs4Card(
            title = "ggplot2 コードサンプル",
            width = 12,
            status = "primary",
            collapsed = TRUE,
            collapsible = TRUE,
            verbatimTextOutput("ggplotCode")
          )
        )
      ),
      
      # インタラクティブタブ
      bs4TabItem(
        tabName = "interactive",
        fluidRow(
          bs4Card(
            title = "インタラクティブな可視化（plotly）",
            width = 6,
            status = "success",
            solidHeader = TRUE,
            p("plotlyを使ったインタラクティブなグラフです。マウスオーバーで値の確認、ズームやパンが可能です。"),
            plotlyOutput("plotlyPlot", height = "400px")
          ),
          bs4Card(
            title = "データテーブル（DT）",
            width = 6,
            status = "success",
            solidHeader = TRUE,
            p("DTパッケージを使ったインタラクティブなデータテーブルです。ソート、検索、ページング機能があります。"),
            DTOutput("dataTable")
          )
        ),
        fluidRow(
          bs4Card(
            title = "plotly コードサンプル",
            width = 6,
            status = "primary",
            collapsed = TRUE,
            collapsible = TRUE,
            verbatimTextOutput("plotlyCode")
          ),
          bs4Card(
            title = "DT コードサンプル",
            width = 6,
            status = "primary",
            collapsed = TRUE,
            collapsible = TRUE,
            verbatimTextOutput("dtCode")
          )
        )
      ),
      
      # 地理データタブ
      bs4TabItem(
        tabName = "geo",
        fluidRow(
          bs4Card(
            title = "地理データの可視化（leaflet）",
            width = 12,
            status = "warning",
            solidHeader = TRUE,
            p("leafletを使って日本地図上に都道府県別データを表示しています。"),
            radioButtons("mapData", "表示データ:", 
                         choices = c("人口", "施設数"),
                         selected = "人口", 
                         inline = TRUE),
            leafletOutput("map", height = "600px")
          )
        ),
        fluidRow(
          bs4Card(
            title = "leaflet コードサンプル",
            width = 12,
            status = "primary",
            collapsed = TRUE,
            collapsible = TRUE,
            verbatimTextOutput("leafletCode")
          )
        )
      )
    )
  ),
  
  # フッター部分
  footer = bs4DashFooter(
    fixed = FALSE,
    right = p("R Shiny ハンズオン © 2025"),
    left = a(href = "https://github.com/", target = "_blank", "GitHub")
  )
)

# サーバーロジック定義
server <- function(input, output, session) {
  
  # 基本可視化タブ - ggplot2グラフ
  output$basicPlot <- renderPlot({
    pop_data <- data$population
    
    # 人口トップ10の都道府県を取得
    top_prefs <- pop_data %>%
      arrange(desc(population)) %>%
      head(10)
    
    # グラフの種類に応じて異なるグラフを作成
    if (input$plotType == "棒グラフ") {
      # 棒グラフ
      ggplot(top_prefs, aes(x = reorder(prefecture, -population), y = population/10000, fill = region)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels = function(x) paste0(x, "万人")) +
        labs(title = "都道府県別人口（上位10）",
             x = "都道府県", 
             y = "人口") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else if (input$plotType == "折れ線グラフ") {
      # 折れ線グラフ（地域別の累積人口）
      pop_data %>%
        group_by(region) %>%
        summarise(total_pop = sum(population)/10000) %>%
        ggplot(aes(x = reorder(region, -total_pop), y = total_pop, group = 1)) +
        geom_line(size = 1, color = "steelblue") +
        geom_point(size = 3, color = "steelblue") +
        scale_y_continuous(labels = function(x) paste0(x, "万人")) +
        labs(title = "地域別総人口",
             x = "地域", 
             y = "人口総計") +
        theme_minimal()
        
    } else if (input$plotType == "散布図") {
      # 散布図（人口と面積の関係）
      ggplot(pop_data, aes(x = area, y = population/10000, color = region)) +
        geom_point(alpha = 0.7, size = 3) +
        scale_y_continuous(labels = function(x) paste0(x, "万人")) +
        scale_x_continuous(labels = function(x) paste0(x, "km²")) +
        labs(title = "都道府県別 人口と面積の関係",
             x = "面積", 
             y = "人口") +
        theme_minimal()
        
    } else if (input$plotType == "箱ひげ図") {
      # 箱ひげ図（地域別の人口分布）
      ggplot(pop_data, aes(x = region, y = population/10000, fill = region)) +
        geom_boxplot() +
        scale_y_continuous(labels = function(x) paste0(x, "万人")) +
        labs(title = "地域別 人口分布",
             x = "地域", 
             y = "人口") +
        theme_minimal() +
        theme(legend.position = "none")
    }
  })
  
  # 基本可視化タブ - コードサンプル表示
  output$ggplotCode <- renderText({
    if (input$plotType == "棒グラフ") {
      return(
'# 棒グラフのコード例
ggplot(top_prefs, aes(x = reorder(prefecture, -population), y = population/10000, fill = region)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = function(x) paste0(x, "万人")) +
  labs(title = "都道府県別人口（上位10）",
       x = "都道府県", 
       y = "人口") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))'
      )
    } else if (input$plotType == "折れ線グラフ") {
      return(
'# 折れ線グラフのコード例
pop_data %>%
  group_by(region) %>%
  summarise(total_pop = sum(population)/10000) %>%
  ggplot(aes(x = reorder(region, -total_pop), y = total_pop, group = 1)) +
  geom_line(size = 1, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  scale_y_continuous(labels = function(x) paste0(x, "万人")) +
  labs(title = "地域別総人口",
       x = "地域", 
       y = "人口総計") +
  theme_minimal()'
      )
    } else if (input$plotType == "散布図") {
      return(
'# 散布図のコード例
ggplot(pop_data, aes(x = area, y = population/10000, color = region)) +
  geom_point(alpha = 0.7, size = 3) +
  scale_y_continuous(labels = function(x) paste0(x, "万人")) +
  scale_x_continuous(labels = function(x) paste0(x, "km²")) +
  labs(title = "都道府県別 人口と面積の関係",
       x = "面積", 
       y = "人口") +
  theme_minimal()'
      )
    } else if (input$plotType == "箱ひげ図") {
      return(
'# 箱ひげ図のコード例
ggplot(pop_data, aes(x = region, y = population/10000, fill = region)) +
  geom_boxplot() +
  scale_y_continuous(labels = function(x) paste0(x, "万人")) +
  labs(title = "地域別 人口分布",
       x = "地域", 
       y = "人口") +
  theme_minimal() +
  theme(legend.position = "none")'
      )
    }
  })
  
  # インタラクティブタブ - plotlyプロット
  output$plotlyPlot <- renderPlotly({
    pop_data <- data$population %>%
      arrange(desc(population)) %>%
      head(15)
    
    p <- ggplot(pop_data, aes(x = reorder(prefecture, -population), y = population/10000, fill = region, 
                             text = paste0("都道府県: ", prefecture, 
                                          "<br>人口: ", format(population, big.mark = ","), "人",
                                          "<br>地域: ", region))) +
      geom_bar(stat = "identity") +
      labs(title = "都道府県別人口（上位15）", x = "都道府県", y = "人口（万人）") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    # ggplotからplotlyに変換、ツールチップをカスタマイズ
    ggplotly(p, tooltip = "text") %>%
      layout(hoverlabel = list(bgcolor = "white", font = list(family = "sans-serif")))
  })
  
  # インタラクティブタブ - データテーブル
  output$dataTable <- renderDT({
    # DTでデータテーブルを作成
    data$population %>%
      select(prefecture, region, population, area, density) %>%
      mutate(
        population = format(population, big.mark = ","),
        area = paste0(format(area, big.mark = ","), " km²"),
        density = paste0(format(round(density, 1), big.mark = ","), " 人/km²")
      ) %>%
      datatable(
        colnames = c("都道府県", "地域", "人口", "面積", "人口密度"),
        options = list(
          pageLength = 8,
          language = list(
            url = '//cdn.datatables.net/plug-ins/1.10.25/i18n/Japanese.json'
          )
        ),
        rownames = FALSE
      ) %>%
      formatStyle(
        'region',
        backgroundColor = styleEqual(
          unique(data$population$region),
          colorRampPalette(brewer.pal(8, "Pastel1"))(length(unique(data$population$region)))
        )
      )
  })
  
  # インタラクティブタブ - コードサンプル表示
  output$plotlyCode <- renderText({
'# plotlyを使ったインタラクティブグラフのコード例
# まずggplotでベースを作り、それをplotlyに変換
p <- ggplot(pop_data, aes(x = reorder(prefecture, -population), y = population/10000, fill = region, 
                         text = paste0("都道府県: ", prefecture, 
                                      "<br>人口: ", format(population, big.mark = ","), "人",
                                      "<br>地域: ", region))) +
  geom_bar(stat = "identity") +
  labs(title = "都道府県別人口（上位15）", x = "都道府県", y = "人口（万人）") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ggplotからplotlyに変換、ツールチップをカスタマイズ
ggplotly(p, tooltip = "text") %>%
  layout(hoverlabel = list(bgcolor = "white", font = list(family = "sans-serif")))'
  })
  
  output$dtCode <- renderText({
'# DTを使ったインタラクティブテーブルのコード例
data$population %>%
  select(prefecture, region, population, area, density) %>%
  mutate(
    population = format(population, big.mark = ","),
    area = paste0(format(area, big.mark = ","), " km²"),
    density = paste0(format(round(density, 1), big.mark = ","), " 人/km²")
  ) %>%
  datatable(
    colnames = c("都道府県", "地域", "人口", "面積", "人口密度"),
    options = list(
      pageLength = 8,
      language = list(
        url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Japanese.json"
      )
    ),
    rownames = FALSE
  ) %>%
  formatStyle(
    "region",
    backgroundColor = styleEqual(
      unique(data$population$region),
      colorRampPalette(brewer.pal(8, "Pastel1"))(length(unique(data$population$region)))
    )
  )'
  })
  
  # 地理データタブ - 地図
  output$map <- renderLeaflet({
    # 表示するデータを選択
    mapData <- data$map
    
    if (input$mapData == "人口") {
      # 人口データを結合
      mapData <- mapData %>%
        left_join(data$population, by = c("prefecture" = "prefecture"))
      
      # カラーパレットを作成
      pal <- colorNumeric(palette = "YlOrRd", domain = mapData$population)
      
      # 地図作成
      leaflet() %>%
        addTiles() %>%
        setView(lng = 136.0, lat = 38.0, zoom = 5) %>%
        addPolygons(
          data = mapData,
          fillColor = ~pal(population),
          weight = 1,
          opacity = 1,
          color = "white",
          fillOpacity = 0.7,
          highlight = highlightOptions(
            weight = 2,
            color = "#666",
            fillOpacity = 0.7,
            bringToFront = TRUE
          ),
          popup = ~paste0(
            "<strong>", prefecture, "</strong><br>",
            "人口: ", format(population, big.mark = ","), "人<br>",
            "面積: ", format(area, big.mark = ","), "km²<br>",
            "人口密度: ", format(round(density, 1), big.mark = ","), "人/km²"
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal,
          values = mapData$population,
          title = "人口",
          labFormat = labelFormat(suffix = "人", big.mark = ",")
        )
    } else {
      # 施設データを集計して結合
      facilities_count <- data$facilities %>%
        group_by(prefecture) %>%
        summarise(facility_count = n())
      
      mapData <- mapData %>%
        left_join(facilities_count, by = c("prefecture" = "prefecture"))
      
      # NAを0に置換
      mapData$facility_count[is.na(mapData$facility_count)] <- 0
      
      # カラーパレットを作成
      pal <- colorNumeric(palette = "Blues", domain = mapData$facility_count)
      
      # 地図作成
      leaflet() %>%
        addTiles() %>%
        setView(lng = 136.0, lat = 38.0, zoom = 5) %>%
        addPolygons(
          data = mapData,
          fillColor = ~pal(facility_count),
          weight = 1,
          opacity = 1,
          color = "white",
          fillOpacity = 0.7,
          highlight = highlightOptions(
            weight = 2,
            color = "#666",
            fillOpacity = 0.7,
            bringToFront = TRUE
          ),
          popup = ~paste0(
            "<strong>", prefecture, "</strong><br>",
            "施設数: ", format(facility_count, big.mark = ","), "施設"
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal,
          values = mapData$facility_count,
          title = "施設数",
          labFormat = labelFormat(suffix = "施設", big.mark = ",")
        ) %>%
        # 施設の位置をプロットする（あれば）
        addCircleMarkers(
          data = data$facilities,
          lng = ~longitude,
          lat = ~latitude,
          radius = 5,
          color = "darkblue",
          fillColor = "blue",
          fillOpacity = 0.6,
          weight = 1,
          popup = ~paste0(
            "<strong>", name, "</strong><br>",
            "種類: ", type, "<br>",
            "住所: ", address
          ),
          clusterOptions = markerClusterOptions()
        )
    }
  })
  
  # 地理データタブ - コードサンプル表示
  output$leafletCode <- renderText({
'# leafletを使った地図可視化のコード例
# 人口データの場合
mapData <- japan_map %>%
  left_join(population_data, by = c("prefecture" = "prefecture"))

# カラーパレットを作成
pal <- colorNumeric(palette = "YlOrRd", domain = mapData$population)

# 地図作成
leaflet() %>%
  addTiles() %>%
  setView(lng = 136.0, lat = 38.0, zoom = 5) %>%
  addPolygons(
    data = mapData,
    fillColor = ~pal(population),
    weight = 1,
    opacity = 1,
    color = "white",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 2,
      color = "#666",
      fillOpacity = 0.7,
      bringToFront = TRUE
    ),
    popup = ~paste0(
      "<strong>", prefecture, "</strong><br>",
      "人口: ", format(population, big.mark = ","), "人<br>",
      "面積: ", format(area, big.mark = ","), "km²<br>",
      "人口密度: ", format(round(density, 1), big.mark = ","), "人/km²"
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal,
    values = mapData$population,
    title = "人口",
    labFormat = labelFormat(suffix = "人", big.mark = ",")
  )'
  })
  
  # DBプールを終了する時のイベントハンドラ
  onStop(function() {
    if (!is.null(pool)) {
      poolClose(pool)
    }
  })
}

# Shinyアプリを実行
shinyApp(ui, server)
