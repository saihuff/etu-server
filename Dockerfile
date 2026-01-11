# ---------- build stage ----------
FROM debian:bookworm AS builder

WORKDIR /app

# ① まず apt を使える状態にする
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    xz-utils \
    build-essential \
    libgmp-dev \
    libffi-dev \
    zlib1g-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ② stack を入れる
RUN curl -sSL https://get.haskellstack.org/ | sh

# ③ stack 設定だけ先にコピー（キャッシュ効く）
COPY stack.yaml etu-server.cabal ./
RUN stack setup

# ④ 残りをコピーしてビルド
COPY . .
RUN stack build --copy-bins --local-bin-path /app/bin

# ---------- runtime stage ----------
FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libpq5 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/bin/etu-server /app/etu-server

CMD ["/app/etu-server"]

