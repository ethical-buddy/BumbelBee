#!/bin/bash

# Define variables
TARGET="x86_64-elf"
PREFIX="/usr/local/$TARGET"
GCC_VERSION="13.2.0"
BINUTILS_VERSION="2.41"
JOBS=$(nproc)

# Update and install prerequisites
echo "Installing prerequisites..."
sudo apt update
sudo apt install -y build-essential libgmp-dev libmpfr-dev libmpc-dev flex bison texinfo wget curl

# Create a working directory
WORKDIR="$HOME/cross-toolchain"
mkdir -p $WORKDIR
cd $WORKDIR

# Download Binutils
echo "Downloading Binutils $BINUTILS_VERSION..."
wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
tar -xvzf binutils-$BINUTILS_VERSION.tar.gz

# Build and install Binutils
echo "Building Binutils..."
mkdir -p build-binutils
cd build-binutils
../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix=$PREFIX --disable-nls --disable-werror
make -j$JOBS
sudo make install
cd ..

# Download GCC
echo "Downloading GCC $GCC_VERSION..."
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
tar -xvzf gcc-$GCC_VERSION.tar.gz

# Download GCC prerequisites
cd gcc-$GCC_VERSION
./contrib/download_prerequisites
cd ..

# Build and install GCC
echo "Building GCC..."
mk
dir -p build-gcc
cd build-gcc
../gcc-$GCC_VERSION/configure --target=$TARGET --prefix=$PREFIX --enable-languages=c,c++ --disable-nls --without-headers
make all-gcc -j$JOBS
make all-target-libgcc -j$JOBS
sudo make install-gcc
sudo make install-target-libgcc

# Verify installation
echo "Verifying installation..."
$PREFIX/bin/$TARGET-gcc --version

# Add cross-compiler to PATH
if ! grep -q "$PREFIX/bin" ~/.bashrc; then
    echo "Adding cross-compiler to PATH..."
    echo "export PATH=\$PATH:$PREFIX/bin" >> ~/.bashrc
    source ~/.bashrc
fi

echo "x86_64-elf cross-compilation toolchain installation complete!"

