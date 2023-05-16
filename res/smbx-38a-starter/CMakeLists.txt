cmake_minimum_required(VERSION 3.24.0)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake")
    include(./Config.cmake)
else()
    message(WARNING "smbx-38a-starter::CMakeLists::Warning: File ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake not found, Please create one.")
endif()

# -------------------------------------------------------------- vcpkg
set(VCPKG_TARGET_TRIPLET "x64-windows-static")
set(VCPKG_ROOT "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE} ${VCPKG_ROOT})
if (NOT DEFINED VCPKG_ROOT)
    message(FATAL_ERROR  "smbx-38a-starter::CMakeLists::Error: Vcpkg not found. Please define CMAKE_TOOLCHAIN_FILE var to point the dir to vcpkg.cmake")
else()
    message(STATUS "smbx-38a-starter::CMakeLists::Info: Vcpkg - found: ${VCPKG_ROOT}")
endif()
# --------------------------------------------------------------------

project(smbx-38a-starter)

# -------------------------------------------------------------- icon
set(XD_RC_WINDRES_PATH icon)
if(WIN32 AND DEFINED XD_RC_WINDRES_PATH AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${XD_RC_WINDRES_PATH}")
    set(__RC_WINDRES_PATH_REAL_FULLPATH "${CMAKE_CURRENT_SOURCE_DIR}/${XD_RC_WINDRES_PATH}")
    file (GLOB_RECURSE ALL_RC "${XD_RC_WINDRES_PATH}/*.rc.in")
    foreach(rc_in ${ALL_RC})
        file(RELATIVE_PATH rc_in_name "${__RC_WINDRES_PATH_REAL_FULLPATH}" ${rc_in})
        string(REGEX REPLACE ".in$" "" rc_out ${rc_in_name})
        configure_file(${rc_in} "${CMAKE_CURRENT_SOURCE_DIR}/rc/gen_rc/${rc_out}")
    endforeach()
endif()
# --------------------------------------------------------------------

add_subdirectory(rc)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED true)

# ----------------------------------------------------------- add file
file(GLOB_RECURSE ALL_RES
        src/*.h
        src/*.hpp
        src/*.c
        src/*.cpp)
include_directories(src ./src/private)
add_executable(${PROJECT_NAME} WIN32 ${ALL_RES})

if(WIN32)
    file(GLOB_RECURSE ALL_RC "rc/gen_rc/*.rc")
    target_sources(${PROJECT_NAME} PRIVATE ${ALL_RC})
else()
    message(FATAL_ERROR  "${PROJECT_NAME}::CMakeLists::Error: Unsupported platform")
endif()
# --------------------------------------------------------------------

# ------------------------------------------------------- linking flag
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_EXE_LINKER_FLAGS "-mwindows")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
    message(STATUS "smbx-38a-starter::CMakeLists::Info: clang config success")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(CMAKE_EXE_LINKER_FLAGS "/NODEFAULTLIB:\"LIBCMT.lib\"")
    message(STATUS "smbx-38a-starter::CMakeLists::Info: msvc config success")
else()
    message(FATAL_ERROR  "${PROJECT_NAME}::CMakeLists::Error: Unsupported compiler")
endif()
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
# --------------------------------------------------------------------

# ------------------------------------------------------------ add pkg
find_package(unofficial-minizip CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE unofficial::minizip::minizip)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)

target_link_libraries(${PROJECT_NAME} PUBLIC rc)
# --------------------------------------------------------------------
