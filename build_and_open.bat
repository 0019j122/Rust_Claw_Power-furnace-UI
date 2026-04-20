@echo off
echo Building Rust project...
cargo build
if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)
if exist target\debug\openclaw_power_furnace.dll copy /Y target\debug\openclaw_power_furnace.dll bin\openclaw_power_furnace.dll >nul
echo Build successful. Opening Godot...
start "" "C:\Rust_Claw_Power furnace - UI\src\open_source_plugins\Godot\Godot_v4.6.2-stable_win64.exe" --path "%~dp0"
echo Done!