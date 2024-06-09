# 使用NVIDIA CUDA基础镜像
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# 设置非交互方式安装
ENV DEBIAN_FRONTEND=noninteractive

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖库，包括 git-lfs 和 CUDA 编译器
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    wget \
    git \
    git-lfs \
    bzip2 \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /root/miniconda.sh && \
    /bin/bash /root/miniconda.sh -b -p /opt/conda && \
    rm /root/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    /opt/conda/bin/conda init && \
    echo "conda activate base" >> /root/.bashrc

RUN  echo 'export LD_LIBRARY_PATH=/opt/conda/envs/rlgpu/lib/:$LD_LIBRARY_PATH' >> /root/.bashrc

# 更新环境变量
ENV PATH /opt/conda/bin:$PATH

# 复制 Conda 环境配置文件
COPY environment.yml /app/

# 创建并激活 Conda 环境
RUN conda env create -f /app/environment.yml && conda clean -a
ENV CONDA_DEFAULT_ENV=rlgpu
ENV PATH /opt/conda/envs/rlgpu/bin:$PATH

# 设置CUDA环境变量
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# 使用指定的 shell
SHELL ["conda", "run", "-n", "rlgpu", "/bin/bash", "-c"]


ENV TORCH_CUDA_ARCH_LIST "5.2 6.0 6.1 7.0 7.5 8.0 8.6+PTX"  

# 克隆 cuRobo 仓库并安装依赖项
RUN git clone https://github.com/NVlabs/curobo.git /app/curobo && \
    cd /app/curobo && \
    pip install -e . --no-build-isolation

# 复制并安装 isaacgym 依赖项
COPY isaacgym /app/isaacgym
RUN cd /app/isaacgym/python && pip install -e .

# 安装OpenCV
RUN pip install opencv-python-headless

# 复制当前目录内容到工作目录中
COPY . /app

# 暴露端口（如果你的应用需要）
EXPOSE 8000

# 设置启动命令
# CMD ["conda", "run", "--no-capture-output", "-n", "rlgpu", "python", "human_manipulation.py"]