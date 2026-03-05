#!/bin/bash

# 自动上传代码到GitHub并触发构建的脚本

if [ $# -lt 2 ]; then
    echo "用法: $0 <GitHub用户名> <仓库名> [提交信息]"
    exit 1
fi

GITHUB_USERNAME=$1
REPOSITORY_NAME=$2
COMMIT_MESSAGE=${3:-"Update code"}

# 设置工作目录
WORKING_DIR=$(dirname "$0")
cd "$WORKING_DIR"

echo "=== 开始上传和构建流程 ==="

# 检查Git是否安装
if ! command -v git &> /dev/null; then
    echo "错误: Git未安装，请先安装Git"
    exit 1
fi

# 初始化Git仓库（如果尚未初始化）
if [ ! -d ".git" ]; then
    echo "初始化Git仓库..."
    git init
    if [ $? -ne 0 ]; then
        echo "错误: Git初始化失败"
        exit 1
    fi
fi

# 添加所有文件
echo "添加文件到Git..."
git add .
if [ $? -ne 0 ]; then
    echo "错误: Git添加文件失败"
    exit 1
fi

# 提交更改
echo "提交更改..."
git commit -m "$COMMIT_MESSAGE"
if [ $? -ne 0 ]; then
    echo "没有新的更改，跳过提交"
fi

# 关联远程仓库
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPOSITORY_NAME.git"
echo "关联远程仓库: $REMOTE_URL"
git remote remove origin 2>/dev/null
git remote add origin $REMOTE_URL
if [ $? -ne 0 ]; then
    echo "错误: 关联远程仓库失败"
    exit 1
fi

# 推送代码
echo "推送代码到GitHub..."
git branch -M main
git push -u origin main -f
if [ $? -ne 0 ]; then
    echo "错误: 推送代码失败，请检查您的GitHub账号权限"
    exit 1
fi

echo "=== 代码上传成功！ ==="
echo ""
echo "下一步操作："
echo "1. 登录GitHub，进入仓库: https://github.com/$GITHUB_USERNAME/$REPOSITORY_NAME"
echo "2. 点击 'Actions' 标签"
echo "3. 点击 'Build DeviceCheckerDylib' 工作流"
echo "4. 点击 'Run workflow' 按钮触发构建"
echo "5. 构建完成后，在 'Artifacts' 部分下载编译好的dylib"
echo ""
echo "构建完成后，您可以通过TrollStore安装编译好的dylib文件"