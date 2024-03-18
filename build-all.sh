#!/bin/bash
set -o errexit -o pipefail

SCRIPTPATH=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )
PROJECT_HOME=$( realpath "$SCRIPTPATH" )
BUILD_TYPE=Debug
BUILD_DIR=build
CMAKE_BUILD_TYPE=$BUILD_TYPE

export PATH="$PROJECT_HOME/.local/bin:$PATH"
export LD_LIBRARAY_PATH="$PROJECT_HOME/.local/lib:$LD_LIBRARAY_PATH"

# Get premake5
PREMAKE5_URL="https://github.com/premake/premake-core/releases/download/v5.0.0-beta2/premake-5.0.0-beta2-linux.tar.gz"
if [[ ! -f "$PROJECT_HOME/.local/bin/premake5" ]]; then
    echo "Downloading premake5" && \
    mkdir -p "$PROJECT_HOME/temp" && \
    cd "$PROJECT_HOME/temp" && \
    wget "$PREMAKE5_URL" -O "premake5.tar.gz" && \
    tar -zxvf "premake5.tar.gz" && \
    mkdir -p "$PROJECT_HOME/.local/bin" && \
    mkdir -p "$PROJECT_HOME/.local/lib" && \
    mv premake5 "$PROJECT_HOME/.local/bin"
fi

# sudo apt-get install gcc-multilib g++-multilib
echo "Building lunasvg"
if [[ ! -f "$PROJECT_HOME/.local/lib/liblunasvg.a" ]]; then
    cd "$PROJECT_HOME/thirdparty/lunasvg" && \
    rm -fr build && \
    cmake -B build -S . -DBUILD_SHARED_LIBS=OFF -DLUNASVG_BUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="$PROJECT_HOME/.local" && \
    cmake --build build --target lunasvg --config Release -- -j4 install && \
    mkdir -p "$PROJECT_HOME/.local/lib/pkgconfig" && \
    cp "$PROJECT_HOME/support/lunasvg.pc" "$PROJECT_HOME/.local/lib/pkgconfig" && \
    sed -i "s#@LUNASVG_INSTALL_PREFIX@#$PROJECT_HOME/.local#g" "$PROJECT_HOME/.local/lib/pkgconfig/lunasvg.pc"
fi

echo "Building rlottie"
if [[ ! -f "$PROJECT_HOME/.local/lib/x86_64-linux-gnu/librlottie.a" ]]; then
    cd "$PROJECT_HOME/thirdparty/rlottie" && \
    rm -fr build && \
    meson setup build --prefix="$PROJECT_HOME/.local" -Ddefault_library=static && \
    ninja -j 8 -C build install
fi

echo "Building RmlUi"
export LUNASVG_DIR="$PROJECT_HOME/thirdparty/lunasvg"
export RLOTTIE_DIR="$PROJECT_HOME/thirdparty/rlottie"
if [[ ! -f "$PROJECT_HOME/.local/lib/libRmlCore.a" ]]; then
    cd "$PROJECT_HOME/thirdparty/RmlUi" && \
    rm -fr build && mkdir build && cd build && \
    PKG_CONFIG_PATH="$PROJECT_HOME/.local/lib/pkgconfig:$PROJECT_HOME/.local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH" && \
    cmake -DBUILD_SHARED_LIBS=OFF -DBUILD_SAMPLES=ON -DENABLE_SVG_PLUGIN=ON -DENABLE_LOTTIE_PLUGIN=OFF -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="$PROJECT_HOME/.local" .. && \
    make -j 8 install
fi

# sudo apt-get install gcc-multilib g++-multilib
echo "Building quickjspp"
if [[ ! -f "$PROJECT_HOME/.local/lib/quickjs/libquickjs.a" ]]; then
    cd "$PROJECT_HOME/thirdparty/quickjspp" && \
    rm -fr .bin && rm -fr .build && git clean -fx && git clean -fd && \
    cp "$PROJECT_HOME/support/Makefile.quickjspp" "$PROJECT_HOME/thirdparty/quickjspp/Makefile" && \
    sed -i "s#@QUICKJS_INSTALL_PREFIX@#$PROJECT_HOME/.local#g" "$PROJECT_HOME/thirdparty/quickjspp/Makefile"
    make clean && make -j8 libquickjs.a && make install && \
    cp "$PROJECT_HOME/support/quickjs.pc" "$PROJECT_HOME/.local/lib/pkgconfig" && \
    sed -i "s#@QUICKJS_INSTALL_PREFIX@#$PROJECT_HOME/.local#g" "$PROJECT_HOME/.local/lib/pkgconfig/quickjs.pc"
    # premake5 gmake2 --cc=gcc --jsx --storage && \
    # cd .build/gmake2 && make -j8 quickjs
fi

cd "$PROJECT_HOME" && \
echo "Cleaning up build directory" && \
rm -fr build && \
./generate-bindings.sh && \
echo "Generating build files" && \
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
echo "Building" && \
cmake --build "$BUILD_DIR" --config $CMAKE_BUILD_TYPE
