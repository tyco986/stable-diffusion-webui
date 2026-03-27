# Stable Diffusion WebUI (AUTOMATIC1111) — Ubuntu 22.04, 国内镜像: apt / pip / git / Hugging Face
# 构建: docker build -t sd-webui:cn .
# 运行(需本机 NVIDIA Container Toolkit): docker run --gpus all -p 2222:2222 -p 22222:22 sd-webui:cn
#
# 可选构建参数:
#   --build-arg APT_MIRROR=mirrors.aliyun.com
#   --build-arg TYCO_PASSWORD=你的密码

ARG APT_MIRROR=mirrors.aliyun.com
ARG TYCO_PASSWORD=0

FROM ubuntu:22.04

ARG APT_MIRROR
ARG TYCO_PASSWORD

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---------------------------------------------------------------------------
# apt: 阿里云 Ubuntu 镜像
# ---------------------------------------------------------------------------
RUN sed -i "s|http://archive.ubuntu.com/ubuntu|http://${APT_MIRROR}/ubuntu|g" /etc/apt/sources.list && \
    sed -i "s|http://security.ubuntu.com/ubuntu|http://${APT_MIRROR}/ubuntu|g" /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      wget \
      bc \
      python3.10 \
      python3.10-venv \
      python3-pip \
      python3.10-dev \
      build-essential \
      libgl1 \
      libglib2.0-0 \
      libgoogle-perftools4 \
      openssh-server \
      gosu \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# pip: 清华 PyPI（全局 /etc/pip.conf，venv 内 pip 也会读）
# ---------------------------------------------------------------------------
RUN printf '%s\n' \
      '[global]' \
      'index-url = https://pypi.tuna.tsinghua.edu.cn/simple' \
      'trusted-host = pypi.tuna.tsinghua.edu.cn' \
      'timeout = 120' \
    > /etc/pip.conf

ENV PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn \
    PIP_DEFAULT_TIMEOUT=120

# ---------------------------------------------------------------------------
# git: GitHub 经 ghproxy 加速（失效时可换 gitclone / 自建反代）
# ---------------------------------------------------------------------------
RUN git config --system url."https://mirror.ghproxy.com/https://github.com/".insteadOf "https://github.com/"

# ---------------------------------------------------------------------------
# Hugging Face: 国内常用镜像端点（模型下载、部分依赖）
# ---------------------------------------------------------------------------
ENV HF_ENDPOINT=https://hf-mirror.com \
    HUGGINGFACE_HUB_CACHE=/opt/stable-diffusion-webui/.cache/huggingface

# PyTorch：见 webui-user.sh 中 TORCH_COMMAND（默认同官方 cu128）；国内慢可改为清华/阿里 wheel 源且与 CUDA 一致

# ---------------------------------------------------------------------------
# 应用用户与代码
# ---------------------------------------------------------------------------
RUN useradd -m -s /bin/bash tyco && \
    echo "tyco:${TYCO_PASSWORD}" | chpasswd && \
    mkdir -p /home/tyco/.pip && cp /etc/pip.conf /home/tyco/.pip/pip.conf && \
    chown -R tyco:tyco /home/tyco/.pip

COPY --chown=tyco:tyco . /opt/stable-diffusion-webui

WORKDIR /opt/stable-diffusion-webui

# sshd 配置：允许密码登录（仅内网/开发用；公网请改密钥并加固）
RUN mkdir -p /var/run/sshd && \
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^session\s\+required\s\+pam_loginuid.so/session optional pam_loginuid.so/' /etc/pam.d/sshd

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 2222 22

# 入口以 root 起 sshd，再用 gosu 以 tyco 跑 webui.sh（脚本本身禁止 root）
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["./webui.sh"]
