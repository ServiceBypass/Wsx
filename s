#include <windows.h>
#include <iostream>
#include <detours.h> 

int (WINAPI *pSend)(SOCKET s, const char* buf, int len, int flags) = send;

int WINAPI HookedSend(SOCKET s, const char* buf, int len, int flags) {
    std::cout << "[DATA]: " << std::string(buf, len) << std::endl;
    
    return pSend(s, buf, len, flags);
}

void InstallHooks() {
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    DetourAttach(&(PVOID&)pSend, HookedSend);
    DetourTransactionCommit();
}

void CreateConsole() {
    AllocConsole();
    FILE* fp;
    freopen_s(&fp, "CONOUT$", "w", stdout);
    std::cout << "Sniffer Shoro Shod..." << std::endl;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        CreateConsole();   
        InstallHooks();   
    }
    return TRUE;
}
