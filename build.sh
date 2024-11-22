#!/bin/bash

# 设置 GOOS 和 GOARCH 变量
GOOS_LIST=("linux")
GOARCH_LIST=("amd64" "arm64" "loong64" "mips64" "riscv64")

# 设置输出目录
OUTPUT_DIR="output"
MAIN_FILE="main.go"

# 创建输出目录
mkdir -p ${OUTPUT_DIR}

# 编译时间
NOW=$(date '+%Y%m%d%H%M')

echo "开始编译程序"

# 开始交叉编译
for GOOS in "${GOOS_LIST[@]}"; do
  for GOARCH in "${GOARCH_LIST[@]}"; do
    echo "Building for OS: ${GOOS} and Arch: ${GOARCH}"

    OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-${GOARCH}"

    if [ "${GOARCH}" == "amd64" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-x86-64"
    elif [ "${GOARCH}" == "arm64" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-aarch64"
    elif [ "${GOARCH}" == "loong64" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-loong64"
    elif [ "${GOARCH}" == "mips64le" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-mips64le"
    elif [ "${GOARCH}" == "mips64" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-mips64"
    elif [ "${GOARCH}" == "riscv64" ]; then
      OUT_FILE="${OUTPUT_DIR}/supervisord-${GOOS}-riscv64"    
    fi

    if [ "${GOOS}" == "windows" ]; then
      OUT_FILE="${OUT_FILE}.exe"
    fi

    # 确保变量存在
    env GOOS=${GOOS} GOARCH=${GOARCH} go build -tags release -a -o ${OUT_FILE} -ldflags "-linkmode external -extldflags -static" ${MAIN_FILE}

    if [ "${GOOS}" == "linux" ]; then
      cp ${OUT_FILE} ./supervisord
    fi
  done
done

echo "编译完成"