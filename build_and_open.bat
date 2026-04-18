@echo off
echo Building Rust project...
cargo build
if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)
echo Build successful. Opening Godot...
start "" "%~dp0src\open_source_plugins\Godot\Godot_v4.6.2-stable_win64.exe" --path "%~dp0"
echo Done!