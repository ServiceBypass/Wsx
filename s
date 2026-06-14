#include <windows.h>
#include <iostream>
#include <detours.h>

// Winsock fonksiyonlarımızın pointerları
int (WINAPI *pSend)(SOCKET s, const char* buf, int len, int flags) = send;
int (WINAPI *pRecv)(SOCKET s, char* buf, int len, int flags) = recv;

// Gelen/Giden veriyi düzgün formatta yazdırmak için yardımcı fonksiyon
void LogData(const char* data, int len, const char* label) {
    std::cout << "\n[" << label << " | " << len << " bytes]" << std::endl;
    for (int i = 0; i < len; i++) {
        // Sadece okunabilir karakterleri bas, değilse nokta koy
        if (isprint((unsigned char)data[i])) 
            std::cout << data[i];
        else 
            std::cout << ".";
    }
    std::cout << "\n----------------------------" << std::endl;
}

// Hook edilen send fonksiyonu
int WINAPI HookedSend(SOCKET s, const char* buf, int len, int flags) {
    if (len > 0) LogData(buf, len, "Giden Veri");
    return pSend(s, buf, len, flags);
}

// Hook edilen recv fonksiyonu
int WINAPI HookedRecv(SOCKET s, char* buf, int len, int flags) {
    int result = pRecv(s, buf, len, flags);
    if (result > 0) LogData(buf, result, "Gelen Veri");
    return result;
}

void InstallHooks() {
    // ws2_32.dll kütüphanesinden fonksiyon adreslerini garantili al
    HMODULE hWinsock = GetModuleHandleA("ws2_32.dll");
    if (hWinsock) {
        pSend = (int (WINAPI*)(SOCKET, const char*, int, int))GetProcAddress(hWinsock, "send");
        pRecv = (int (WINAPI*)(SOCKET, char*, int, int))GetProcAddress(hWinsock, "recv");
    }

    DetourRestoreAfterWith();
    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());
    
    // Hookları tak
    DetourAttach(&(PVOID&)pSend, HookedSend);
    DetourAttach(&(PVOID&)pRecv, HookedRecv);
    
    DetourTransactionCommit();
}

void CreateConsole() {
    AllocConsole();
    FILE* fp;
    freopen_s(&fp, "CONOUT$", "w", stdout);
    std::cout << "Sniffer Aktif. Trafik Dinleniyor..." << std::endl;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        // DLL inject edildiğinde konsolu aç ve hookları kur
        CreateConsole();
        InstallHooks();
    }
    return TRUE;
}
