@echo off
call "D:\Vs\VC\Auxiliary\Build\vcvars64.bat"
cd backend_cpp
cl.exe /utf-8 /EHsc /std:c++17 /I include /I include\asio-asio-1-28-0\asio\include /DCROW_ENABLE_STANDALONE /DWIN32_LEAN_AND_MEAN /D_WIN32_WINNT=0x0601 main.cpp /link ws2_32.lib
if %ERRORLEVEL% EQU 0 (
    echo Compilation successful! Running backend...
    main.exe
) else (
    echo Compilation failed.
)
