#Requires -Version 7.0
<#
.SYNOPSIS
    pwsh-pretty 一键卸载：恢复原配置，移除部署的 profile / 主题 / 片段。
.PARAMETER RemoveTools
    同时卸载安装的 oh-my-posh / eza / bat / zoxide / fzf / fastfetch / 字体 / PSFzf / mdcat。
.EXAMPLE
    .\uninstall.ps1
.EXAMPLE
    .\uninstall.ps1 -RemoveTools
#>
[CmdletBinding()]
param([switch]$RemoveTools)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir 'scripts\00-utils.ps1')

Show-Banner '卸载 / 还原'
Set-StepTotal ($(if ($RemoveTools) { 5 } else { 4 }))
$profileDir = Split-Path $PROFILE -Parent

# ===== [1] 恢复 / 删除 profile =====
Write-Phase "恢复 PowerShell profile"
$backup = "$PROFILE.pwsh-pretty-backup"
if (Test-Path $backup) {
    Copy-Item $backup $PROFILE -Force; Remove-Item $backup -Force
    Write-Item "已从备份恢复原 profile" 'ok'
} elseif (Test-Path $PROFILE) {
    Remove-Item $PROFILE -Force
    Write-Item "无备份(原本无 profile)，已删除 pwsh-pretty 的 profile" 'ok'
} else { Write-Item "未找到 profile" 'skip' }

# ===== [2] 删除主题 + profile.d 片段 =====
Write-Phase "删除主题与配置片段"
$theme = Join-Path $profileDir 'my-minimal.omp.json'
if (Test-Path $theme) { Remove-Item $theme -Force; Write-Item "已删除主题文件" 'ok' } else { Write-Item "主题文件不存在" 'skip' }
$fragments = Join-Path $profileDir 'profile.d'
if (Test-Path $fragments) { Remove-Item $fragments -Recurse -Force; Write-Item "已删除 profile.d 片段目录" 'ok' } else { Write-Item "profile.d 不存在" 'skip' }

# ===== [3] 删除本地部署的工具 (mdcat) =====
Write-Phase "清理本地部署的工具"
$binDir = Join-Path $profileDir 'bin'
if (Test-Path "$binDir\mdcat.exe") {
    Remove-Item "$binDir\mdcat.exe" -Force
    Write-Item "已删除 mdcat.exe" 'ok'
    if (-not (Get-ChildItem $binDir -ErrorAction SilentlyContinue)) { Remove-Item $binDir -Force }
} else { Write-Item "无本地部署的 mdcat" 'skip' }

# ===== [4] 恢复 Windows Terminal =====
Write-Phase "恢复 Windows Terminal 配置"
$wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtBackup = "$wt.pwsh-pretty-backup"
if (Test-Path $wtBackup) {
    Copy-Item $wtBackup $wt -Force; Remove-Item $wtBackup -Force
    Write-Item "已恢复 Windows Terminal 配置" 'ok'
} else { Write-Item "无 WT 备份，跳过" 'skip' }

# ===== [5] 可选卸载工具 =====
if ($RemoveTools) {
    Write-Phase "卸载工具 (-RemoveTools)"
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        foreach ($pkg in 'oh-my-posh','eza','bat','zoxide','fzf','fastfetch','chafa','JetBrainsMono-NF') {
            try { scoop uninstall $pkg *>&1 | Out-Null; Write-Item "已卸载 $pkg" 'ok' }
            catch { Write-Item "$pkg 未安装或跳过" 'skip' }
        }
    } else { Write-Item "未找到 scoop" 'skip' }
    $psfzf = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules\PSFzf'
    if (Test-Path $psfzf) { Remove-Item $psfzf -Recurse -Force -ErrorAction SilentlyContinue; Write-Item "已删除 PSFzf 模块" 'ok' }
}

Show-Done "卸载完成！请重新打开 Windows Terminal。"
