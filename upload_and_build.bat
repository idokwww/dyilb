@echo off

REM 自动上传代码到GitHub并触发构建的批处理脚本

if "%1"=="" goto usage
if "%2"=="" goto usage

set GITHUB_USERNAME=%1
set REPOSITORY_NAME=%2
set COMMIT_MESSAGE=%3
if "%COMMIT_MESSAGE%"=="" set COMMIT_MESSAGE=Update code

REM 设置工作目录
cd /d "%~dp0"

echo === 开始上传和构建流程 ===

REM 检查Git是否安装
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Git未安装或未添加到系统PATH
    echo 请先安装Git并将其添加到系统环境变量
    echo 或使用以下命令手动设置Git路径:
    echo set PATH=%PATH%;C:\Program Files\Git\bin
    pause
    exit /b 1
)

REM 初始化Git仓库（如果尚未初始化）
if not exist ".git" (
    echo 初始化Git仓库...
    git init
    if %errorlevel% neq 0 (
        echo 错误: Git初始化失败
        pause
        exit /b 1
    )
)

REM 添加所有文件
echo 添加文件到Git...
git add .
if %errorlevel% neq 0 (
    echo 错误: Git添加文件失败
    pause
    exit /b 1
)

REM 提交更改
echo 提交更改...
git commit -m "%COMMIT_MESSAGE%"
if %errorlevel% neq 0 (
    echo 没有新的更改，跳过提交
)

REM 关联远程仓库
set REMOTE_URL=https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%.git
echo 关联远程仓库: %REMOTE_URL%
git remote remove origin 2>nul
git remote add origin %REMOTE_URL%
if %errorlevel% neq 0 (
    echo 错误: 关联远程仓库失败
    pause
    exit /b 1
)

REM 推送代码
echo 推送代码到GitHub...
git branch -M main
git push -u origin main -f
if %errorlevel% neq 0 (
    echo 错误: 推送代码失败，请检查您的GitHub账号权限
    pause
    exit /b 1
)

echo === 代码上传成功！ ===
echo.
echo 下一步操作：
echo 1. 登录GitHub，进入仓库: https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%
echo 2. 点击 'Actions' 标签
echo 3. 点击 'Build DeviceCheckerDylib' 工作流
echo 4. 点击 'Run workflow' 按钮触发构建
echo 5. 构建完成后，在 'Artifacts' 部分下载编译好的dylib
echo.
echo 构建完成后，您可以通过TrollStore安装编译好的dylib文件
echo.
pause
:usage
echo 用法: %0 ^<GitHub用户名^> ^<仓库名^> [提交信息]
pause