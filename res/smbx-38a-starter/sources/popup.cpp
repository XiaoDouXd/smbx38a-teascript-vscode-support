
#include "popup.h"

void CreateProgressDialog(HINSTANCE hinstance, const char* title, const char* content)
{
    WPopup = CreateWindowEx(
            0,
            "STATIC",
            title,
            WS_BORDER ,
            CW_USEDEFAULT, CW_USEDEFAULT,
            420, 120,
            nullptr,
            nullptr,
            hinstance,
            nullptr
    );

    HProgressBar = CreateWindowEx(
            0,
            PROGRESS_CLASS,
            nullptr,
            WS_CHILD | WS_VISIBLE,
            20, 40,
            360, 20,
            WPopup,
            nullptr,
            GetModuleHandle(nullptr),
            nullptr
    );

    HLabel = CreateWindowEx(
            0,
            "STATIC",
            content,
            WS_CHILD | WS_VISIBLE,
            20, 20,
            260, 20,
            WPopup,
            nullptr,
            GetModuleHandle(nullptr),
            nullptr
    );

    ShowWindow(WPopup, SW_SHOW);
    UpdateWindow(WPopup);
}

void UpdateProgressDialog(const char* content, float progress)
{
    if (HLabel != nullptr)
    {
        SetWindowText(HLabel, content);
    }

    if (HProgressBar != nullptr)
    {
        int range = 100;
        int position = static_cast<int>(progress * (float )range);
        SendMessage(HProgressBar, PBM_SETPOS, position, 0);
    }
}