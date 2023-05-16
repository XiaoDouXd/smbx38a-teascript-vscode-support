#include <string>

// 游戏名称, 决定了数据文件夹名
// game name, which determines the name of data folder generated
const std::string gameName = "shadow2d";

// 游戏文件路径, 从 ./$数据文件夹名$/worlds 开始
// path to game file (start from ./!$gameName$_data/worlds)
const std::string pathToMain = "main.elvl";

#include "private/main-content.h"