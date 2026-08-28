FROM python:3.13-alpine

# 安装必要的依赖（如果你的 requirements 包含依赖 C 编译的库）
RUN adduser -D user
USER user

WORKDIR /opt/rdgen

# 优先单独 COPY requirements.txt，利用 Docker 缓存加速依赖安装
COPY --chown=user:user requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 再 COPY 剩下的项目代码
COPY --chown=user:user . .

ENV PYTHONUNBUFFERED=1

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget --spider http://127.0.0.1:8000/ || exit 1

# 启动时先做 migrate，再启动 gunicorn
CMD ["sh", "-c", "python manage.py migrate && /home/user/.local/bin/gunicorn -c gunicorn.conf.py rdgen.wsgi:application"]
