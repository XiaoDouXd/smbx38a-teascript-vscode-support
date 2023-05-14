cmake_minimum_required(VERSION 3.24.0)

set(VCPKG_TARGET_TRIPLET "x64-windows-static")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake")
    include(./Config.cmake)
else()
    message(WARNING ${XD_PROJECT_NAME} "::CMakeLists::Warning: File ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake not found, Please create one.")
endif()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE} ${VCPKG_ROOT})
if (NOT DEFINED VCPKG_ROOT)
    message(FATAL_ERROR  ${XD_PROJECT_NAME} "::CMakeLists::Error: Vcpkg not found. Please define CMAKE_TOOLCHAIN_FILE var to point the dir to vcpkg.cmake")
else()
    message(STATUS ${XD_PROJECT_NAME} "::CMakeLists::Info: Vcpkg - found: ${VCPKG_ROOT}")
endif()

project(smbx-38a-starter)

# -------------------------------------------------------------- 图标
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

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
file(GLOB_RECURSE ALL_RES
        sources/*.h
        sources/*.hpp
        sources/*.c
        sources/*.cpp)
include_directories(${PROJECT_NAME} source)
add_executable(${PROJECT_NAME} WIN32 ${ALL_RES})

if(WIN32)
    file(GLOB_RECURSE ALL_RC "rc/gen_rc/*.rc")
    target_sources(${PROJECT_NAME} PRIVATE ${ALL_RC})
endif(WIN32)
if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_EXE_LINKER_FLAGS "-mwindows")
endif()
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)

find_package(unofficial-minizip CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE unofficial::minizip::minizip)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)

target_link_libraries(${PROJECT_NAME} PUBLIC rc)
