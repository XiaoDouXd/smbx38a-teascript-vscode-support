#include <iostream>
#include <filesystem>
#include <fstream>
#include <cstring>
#include <zconf.h>
#include <windows.h>

#include "unzip.h"

#include "SRC_ZIP.h"

namespace fs = std::filesystem;

const std::string gameName = "shadow2d";

#define MAX_FILENAME 512
#define READ_SIZE 8192
#define DIR_IDENTIFY '/'

class exce : public std::exception
{
public:
    explicit exce(const std::string& str) : _what(str.c_str()) {}
    explicit exce(const char* str) : _what(str) {}
    [[nodiscard]] const char* what() const noexcept override {return _what;}

private:
    const char* _what;
};

void tryCreateParentDir(const fs::path& p)
{
    if (fs::exists(p)) return;

    const fs::path del("/");

    auto temp = fs::path();
    for (auto i = p.begin(); i != p.end(); i++)
    {
        temp += *i;
        temp += del;
        auto j = i;
        if (++j == p.end()) return;
        if (!fs::exists(temp))
            fs::create_directory(temp);
    }
}

void createTask(const char* content)
{
    STARTUPINFO startupInfo;
    PROCESS_INFORMATION processInfo;
    ZeroMemory(&startupInfo, sizeof(startupInfo));
    startupInfo.cb = sizeof(startupInfo);
    ZeroMemory(&processInfo, sizeof(processInfo));

    LPCSTR cmd = content;
    CreateProcess(nullptr,
                  (LPSTR)cmd,
                  nullptr, nullptr,
                  FALSE, 0,
                  nullptr,
                  nullptr, &startupInfo,
                  &processInfo);

    WaitForSingleObject(processInfo.hProcess, INFINITE);
    CloseHandle(processInfo.hProcess);
    CloseHandle(processInfo.hThread);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    auto gameSrcPath = "./!" + gameName + "_data/";
    auto gameRunnerPath = "./!" + gameName + "_data/smbx.exe";
    auto gameFilePath = "\"./!" + gameName + "_data/worlds/main.elvl\"";

    auto packTempPath = "./~" + gameName + "_temp";
    auto exePath = fs::absolute(fs::path("."));

    try{
        if (fs::exists(gameRunnerPath))
        {
            createTask((exePath.string() + "/" + gameRunnerPath + " " +gameFilePath).c_str());
            return 0;
        }

        if (fs::exists(gameSrcPath))
            fs::remove_all(gameSrcPath);
        if (fs::exists(packTempPath))
            fs::remove(packTempPath);
        std::ofstream f;
        f.open(packTempPath, std::ios_base::binary | std::ios_base::out | std::ios_base::trunc);
        f.write((char*)RC::SRC_ZIP.data(), RC::SRC_ZIP.size());
        f.close();

        fs::create_directory(gameSrcPath);

        auto zipfile = unzOpen64(packTempPath.c_str());

        // Get info about the zip file
        unz_global_info global_info;
        if ( unzGetGlobalInfo( zipfile, &global_info ) != UNZ_OK )
        {
            unzClose( zipfile );
            throw exce("could not read file global info");
        }

        // Buffer to hold data read from the zip file.
        char read_buffer[ READ_SIZE ];

        // Loop to extract all files
        uLong i;
        for ( i = 0; i < global_info.number_entry; ++i )
        {
            // Get info about current file.
            unz_file_info file_info;
            char filename[ MAX_FILENAME ];
            if ( unzGetCurrentFileInfo(
                    zipfile,
                    &file_info,
                    filename,
                    MAX_FILENAME,
                    nullptr, 0, nullptr, 0 ) != UNZ_OK )
            {
                unzClose( zipfile );
                throw exce("could not read file info");
            }

            // Check if this entry is a directory or file.
            const size_t filename_length = strlen( filename );
            if (filename[filename_length-1] == DIR_IDENTIFY )
            {
                // Entry is a directory, so create it.
                if (!fs::exists(gameSrcPath + filename))
                {
                    tryCreateParentDir(gameSrcPath + filename);
                    fs::create_directory(gameSrcPath + filename);
                }
            }
            else
            {
                if ( unzOpenCurrentFile( zipfile ) != UNZ_OK )
                {
                    unzClose( zipfile );
                    throw exce("could not open file");
                }

                // Open a file to write out the data.
                tryCreateParentDir(gameSrcPath + filename);
                f.open(gameSrcPath + filename, std::ios_base::binary | std::ios_base::out | std::ios_base::trunc);
                if (!f.is_open())
                {
                    unzCloseCurrentFile( zipfile );
                    unzClose( zipfile );
                    throw exce("could not open destination file");
                }

                int error = UNZ_OK;
                do
                {
                    error = unzReadCurrentFile( zipfile, read_buffer, READ_SIZE );
                    if ( error < 0 )
                    {
                        unzCloseCurrentFile( zipfile );
                        unzClose( zipfile );
                        throw exce("error %d" + std::to_string(error));
                    }

                    // Write data to file.
                    if ( error > 0 ) f.write(read_buffer, error);
                } while ( error > 0 );

                f.close();
            }

            unzCloseCurrentFile( zipfile );
            // Go the the next entry listed in the zip file.
            if ( ( i+1 ) < global_info.number_entry )
            {
                if ( unzGoToNextFile( zipfile ) != UNZ_OK )
                {
                    unzClose( zipfile );
                    throw exce("could not read next file");
                }
            }
        }
        unzClose( zipfile );
        fs::remove(packTempPath);

        createTask((exePath.string() + "/" + gameRunnerPath + " " +gameFilePath).c_str());
        return 0;

    }
    catch (std::exception& e)
    {
        std::cerr << "application exception: " << e.what();
    }
    return 0;
}