#Requires -Version 7.0
<#
.SYNOPSIS
    pwsh-pretty 一键卸载：恢复原配置，移除部署的 profile / 主题。
.DESCRIPTION
    - 恢复安装时备份的 profile 和 Windows Terminal 配置
    - 删除部署的主题文件
    - 可选：用 -RemoveTools 一并卸载 oh-my-posh / eza / 字体
.PARAMETER RemoveTools
    同时卸载通过 scoop 安装的 oh-my-posh、eza、JetBrainsMono-NF 字体。
.EXAMPLE
    .\uninstall.ps1
.EXAMPLE
    .\uninstall.ps1 -RemoveTools
#>
[CmdletBinding()]
param(
    [switch]$RemoveTools
)

$ErrorActionPreference = 'Stop'

function Write-Step  { param($m) Write-Host ">>> $m" -ForegroundColor Cyan }
function Write-Ok    { param($m) Write-Host "    [OK] $m" -ForegroundColor Green }
function Write-Warn2 { param($m) Write-Host "    [!] $m"  -ForegroundColor Yellow }

# ---------- 1. 恢复 / 删除 profile ----------
Write-Step "恢复 PowerShell profile"
$backup = "$PROFILE.pwsh-pretty-backup"
if (Test-Path $backup) {
    Copy-Item $backup $PROFILE -Force
    Remove-Item $backup -Force
    Write-Ok "已从备份恢复原 profile"
} elseif (Test-Path $PROFILE) {
    Remove-Item $PROFILE -Force
    Write-Ok "无备份(安装前本无 profile)，已删除 pwsh-pretty 的 profile"
} else {
    Write-Warn2 "未找到 profile，跳过"
}

# ---------- 2. 删除部署的主题 ----------
Write-Step "删除主题文件"
$theme = Join-Path (Split-Path $PROFILE -Parent) 'my-minimal.omp.json'
if (Test-Path $theme) {
    Remove-Item $theme -Force
    Write-Ok "已删除 my-minimal.omp.json"
} else {
    Write-Warn2 "主题文件不存在，跳过"
}

# ---------- 3. 恢复 Windows Terminal 配置 ----------
Write-Step "恢复 Windows Terminal 配置"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtBackup   = "$wtSettings.pwsh-pretty-backup"
if (Test-Path $wtBackup) {
    Copy-Item $wtBackup $wtSettings -Force
    Remove-Item $wtBackup -Force
    Write-Ok "已恢复 Windows Terminal 配置"
} else {
    Write-Warn2 "无 WT 备份，跳过 (字体设置如需还原请手动改)"
}

# ---------- 4. 删除 pwsh-pretty 部署的本地副本 (mdcat 等) ----------
Write-Step "清理本地部署的工具"
$binDir = Join-Path (Split-Path $PROFILE -Parent) 'bin'
if (Test-Path "$binDir\mdcat.exe") {
    Remove-Item "$binDir\mdcat.exe" -Force
    Write-Ok "已删除 mdcat.exe"
    # bin 目录空了就一起删
    if (-not (Get-ChildItem $binDir -ErrorAction SilentlyContinue)) { Remove-Item $binDir -Force }
}

# ---------- 5. 可选：卸载工具 ----------
if ($RemoveTools) {
    Write-Step "卸载工具 (-RemoveTools)"
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        foreach ($pkg in 'oh-my-posh', 'eza', 'bat', 'zoxide', 'fzf', 'fastfetch', 'JetBrainsMono-NF') {
            try {
                scoop uninstall $pkg
                Write-Ok "已卸载 $pkg"
            } catch {
                Write-Warn2 "$pkg 未安装或卸载失败，跳过"
            }
        }
    } else {
        Write-Warn2 "未找到 scoop，无法自动卸载 scoop 工具"
    }
    # PSFzf 模块 (从 GitHub 装的)
    $psfzf = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules\PSFzf'
    if (Test-Path $psfzf) {
        Remove-Item $psfzf -Recurse -Force -ErrorAction SilentlyContinue
        Write-Ok "已删除 PSFzf 模块"
    }
} else {
    Write-Warn2 "保留所有工具 (如需卸载请加 -RemoveTools)"
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " 卸载完成！请重新打开 Windows Terminal。" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
