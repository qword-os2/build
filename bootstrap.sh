#!/usr/bin/env bash

DEFAULT_IMAGE_SIZE=4096

set -e

if [ -z "$1" ]; then
    echo "Usage: ./bootstrap.sh BUILD_DIRECTORY [IMAGE_SIZE_MB]"
    exit 0
fi

# Accepted host OSes else fail.
OS=$(uname)
if ! [ "$OS" = "Linux" ] && ! [ "$OS" = "FreeBSD" ]; then
    echo "Host OS \"$OS\" is not supported."
    exit 1
fi

# Image size in MiB
if [ -z "$2" ]; then
    IMGSIZE=$DEFAULT_IMAGE_SIZE
else
    IMGSIZE="$2"
fi

# Make sure BUILD_DIR is absolute
BUILD_DIR="$(realpath $1)"

# qword repo
QWORD_DIR="$(pwd)/qword"
QWORD_REPO=https://github.com/qword-os2/qword.git

# Add toolchain to PATH
PATH="$BUILD_DIR/tools/cross-binutils/bin:$PATH"
PATH="$BUILD_DIR/tools/system-gcc/bin:$PATH"

set -x

[ -d "$QWORD_DIR" ] || git clone "$QWORD_REPO" "$QWORD_DIR"
make -C "$QWORD_DIR" CC="x86_64-qword-gcc"

if ! [ -f ./qword.hdd ]; then
    dd if=/dev/zero bs=1M count=0 seek=$IMGSIZE of=qword.hdd

    case "$OS" in
        "FreeBSD")
            sudo mdconfig -a -t vnode -f qword.hdd -u md9
            sudo gpart create -s mbr md9
            sudo gpart add -a 4k -t '!14' md9
            sudo mdconfig -d -u md9
            ;;
        "Linux")
            parted -s qword.hdd mklabel msdos
            parted -s qword.hdd mkpart primary 1 100%
            ;;
    esac

    echfs-utils -m -p0 qword.hdd quick-format 32768
fi

# Install limine
if ! [ -d limine ]; then
    git clone https://github.com/limine-bootloader/limine.git --depth=1 --branch=v0.6.3
fi
make -C limine limine-install
limine/limine-install limine/limine.bin qword.hdd

# Prepare root
install -m 644 qword/qword.elf root/
install -m 644 /etc/localtime root/etc/
install -d root/lib
install "$BUILD_DIR/system-root/usr/lib/ld.so" root/lib/

mkdir -p mnt

if [ "$USE_FUSE" = "no" ]; then
    ./copy-root-to-img.sh "$BUILD_DIR"/system-root qword.hdd 0
    ./copy-root-to-img.sh root qword.hdd 0
else
    echfs-fuse --mbr -p0 qword.hdd mnt
    while ! rsync -ru --copy-links --info=progress2 "$BUILD_DIR"/system-root/* mnt; do
        true
    done # FIXME: This while loop only exists because of an issue in echfs-fuse that makes it fail randomly.
    sync
    rsync -ru --copy-links --info=progress2 root/* mnt
    sync
    fusermount -u mnt/
    rm -rf ./mnt
fi
