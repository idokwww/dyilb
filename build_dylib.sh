#!/bin/bash

# 进入项目目录
cd "$(dirname "$0")"

# 编译dylib
echo "开始编译DeviceCheckerDylib..."
xcodebuild -project DeviceChecker.xcodeproj -target DeviceCheckerDylib -configuration Release build

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "编译成功！"
    
    # 查找生成的dylib文件
    DYLIB_PATH=$(find ./build -name "libDeviceCheckerDylib.dylib" -type f)
    
    if [ -f "$DYLIB_PATH" ]; then
        echo "dylib文件位置: $DYLIB_PATH"
        
        # 复制到当前目录
        cp "$DYLIB_PATH" ./libDeviceCheckerDylib.dylib
        echo "已复制到当前目录: ./libDeviceCheckerDylib.dylib"
    else
        echo "未找到生成的dylib文件"
    fi
else
    echo "编译失败！"
    exit 1
fi