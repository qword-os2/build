# qword - A KISS Unix-like operating system, written in C and Assembly for x86_64.

![Reference screenshot](/screenshot.png?raw=true "Reference screenshot")

## THIS PROJECT IS NOT DEFUNCT.
I see Qword2 as the "unofficial" second version of https://github.com/qword-os/. All thanks goes to the original contributors.

Please do send PRs or open issues against this project which looked at.

You're free to check out the code, fork it, and all that, as long as the license
(LICENSE.md) is respected.

## Build requirements
**A devcontainer which has all requirements installed! Please skip to [Building](#building) if you have loaded the container.**

In order to build qword, make sure to have the following installed:
 `wget`, `git`, `bash`, `make` (`gmake` on FreeBSD), `patch`,
 `meson` (from pip3), `ninja-build`, `xz`, `gzip`, `tar`,
 `texinfo` , `gcc/g++` (8 or higher), `nasm`, `autoconf`,
 `bison`, `gperf`, `autopoint`, `help2man`,
 `libfuse-dev` (on Linux), `rsync` (on Linux),
 `parted` (on Linux), and `qemu-system-x86` (to test it).

The echfs utilities are necessary to build the image. Install them:
```bash
git clone https://github.com/echfs/echfs.git
cd echfs
make
# This will install echfs-utils in /usr/local
sudo make install
```

And finally, make sure you have `xbstrap`. You can install it from `pip3`:
```bash
sudo pip3 install xbstrap
```

## Building
```bash
# Clone this repo wherever you like
git clone https://github.com/qword-os2/build.git qword-build
cd qword-build
# Create and enter a "build" directory inside
mkdir build && cd build
# Initialise xbstrap and start a full build
xbstrap init ..
xbstrap install --all
# Enter the root directory of the repo
cd ..
# Create the image using the bootstrap.sh script
MAKEFLAGS="-j4" ./bootstrap.sh build
# If your platform doesnt support fuse (e.g. devcontainer), you can use.
MAKEFLAGS="-j4" USE_FUSE=no ./bootstrap.sh build
```

Some MAKEFLAGS that can be useful are:
```bash
MAKEFLAGS="-j8" ./bootstrap.sh build  # For parallelism
MAKEFLAGS="DBGOUT=qemu -j8" ./bootstrap.sh build  # For QEMU console debug output
DBGOUT=tty    # For kernel tty debug output
DBGOUT=both   # For both of the above
DBGSYM=yes    # For compilation with debug symbols and other debug facilities (can be used in combination with the other options)
```

## Running
Once built you can run the system in qemu.
```bash
# Now if you want to test it in qemu simply run
./run.sh
# If that doesn't work because you don't have hardware virtualisation/KVM or using the devcontainer, run
NO_KVM=1 ./run.sh
```

The default username / password are `root` and `root`.