FROM alpine:latest

# Buildx 会自动填充这个参数 (如 amd64, arm64)
ARG TARGETARCH

# 安装基础工具
RUN apk add --no-cache curl wget ca-certificates libc6-compat gcompat

# 根据架构动态下载对应版本的 Cloudflared
# 注意：Cloudflare 官方命名规则为 cloudflared-linux-amd64 或 cloudflared-linux-arm64
RUN echo "Building for architecture: $TARGETARCH" && \
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH} -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV TUNNEL_METRICS="0.0.0.0:2000"

ENTRYPOINT ["/entrypoint.sh"]
