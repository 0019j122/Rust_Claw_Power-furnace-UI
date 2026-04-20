@echo off
REM 診斷腳本：測試 Godot 啟動
cd /d "C:\Rust_Claw_Power furnace - UI"

echo ===== Rust 編譯 =====
cargo build 2>&1
if %errorlevel% neq 0 (
    echo Rust 編譯失敗!
    pause
    exit /b 1
)
if exist target\debug\openclaw_power_furnace.dll copy /Y target\debug\openclaw_power_furnace.dll bin\openclaw_power_furnace.dll >nul
echo ===== DLL 檢查 =====
dir /s target\debug\*.dll

echo ===== Godot 啟動 =====
echo 啟動 Godot...
"src\open_source_plugins\Godot\Godot_v4.6.2-stable_win64.exe" --path "." 2>&1

pause
