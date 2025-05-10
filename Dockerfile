# RStudio Server環境をベースにShinyアプリ開発環境を構築 
FROM rocker/rstudio:4.3.2  

LABEL maintainer="R Shiny Workshop <workshop@example.com>"  

# 必要なシステムライブラリをインストール 
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libudunits2-dev \
    libproj-dev \
    libgeos-dev \
    libsqlite3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*  

# 必要なRパッケージをインストール 
RUN R -e "install.packages(c(\
    'shiny', \
    'rmarkdown', \
    'ggplot2', \
    'dplyr', \
    'readr', \
    'DT', \
    'plotly', \
    'leaflet', \
    'RColorBrewer', \
    'scales', \
    'sf', \
    'shinydashboard', \
    'bs4Dash', \
    'pool', \
    'RPostgres', \
    'jsonlite' \
    ), repos='https://cran.rstudio.com/')"  

# Shinyサーバーをインストール 
RUN apt-get update && apt-get install -y \
    gdebi-core \
    && wget --no-verbose https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb \
    && gdebi -n shiny-server-1.5.20.1002-amd64.deb \
    && rm shiny-server-1.5.20.1002-amd64.deb \
    && rm -rf /var/lib/apt/lists/*  

# アプリケーションディレクトリを作成 
RUN mkdir -p /app  

# Shinyユーザーのアクセス権を設定
RUN mkdir -p /srv/shiny-server
RUN chown -R shiny:shiny /srv/shiny-server

# 作業ディレクトリを設定 
WORKDIR /app  

# シェルスクリプトを追加して起動時にデータを準備 
COPY ./app/scripts/prepare_data.R /app/scripts/  

# ポートを公開 
EXPOSE 8787 3838  

# 起動コマンド (RStudioとShinyサーバーの両方を起動) 
CMD ["/init"]