#pragma once

#include <Windows.h>
#include <commctrl.h>

extern HWND WPopup;
extern HWND HProgressBar;
extern HWND HLabel;

void CreateProgressDialog(HINSTANCE wnd, const char* title, const char* content);
void UpdateProgressDialog(const char* content, float progress);