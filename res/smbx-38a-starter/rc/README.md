# rc - C++ CMake 静态资源导入小记

#### 介绍
C++ CMake 静态资源导入小记

#### 使用方法
- 引入：将项目放到名为 rc 的文件目录中，然后在上级 CMakeLists 中加入 add_subdirectory(rc)。
- 配置：首次引入项目请先在项目的 CMakeLists 执行之前将 `XD_RC_REGEN` 设置为 `ON`，当该设置应用时，rc 项目会将项目中 `res/` 目录下的文件全部转换为 C++ 脚本并生成到 `gen/` 目录中。若首次引入项目没有执行转换，rc 项目会报找不到可链接代码。在后续开发中 `XD_RC_REGEN` 可酌情设置，毕竟每次生成都要转换资源文件有点耗时……
- 链接：在需要用到 rc 项目的工程中加入 `target_link_libraries(${PROJECT_NAME} PRIVATE rc)` 即可。
