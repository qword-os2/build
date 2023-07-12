sudo apt update
sudo apt install -y wget git bash make patch gzip tar nasm ninja-build autoconf bison gperf autopoint help2man rsync parted qemu
pip3 install --user meson xbstrap
git clone https://github.com/qword-os2/qword /workspaces/qword
git clone https://github.com/qword-os2/util-qword /workspaces/util-qword