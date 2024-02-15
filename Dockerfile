# Use an Ubuntu base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

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
    && rm -rf /var/lib/apt/lists/*

# Download and compile zlib for MinGW-w64
RUN wget http://www.zlib.net/zlib-1.3.1.tar.gz -O zlib.tar.gz && \
    tar -xf zlib.tar.gz && \
    cd zlib-1.3.1 && \
    CROSS_PREFIX=x86_64-w64-mingw32- ./configure --static --prefix=/usr/x86_64-w64-mingw32 && \
    make && \
    make install && \
    cd .. && \
    rm -rf zlib-1.3.1 zlib.tar.gz

WORKDIR /usr/src/app

# Download LibNC
RUN wget https://bellard.org/libnc/libnc-2021-04-24.tar.gz --no-check-certificate -O libnc.tar && \
    tar -xf libnc.tar

# Compile LibNC
# Assuming LibNC can be compiled using a similar pattern to zlib.
# Adjust these commands according to the actual build instructions for LibNC.
RUN cd libnc-2021-04-24 && \
    make && \
    cd ..

# Download NNCP package
RUN wget https://bellard.org/nncp/nncp-2023-10-21.tar.gz --no-check-certificate -O nncp.tar --no-check-certificate && \
    tar -xf nncp.tar

WORKDIR /usr/src/app/nncp-2023-10-21

# Compile using MinGW-w64, adjust CPPFLAGS and LDFLAGS as needed for your setup
# Now including LibNC in the linking process
RUN make CC=x86_64-w64-mingw32-gcc \
    CPPFLAGS="-I/usr/x86_64-w64-mingw32/include" \
    LDFLAGS="-L/usr/x86_64-w64-mingw32/lib -static -lz -lnc"

CMD ["echo", "Build complete. Replace this command as needed."]
