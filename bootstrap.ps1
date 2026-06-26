#Requires -Version 7.0
<#
.SYNOPSIS
    pwsh-pretty 一键引导安装脚本 (供 irm | iex 使用)。
.DESCRIPTION
    克隆 pwsh-pretty 仓库到临时目录并运行 install.ps1。
    支持通过环境变量传参：
      $env:PWSH_PRETTY_PROXY     代理地址，如 http://127.0.0.1:7897
      $env:PWSH_PRETTY_SKIPFONT  设为 1 跳过字体安装
.EXAMPLE
    irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
.EXAMPLE
    $env:PWSH_PRETTY_PROXY='http://127.0.0.1:7897'; irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
#>

$ErrorActionPreference = 'Stop'
$repo = 'https://github.com/Xynrin/pwsh-pretty.git'

function Write-Step { param($m) Write-Host ">>> $m" -ForegroundColor Cyan }

# 应用代理（如果设置了环境变量）
$proxy = $env:PWSH_PRETTY_PROXY
if ($proxy) {
    Write-Step "使用代理: $proxy"
    $env:HTTP_PROXY = $proxy; $env:HTTPS_PROXY = $proxy; $env:ALL_PROXY = $proxy
}

# 确保有 git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "未找到 git，请先安装 git，或改用 README 中的 git clone 方式手动安装。"
}

# 克隆到临时目录
$dest = Join-Path $env:TEMP "pwsh-pretty-$(Get-Random)"
Write-Step "克隆仓库到 $dest"
git clone --depth 1 $repo $dest

# 组装参数并调用 install.ps1
$installArgs = @{}
if ($proxy) { $installArgs['Proxy'] = $proxy }
if ($env:PWSH_PRETTY_SKIPFONT -eq '1') { $installArgs['SkipFont'] = $true }
if ($env:PWSH_PRETTY_ALL      -eq '1') { $installArgs['All'] = $true }
if ($env:PWSH_PRETTY_COREONLY -eq '1') { $installArgs['CoreOnly'] = $true }

Write-Step "运行 install.ps1"
try {
    & (Join-Path $dest 'install.ps1') @installArgs
} finally {
    # 清理临时克隆
    Write-Step "清理临时文件"
    Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
}
