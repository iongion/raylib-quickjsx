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
cd thirdparty/lunasvg && \
rm -fr builddir && \
meson setup builddir --prefix="$PROJECT_HOME/.local" && \
ninja -j 8 -C builddir install

exit 0

echo "Building rlottie"
cd thirdparty/rlottie && \
rm -fr builddir && \
meson setup builddir --prefix="$PROJECT_HOME/.local" && \
ninja -j 8 -C builddir install

# git clone --depth 1 --branch v2.3.1 https://github.com/sammycage/lunasvg.git
# cd lunasvg
# mkdir build
# cd build
# cmake -G "%VS_GENERATOR%" -DBUILD_SHARED_LIBS=OFF -DLUNASVG_BUILD_EXAMPLES=OFF ..
# cmake --build . --target lunasvg --config Debug -- "/clp:ErrorsOnly"
# cmake --build . --target lunasvg --config Release -- "/clp:ErrorsOnly"
# cd ../../

echo "Building RmlUi"
cd "$PROJECT_HOME/thirdparty/RmlUi" && \
    rm -fr build && mkdir build && cd build && \
    cmake -DBUILD_SAMPLES=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=$BUILD_TYPE .. && \
    make -j 8

# sudo apt-get install gcc-multilib g++-multilib
echo "Building quickjspp"
cd "$PROJECT_HOME/thirdparty/quickjspp" && \
    rm -fr .bin && rm -fr .build && \
    cp -f "$PROJECT_HOME/support/quickjsx-premake5.lua" premake5.lua && \
    premake5 gmake2 --cc=gcc --jsx --storage && \
    make clean && make -j8 libquickjs.a

cd "$PROJECT_HOME" && \
echo "Cleaning up build directory" && \
rm -fr build && \
./generate-bindings.sh && \
echo "Generating build files" && \
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
echo "Building" && \
cmake --build "$BUILD_DIR" --config $BUILD_TYPE
