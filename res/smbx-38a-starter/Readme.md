# smbx38a 打包程序

38a游戏程序结构：将入口关卡命名为 main.elvl 放在 worlds 文件夹的根目录下。然后清除杂物，将整个 smbx38a 程序打成 zip 格式压缩包。命名为 src.zip，放在该项目的 ./rc/res 目录下。

关于游戏名请在 ./source/main.cpc 中修改 gameName 变量。

#### ！！该项目开发时使用 MSVC 编译，并通过 vcpkg 管理第三方包，请确保您有相关工具，并在正式生成项目前配置好了 Config.cmake 里的内容！！