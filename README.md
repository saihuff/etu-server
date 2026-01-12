## etu-server

# 構成

app/
├── Config.hs <- 設定
├── DataSource
│   └── Fetch.hs <- 他サーバとの通信
├── Domain
│   ├── Transform.hs <- データ整形
│   ├── Types
│   │   ├── Menu.hs <- Menu関連の型
│   │   ├── TimeTable.hs <- TimeTable関連の型
│   │   └── Train.hs <- Train関連の型
│   └── Types.hs <- 一般的な型
├── Main.hs <- 主要な
└── UseCase
    └── AggreData.hs <- 必要なデータを抜き出す関数
