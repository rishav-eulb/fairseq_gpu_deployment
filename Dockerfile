FROM python:3.8
#FROM nvidia/cuda:11.5.1-devel-ubuntu20.04
# Install dependencies
RUN apt-get update && apt-get install -y ffmpeg git

WORKDIR /app

# Install python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Clone fairseq and install
RUN git clone https://github.com/pytorch/fairseq /app/fairseq && \
    cd /app/fairseq && \
    pip install --editable ./ && \
    pip install tensorboardX

# Download the model
RUN cd /app/fairseq && \
    wget -P ./models_new 'https://dl.fbaipublicfiles.com/mms/asr/mms1b_fl102.pt'

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