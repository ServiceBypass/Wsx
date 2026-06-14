#include <windows.h>
#include <iostream>
#include <detours.h> 

int (WINAPI *pSend)(SOCKET s, const char* buf, int len, int flags) = send;

int WINAPI HookedSend(SOCKET s, const char* buf, int len, int flags) {
    if (buf != NULL && len > 0) {
        std::cout << "[DATA]: " << std::string(buf, len) << std::endl;
    }
    return pSend(s, buf, len, flags);
}

void InstallHooks() {
    DetourRestoreAfterWith(); 
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    DetourAttach(&(PVOID&)pSend, HookedSend);
    DetourTransactionCommit();
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        AllocConsole();
        FILE* fp;
        freopen_s(&fp, "CONOUT$", "w", stdout);
        InstallHooks();
    }
    return TRUE;
}
