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
    gdebi-core \
    wget && \
    wget --no-verbose https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb && \
    gdebi -n shiny-server-1.5.20.1002-amd64.deb && \
    rm shiny-server-1.5.20.1002-amd64.deb && \
    rm -rf /var/lib/apt/lists/*

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
    'jsonlite',\
    'dbplyr' \
), repos='https://cran.rstudio.com/')"

# 作業ディレクトリを設定
WORKDIR /app

# prepare_data.R をコピー
COPY ./app/scripts/prepare_data.R /app/scripts/

# Shiny アプリ全体をコピー（RStudio/開発環境との整合性のため）
COPY ./app /srv/shiny-server/

# ポートを公開
EXPOSE 8787 3838

# CMD 形式をJSON配列で記述（prepare_data実行後に shiny-server を起動）
CMD ["sh", "-c", "Rscript /app/scripts/prepare_data.R && exec shiny-server"]