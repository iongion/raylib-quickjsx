cmake_minimum_required(VERSION 3.16)

project(rayjs)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

# Workaround for windows to prevent static linking of pthread
IF (WIN32)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static -DJS_STRICT_NAN_BOXING -DCONFIG_BIGNUM -DCONFIG_JSX -DCONFIG_STORAGE -D_CRT_SECURE_NO_WARNINGS -DCONFIG_VERSION=\"2021-03-27\" -DCONFIG_BIGNUM -O2 -flto -fno-rtti")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -fPIC -DJS_STRICT_NAN_BOXING -DCONFIG_BIGNUM -DCONFIG_JSX -DCONFIG_STORAGE -D_CRT_SECURE_NO_WARNINGS -DCONFIG_VERSION=\"2021-03-27\" -DCONFIG_BIGNUM -O2 -flto")
ENDIF()

if (UNIX)
	set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -fPIC -DJS_STRICT_NAN_BOXING -DCONFIG_BIGNUM -DCONFIG_JSX -DCONFIG_STORAGE -D_CRT_SECURE_NO_WARNINGS -DCONFIG_VERSION=\"2021-03-27\" -DCONFIG_BIGNUM -O2 -flto -fno-rtti")
	set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -fPIC -DJS_STRICT_NAN_BOXING -DCONFIG_BIGNUM -DCONFIG_JSX -DCONFIG_STORAGE -D_CRT_SECURE_NO_WARNINGS -DCONFIG_VERSION=\"2021-03-27\" -DCONFIG_BIGNUM -O2 -flto")
endif (UNIX)

message("=== Configure raylib ===")
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/raylib EXCLUDE_FROM_ALL)

message("=== Configure RmlUi ===")
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/RmlUi EXCLUDE_FROM_ALL)

message("=== Configure QuickJSPP ===")
set(quickjs_sources_root ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/quickjspp)

add_library(lightmapper INTERFACE)
target_include_directories(lightmapper INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/lightmapper)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB files src/*.c)
#add_executable(${CMAKE_PROJECT_NAME} MACOSX_BUNDLE ${files})
add_executable(${CMAKE_PROJECT_NAME} ${files})
target_compile_features(${CMAKE_PROJECT_NAME} PRIVATE cxx_std_14)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE include)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE src)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE thirdparty/raygui/src)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/.local/include/quickjs)
target_link_libraries(${CMAKE_PROJECT_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/.local/lib/quickjs/libquickjs.a raylib lightmapper)
