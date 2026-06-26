#Requires -Version 7.0
<#
.SYNOPSIS
    pwsh-pretty 一键安装：美化 PowerShell 7 (提示符 + 图标 ls + 历史预测)。
.DESCRIPTION
    安装 oh-my-posh、eza、Nerd Font 字体，并写入 profile 与极简圆角主题。
    优先使用 scoop（对国内网络友好）。所有原有配置会先备份。
.PARAMETER Proxy
    可选代理地址，例如 http://127.0.0.1:7897。设置后用于 scoop / git / 字体下载。
.PARAMETER SkipFont
    跳过字体安装（如果你已经装过 Nerd Font）。
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -Proxy http://127.0.0.1:7897
#>
[CmdletBinding()]
param(
    [string]$Proxy,
    [switch]$SkipFont
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step  { param($m) Write-Host ">>> $m" -ForegroundColor Cyan }
function Write-Ok    { param($m) Write-Host "    [OK] $m" -ForegroundColor Green }
function Write-Warn2 { param($m) Write-Host "    [!] $m"  -ForegroundColor Yellow }

# ---------- 0. 代理 ----------
if ($Proxy) {
    Write-Step "配置代理: $Proxy"
    $env:HTTP_PROXY  = $Proxy
    $env:HTTPS_PROXY = $Proxy
    $env:ALL_PROXY   = $Proxy
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($Proxy, $true)
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------- 1. 确保 scoop ----------
Write-Step "检查 scoop"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Warn2 "未检测到 scoop，正在安装..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Ok "scoop 已安装"
}

# ---------- 2. 安装 oh-my-posh ----------
Write-Step "安装 oh-my-posh"
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    scoop install oh-my-posh
    Write-Ok "oh-my-posh 安装完成"
} else {
    Write-Ok "oh-my-posh 已存在"
}

# ---------- 3. 安装 eza ----------
Write-Step "安装 eza (现代化 ls)"
if (-not (Get-Command eza -ErrorAction SilentlyContinue) -and -not (Test-Path "$HOME\scoop\apps\eza\current\eza.exe")) {
    scoop install eza
    Write-Ok "eza 安装完成"
} else {
    Write-Ok "eza 已存在"
}

# ---------- 4. 安装 Nerd Font ----------
if (-not $SkipFont) {
    Write-Step "安装 JetBrainsMono Nerd Font"
    $fontInstalled = Get-ItemProperty "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue |
        ForEach-Object { $_.PSObject.Properties.Name } | Where-Object { $_ -match 'JetBrainsMono' }
    if (-not $fontInstalled) {
        if (-not (scoop bucket list | Select-String 'nerd-fonts')) {
            scoop bucket add nerd-fonts
        }
        scoop install JetBrainsMono-NF
        Write-Ok "字体安装完成"
    } else {
        Write-Ok "JetBrainsMono Nerd Font 已安装"
    }
} else {
    Write-Warn2 "已跳过字体安装 (-SkipFont)"
}

# ---------- 5. 部署 profile 与主题 ----------
Write-Step "部署 profile 与主题"
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

# 备份已有 profile
if (Test-Path $PROFILE) {
    $backup = "$PROFILE.pwsh-pretty-backup"
    if (-not (Test-Path $backup)) {
        Copy-Item $PROFILE $backup -Force
        Write-Ok "已备份原 profile -> $backup"
    } else {
        Write-Warn2 "备份已存在，跳过备份 (保留首次备份)"
    }
}

# 写入 profile (UTF-8 无 BOM) 与主题
$profileSrc = Join-Path $scriptDir 'config\profile.ps1'
$themeSrc   = Join-Path $scriptDir 'config\my-minimal.omp.json'
$utf8NoBom  = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($PROFILE, [System.IO.File]::ReadAllText($profileSrc), $utf8NoBom)
Copy-Item $themeSrc (Join-Path $profileDir 'my-minimal.omp.json') -Force
Write-Ok "profile 与主题已部署到 $profileDir"

# ---------- 6. 配置 Windows Terminal 字体 ----------
Write-Step "配置 Windows Terminal 字体"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if ((Test-Path $wtSettings) -and -not $SkipFont) {
    try {
        Copy-Item $wtSettings "$wtSettings.pwsh-pretty-backup" -Force -ErrorAction SilentlyContinue
        $json = Get-Content $wtSettings -Raw | ConvertFrom-Json
        if (-not $json.profiles.defaults) {
            $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([PSCustomObject]@{}) -Force
        }
        $font = [PSCustomObject]@{ face = 'JetBrainsMono Nerd Font' }
        $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue $font -Force
        $json | ConvertTo-Json -Depth 32 | Set-Content $wtSettings -Encoding UTF8
        Write-Ok "Windows Terminal 默认字体已设为 JetBrainsMono Nerd Font"
    } catch {
        Write-Warn2 "自动配置 WT 字体失败，请手动设置: 设置 -> 默认值 -> 外观 -> 字体"
    }
} else {
    Write-Warn2 "未找到 Windows Terminal 配置，请手动把字体设为 'JetBrainsMono Nerd Font'"
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " 安装完成！请完全关闭并重新打开 Windows Terminal。" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host " 如需卸载，运行: .\uninstall.ps1" -ForegroundColor DarkGray
