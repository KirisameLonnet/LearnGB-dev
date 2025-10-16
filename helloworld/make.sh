#!/bin/bash

# This script builds the ROM and DYNAMICALLY UPDATES the VS Code launch.json file.
# 依赖: 需要安装 jq (JSON command-line processor)

set -e # Exit immediately if any command fails

# 切换到脚本所在的目录 (helloworld)，以确保 find 和编译命令正确
cd "$(dirname "$0")"

echo "🔍 Finding .asm source file..."
# 确保只在当前目录 (helloworld) 查找
ASM_FILE=$(find . -maxdepth 1 -name "*.asm" | head -n 1)

if [ -z "$ASM_FILE" ]; then
    echo "❌ Error: No .asm file found in the 'helloworld' directory."
    exit 1
fi

BASENAME=$(basename -- "$ASM_FILE" .asm)
ROM_FILE="${BASENAME}.gb"

# --- Build Steps ---
echo "⚙️  Building ${ROM_FILE}..."
rgbasm -o "${BASENAME}.o" "$ASM_FILE"
rgblink -o "$ROM_FILE" "${BASENAME}.o"
rgbfix -v -p 0xFF "$ROM_FILE"

# --- 核心逻辑: 动态修改 launch.json ---

# 1. 确定 ROM 的相对路径
# 脚本在 helloworld 目录，因此 ROM 路径相对于工作区根目录是 "helloworld/ROM_FILE"
ROM_RELATIVE_PATH="helloworld/${ROM_FILE}" 

# 2. 确定 launch.json 的相对路径
# launch.json 在 ../.vscode/launch.json
LAUNCH_JSON_PATH="../.vscode/launch.json" 
TEMP_JSON_PATH="../.vscode/launch.tmp"

# --- 检查文件是否存在，防止 jq 报错 ---
if [ ! -f "$LAUNCH_JSON_PATH" ]; then
    echo "❌ Error: launch.json not found at ${LAUNCH_JSON_PATH}. Aborting JSON update."
    exit 1
fi

echo "🔨 Updating launch.json with new program path: ${ROM_RELATIVE_PATH}"

# 3. 使用 jq 找到名为 "Launch from Script" 的配置，并更新其 "program" 字段
# 使用 --arg 传递变量，防止 shell 引号问题
# 注意: 我们使用 > 写入临时文件，然后 mv 覆盖，这是原子性更新文件的标准做法
jq --arg rom_path "$ROM_RELATIVE_PATH" \
   '(.configurations[] | select(.name == "Launch from Script").program) = $rom_path' \
   "$LAUNCH_JSON_PATH" > "$TEMP_JSON_PATH"

# 4. 替换旧的 launch.json
mv "$TEMP_JSON_PATH" "$LAUNCH_JSON_PATH"

echo "✅ Build and configuration update successful. You can now use 'Launch from Script'."
```
