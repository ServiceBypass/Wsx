#include <windows.h>
#include <iostream>
// #include <detours.h> 

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        AllocConsole();
        FILE* fp;
        freopen_s(&fp, "CONOUT$", "w", stdout);
        std::cout << "Injected" << std::endl;
        
        // InstallHooks(); 
    }
    return TRUE;
}
