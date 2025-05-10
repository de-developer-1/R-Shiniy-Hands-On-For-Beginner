-- データベース初期化SQL

-- 既存のテーブルがあれば削除
DROP TABLE IF EXISTS prefectures;
DROP TABLE IF EXISTS facilities;

-- 都道府県テーブルの作成
CREATE TABLE prefectures (
    id SERIAL PRIMARY KEY,
    prefecture VARCHAR(10) NOT NULL,
    region VARCHAR(10) NOT NULL,
    population INTEGER NOT NULL,
    area NUMERIC(10, 2) NOT NULL,
    density NUMERIC(10, 2) NOT NULL
);

-- 施設データテーブルの作成
CREATE TABLE facilities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    address VARCHAR(200) NOT NULL,
    prefecture VARCHAR(10) NOT NULL
);

-- インデックスの作成
CREATE INDEX idx_prefectures_prefecture ON prefectures(prefecture);
CREATE INDEX idx_facilities_prefecture ON facilities(prefecture);
CREATE INDEX idx_facilities_type ON facilities(type);

-- サンプルデータは prepare_data.R スクリプトで投入されます
