#!/bin/bash
set -e
cd /opt/stable-diffusion-webui

# root: OpenSSH（供宿主机 -p 映射 22）
if command -v sshd >/dev/null 2>&1; then
  mkdir -p /run/sshd && chmod 0755 /run/sshd
  if ! pgrep -x sshd >/dev/null 2>&1; then
    /usr/sbin/sshd || true
  fi
fi

# webui.sh 禁止以 root 运行
exec gosu tyco "$@"
