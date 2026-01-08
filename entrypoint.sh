#!/bin/sh

# 检查 TOKEN
if [ -z "$TUNNEL_TOKEN" ]; then
    echo "Error: TUNNEL_TOKEN is not set."
    exit 1
fi

echo "Starting cloudflared customized watch-dog..."

# 1. 启动 cloudflared
# --protocol http2: 解决 UDP/QUIC 被运营商阻断的问题
# --metrics: 开启健康检查端口
cloudflared tunnel --no-autoupdate --metrics 0.0.0.0:2000 run --token "$TUNNEL_TOKEN" --protocol http2 &
PID=$!

echo "Cloudflared started with PID $PID"
sleep 10

# 2. 死循环守护 (Watchdog)
while true; do
    # 检查进程是否存在
    if ! kill -0 $PID > /dev/null 2>&1; then
        echo "Process died. Exiting..."
        exit 1
    fi

    # 检查网络连接是否 Ready (超时时间 5秒)
    if ! wget -q --spider --timeout=5 http://127.0.0.1:2000/ready; then
        echo "Health check failed! Cloudflared disconnected."
        echo "Killing process to force restart..."
        kill -9 $PID
        exit 1
    fi

    sleep 30
done
