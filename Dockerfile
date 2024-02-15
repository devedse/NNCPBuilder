# Use an Ubuntu base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
	apt-get update && \
    apt install wine wine32 wine64 libwine libwine:i386 fonts-wine -y

# Install MinGW-w64, wget to download the source, make, gcc, g++, tar, and other build essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mingw-w64 \
    make \
    gcc \
    g++ \
    wget \
    tar \
    xz-utils \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download and compile zlib for MinGW-w64
RUN wget http://www.zlib.net/zlib-1.3.1.tar.gz -O zlib.tar.gz && \
    tar -xf zlib.tar.gz && \
    cd zlib-1.3.1 && \
    CROSS_PREFIX=x86_64-w64-mingw32- ./configure --static --prefix=/usr/x86_64-w64-mingw32 && \
    make && \
    make install && \
    cd .. && \
    rm zlib.tar.gz

WORKDIR /usr/src/app

# Download NNCP package
RUN wget https://bellard.org/nncp/nncp-2023-10-21.tar.gz --no-check-certificate -O nncp.tar --no-check-certificate && \
    tar -xf nncp.tar && rm nncp.tar

RUN wget https://bellard.org/nncp/nncp-2023-10-21-win64.zip --no-check-certificate -O nncp-win64.zip && \
    unzip nncp-win64.zip -d nncp-win64 && \
    cp nncp-win64/*.dll /usr/src/app/nncp-2023-10-21/ && \
    rm -rf nncp-win64 nncp-win64.zip

WORKDIR /usr/src/app/nncp-2023-10-21

# Compile using MinGW-w64, adjust CPPFLAGS and LDFLAGS as needed for your setup
# Now including LibNC in the linking process
RUN make CONFIG_WIN32=y CC=x86_64-w64-mingw32-gcc

# CMD ["echo", "Build complete. Replace this command as needed."]
