#!/bin/bash
DIR=`readlink -f .`
PARENT_DIR=`readlink -f ${DIR}/..`

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export SEC_BUILD_CONF_VENDOR_BUILD_OS=13
export CROSS_COMPILE=$PARENT_DIR/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CLANG_TRIPLE=$PARENT_DIR/clang-r383902/bin/aarch64-linux-gnu-
export ARCH=arm64
export LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=$PARENT_DIR/aarch64-linux-android-4.9/bin
export CLANG_PREBUILT_BIN=$PARENT_DIR/clang-r383902/bin
export PATH=$PATH:$LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN:$CLANG_PREBUILT_BIN
export LLVM=1
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
#export CCACHE_DIR=/mnt/ccache
ccache -M 50G -F 0
sudo apt-get install git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip   | tee log/setup

git clone --branch android-9.0.0_r59 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $PARENT_DIR/aarch64-linux-android-4.9
git clone https://github.com/AOSP-10/prebuilts_clang_host_linux-x86_clang-r383902 $PARENT_DIR/clang-r383902


mkdir log
make clean && make mrproper
make exynos2100-p3sxxx_defconfig | tee log/make_defconfig
make -j16 | tee log/make_kernel


error_caption=$(echo -e \
"
🌸 Sakura-Kernel CI

❌ Build Error!
📅 Date: "$(date +%d\ %B\ %Y)"
⏱ Time: "$(date +%T)"
📝 Version: "$VERSION.$PATCHLEVEL.$SUBLEVEL"
🖥 Build Host Info:
- Total CPU Cores: "$(nproc)"
- Total RAM: "$(free -m | awk '/^Mem:/{print $2}')" "MB"
- User: "$(whoami)"
- Hostname: "$(hostname)"
- Kernel: "$(uname -r)"
- OS: "$(uname -s)"
")

caption=$(echo -e \
"
🌸 Sakura-Kernel CI

✅ Build Successfully!
📅 Date: "$(date +%d\ %B\ %Y)"
⏱ Time: "$(date +%T)"
🔐 MD5: "$(md5sum "out/SakuraInstallerUwU.zip" | cut -d ' ' -f 1)"
📝 Version: "$VERSION.$PATCHLEVEL.$SUBLEVEL"
🖥 Build Host Info:
- Total CPU Cores: "$(nproc)"
- Total RAM: "$(free -m | awk '/^Mem:/{print $2}')" "MB"
- User: "$(whoami)"
- Hostname: "$(hostname)"
- Kernel: "$(uname -r)"
- OS: "$(uname -s)"
")

if [ ! -e arch/arm64/boot/Image ]; then
    cd log
    zip -r Log.zip *
    cd ..
    curl -F chat_id=-1002108403014 -F document=@log/Log.zip -F caption="$error_caption" -F parse_mode=Markdown https://api.telegram.org/bot6977733654:AAHWYfBN7IwFUW5aAGhWGHFnvSwl_89h-jE/sendDocument
    exit 1
fi


mv arch/arm64/boot/Image out/zImage
cd out
zip -r SakuraInstallerUwU.zip *
cd ..

while IFS= read -r line
do
    if [[ $line == VERSION* ]]; then
        VERSION=${line#VERSION = }
    elif [[ $line == PATCHLEVEL* ]]; then
        PATCHLEVEL=${line#PATCHLEVEL = }
    elif [[ $line == SUBLEVEL* ]]; then
        SUBLEVEL=${line#SUBLEVEL = }
    fi
done < Makefile

curl -F chat_id=-1002108403014 -F document=@out/SakuraInstallerUwU.zip -F caption="$caption" -F parse_mode=Markdown https://api.telegram.org/bot6977733654:AAHWYfBN7IwFUW5aAGhWGHFnvSwl_89h-jE/sendDocument
