# Stage 1: Build environment
FROM nvidia/cuda:11.5.1-devel-ubuntu20.04 AS builder

# Set noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y ffmpeg git curl

WORKDIR /app

# Install Python dependencies for building
COPY requirements.txt .
RUN apt-get install -y python3-dev && \
    apt-get install -y python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

# Clone fairseq and install
RUN git clone https://github.com/pytorch/fairseq && \
    cd /app/fairseq && \
    pip3 install --editable ./ && \
    pip3 install tensorboardX

# Download the model using curl
RUN mkdir -p /app/fairseq/models_new && \
    curl -L -o /app/fairseq/models_new/mms1b_fl102.pt 'https://dl.fbaipublicfiles.com/mms/asr/mms1b_fl102.pt'


# Stage 2: Runtime environment
FROM nvidia/cuda:11.5.1-runtime-ubuntu20.04

# Set noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y ffmpeg

WORKDIR /app

# Copy Python dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages
COPY --from=builder /usr/local/bin/fairseq-* /usr/local/bin/

# Set environment variables
ENV TMPDIR /temp_dir
ENV PYTHONPATH .
ENV PREFIX INFER
ENV HYDRA_FULL_ERROR 1
ENV USER micro

# Create directory
RUN mkdir /temp_dir

# Copy the rest of the code
COPY . /app

CMD ["python", "/app/api.py"]

