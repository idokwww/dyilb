#!/usr/bin/env pwsh

# 自动上传代码到GitHub并触发构建的脚本

param(
    [Parameter(Mandatory=$true)][string]$GitHubUsername,
    [Parameter(Mandatory=$true)][string]$RepositoryName,
    [Parameter(Mandatory=$false)][string]$CommitMessage = "Update code"
)

# 设置工作目录
$WorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $WorkingDir

Write-Host "=== 开始上传和构建流程 ==="

# 检查Git是否安装
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git未安装，请先安装Git"
    exit 1
}

# 初始化Git仓库（如果尚未初始化）
if (-not (Test-Path ".git")) {
    Write-Host "初始化Git仓库..."
    git init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git初始化失败"
        exit 1
    }
}

# 添加所有文件
Write-Host "添加文件到Git..."
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Git添加文件失败"
    exit 1
}

# 提交更改
Write-Host "提交更改..."
git commit -m "$CommitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Host "没有新的更改，跳过提交"
}

# 关联远程仓库
$RemoteUrl = "https://github.com/$GitHubUsername/$RepositoryName.git"
Write-Host "关联远程仓库: $RemoteUrl"
git remote remove origin -q 2>$null
git remote add origin $RemoteUrl
if ($LASTEXITCODE -ne 0) {
    Write-Error "关联远程仓库失败"
    exit 1
}

# 推送代码
Write-Host "推送代码到GitHub..."
git branch -M main
git push -u origin main -f
if ($LASTEXITCODE -ne 0) {
    Write-Error "推送代码失败，请检查您的GitHub账号权限"
    exit 1
}

Write-Host "=== 代码上传成功！ ==="
Write-Host ""
Write-Host "下一步操作："
Write-Host "1. 登录GitHub，进入仓库: https://github.com/$GitHubUsername/$RepositoryName"
Write-Host "2. 点击 'Actions' 标签"
Write-Host "3. 点击 'Build DeviceCheckerDylib' 工作流"
Write-Host "4. 点击 'Run workflow' 按钮触发构建"
Write-Host "5. 构建完成后，在 'Artifacts' 部分下载编译好的dylib"
Write-Host ""
Write-Host "构建完成后，您可以通过TrollStore安装编译好的dylib文件"