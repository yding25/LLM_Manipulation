# 使用基础镜像 python:3.7
FROM python:3.7

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 文件并安装依赖
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt || true

# 克隆并安装 isaacgym 依赖项
RUN git clone https://github.com/yding25/LLM_articulated_object_manipulation.git /app/isaacgym \
    && cd /app/isaacgym/isaacgym/python \
    && ls -la  # 添加此行以查看目录内容，调试路径问题
RUN cd /app/isaacgym/isaacgym/python && pip install .

# 复制当前目录内容到工作目录中
COPY . /app

# 暴露端口（如果你的应用需要）
EXPOSE 8000

# 设置默认命令来运行你的应用
CMD ["python", "app/main.py"]