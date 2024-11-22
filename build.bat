@echo off
chcp 65001
SETLOCAL ENABLEDELAYEDEXPANSION

REM 设置 GOOS 和 GOARCH 变量
REM 列出所有编译平台 go tool dist list
REM amd64 表示 64 位的 Intel 或者 AMD 处理器也被称为 x86-64
REM arm64 表示 64 位的 ARM 处理器，也被称为 AArch64

set GOOS_LIST=windows linux
set GOARCH_LIST=amd64 arm64 loong64 mips64 riscv64

REM 设置输出目录
set OUTPUT_DIR=output

REM 设置主程序文件
set MAIN_FILE=main.go

REM 创建输出目录
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

REM 删除文件
if exist "%~dp0supervisord.exe" del "%~dp0supervisord.exe"

REM 编译时间
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
set datetime=%datetime:~0,8%%datetime:~8,4%

echo 开始编译程序

for %%i in (%GOOS_LIST%) do (
    for %%j in (%GOARCH_LIST%) do (
        echo Building for OS: %%i and Arch: %%j

        set "GOOS=%%i"
        set "GOARCH=%%j"

        set "OUT_FILE=%OUTPUT_DIR%\supervisord-%%i-%%j"

        if "%%j"=="amd64" (
            set "OUT_FILE=%OUTPUT_DIR%\supervisord-%%i-x86-64"
        )
        if "%%j"=="arm64" (
            set "OUT_FILE=%OUTPUT_DIR%\supervisord-%%i-aarch64"
        )
        if "%%j"=="loong64" (
            set "OUT_FILE=%OUTPUT_DIR%\supervisord-%%i-loong64"
        )
        if "%%j"=="mips64" (
            set "OUT_FILE=%OUTPUT_DIR%\supervisord-%%i-mips64"
        )
        if "%%i"=="windows" (
            set "OUT_FILE=!OUT_FILE!.exe"
        )

        if "%%j"=="loong64" (
            if "%%i"=="windows" (
                echo 龙芯不试配windows平台
            ) else (
                go build -tags release -a -ldflags "-linkmode external -extldflags -static" -o !OUT_FILE! %MAIN_FILE%
            )
        ) else if "%%j"=="mips64le" (
            if "%%i"=="windows" (
                echo mips64le不试配windows平台
            ) else (
                go build -tags release -a -ldflags "-linkmode external -extldflags -static" -o !OUT_FILE! %MAIN_FILE%
            )
        ) else if "%%j"=="mips64" (
            if "%%i"=="windows" (
                echo mips64不试配windows平台
            ) else (
                go build -tags release -a -ldflags "-linkmode external -extldflags -static" -o !OUT_FILE! %MAIN_FILE%
            )
        ) else if "%%j"=="riscv64" (
            if "%%i"=="windows" (
                echo riscv64不试配windows平台
            ) else (
                go build -tags release -a -ldflags "-linkmode external -extldflags -static" -o !OUT_FILE! %MAIN_FILE%
            )
        ) else (
            go build -tags release -a -ldflags "-linkmode external -extldflags -static" -o !OUT_FILE! %MAIN_FILE%

            if "%%i"=="windows" (
                if "%%j"=="amd64" (
                    copy "%~dp0!OUT_FILE!" "%~dp0supervisord.exe"
                )
            )
        )
    )
)

echo 编译完成