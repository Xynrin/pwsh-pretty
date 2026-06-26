#Requires -Version 7.0
<#
.SYNOPSIS
    pwsh-pretty 一键安装：美化并增强 PowerShell 7。
.DESCRIPTION
    流式 UI 引导安装：核心(oh-my-posh + eza + Nerd Font) + 可选增强工具
    (bat / mdcat / zoxide / fzf / fastfetch)。基于 scoop，对国内网络友好。
    所有原配置先备份；profile 以模块化片段 (profile.d) 部署。
.PARAMETER Proxy
    可选代理地址，例如 http://127.0.0.1:7897。
.PARAMETER SkipFont
    跳过字体安装。
.PARAMETER All
    跳过询问，安装所有增强工具。
.PARAMETER CoreOnly
    只装核心，跳过所有增强工具。
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -Proxy http://127.0.0.1:7897 -All
#>
[CmdletBinding()]
param(
    [string]$Proxy,
    [switch]$SkipFont,
    [switch]$All,
    [switch]$CoreOnly
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ----- 加载 UI 库 -----
. (Join-Path $scriptDir 'scripts\00-utils.ps1')

Show-Banner

# 计算步骤数：核心(1) + 字体(0/1) + 增强(0/1) + 部署(1) + 终端(0/1)
$total = 2  # 核心 + 部署
if (-not $SkipFont) { $total += 2 }      # 字体 + 终端字体
if (-not $CoreOnly) { $total += 1 }      # 增强工具
Set-StepTotal $total

# ===== 代理 =====
if ($Proxy) {
    $env:HTTP_PROXY = $Proxy; $env:HTTPS_PROXY = $Proxy; $env:ALL_PROXY = $Proxy
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($Proxy, $true)
    Write-Item "代理已配置: $Proxy" 'info'
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ===== 幂等安装辅助 =====
function Install-ScoopPkg {
    param([string]$Cmd, [string]$Pkg, [string]$Desc)
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        Write-Item "$Desc 已存在" 'skip'; return
    }
    scoop install $Pkg *>&1 | Out-Null
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) { Write-Item "$Desc 安装完成" 'ok' }
    else { Write-Item "$Desc 安装失败" 'fail' }
}
function Want-Tool {
    param([string]$Name, [string]$Desc)
    if ($All)      { return $true }
    if ($CoreOnly) { return $false }
    return (Confirm-Yn "安装 $Name ($Desc)?")
}

# ===== [n] 核心工具 =====
Write-Phase "安装核心 (scoop + oh-my-posh + eza)"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-WithSpinner "安装 scoop" { Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression }
} else { Write-Item "scoop 已存在" 'skip' }
Install-ScoopPkg -Cmd 'oh-my-posh' -Pkg 'oh-my-posh' -Desc 'oh-my-posh'
if (-not (Test-Path "$HOME\scoop\apps\eza\current\eza.exe")) {
    Install-ScoopPkg -Cmd 'eza' -Pkg 'eza' -Desc 'eza'
} else { Write-Item "eza 已存在" 'skip' }

# ===== [n] 字体 =====
if (-not $SkipFont) {
    Write-Phase "安装 Nerd Font (JetBrainsMono)"
    $fontInstalled = Get-ItemProperty "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue |
        ForEach-Object { $_.PSObject.Properties.Name } | Where-Object { $_ -match 'JetBrainsMono' }
    if (-not $fontInstalled) {
        if (-not (scoop bucket list | Select-String 'nerd-fonts')) { scoop bucket add nerd-fonts *>&1 | Out-Null }
        Invoke-WithSpinner "下载并安装 JetBrainsMono Nerd Font" { scoop install JetBrainsMono-NF *>&1 | Out-Null }
        Write-Item "字体安装完成" 'ok'
    } else { Write-Item "JetBrainsMono Nerd Font 已安装" 'skip' }
}

# ===== [n] 增强工具 =====
if (-not $CoreOnly) {
    Write-Phase "增强工具 (可选)"
    if (Want-Tool 'bat' '高亮 cat')         { Install-ScoopPkg -Cmd 'bat' -Pkg 'bat' -Desc 'bat' }
    if (Want-Tool 'zoxide' '智能 cd')        { Install-ScoopPkg -Cmd 'zoxide' -Pkg 'zoxide' -Desc 'zoxide' }
    if (Want-Tool 'fastfetch' '系统信息 ff') { Install-ScoopPkg -Cmd 'fastfetch' -Pkg 'fastfetch' -Desc 'fastfetch' }
    if (Want-Tool 'fzf' '模糊查找') {
        Install-ScoopPkg -Cmd 'fzf' -Pkg 'fzf' -Desc 'fzf'
        if (-not (Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue)) {
            try {
                $psfzfDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules\PSFzf'
                $tmp = Join-Path $env:TEMP "psfzf-$(Get-Random)"
                Invoke-WithSpinner "安装 PSFzf 模块 (GitHub)" {
                    git clone --depth 1 https://github.com/kelleyma49/PSFzf.git $using:tmp 2>&1 | Out-Null
                }
                $ver = (Select-String -Path "$tmp\PSFzf.psd1" -Pattern "ModuleVersion\s*=\s*'([\d.]+)'").Matches.Groups[1].Value
                if (-not $ver) { $ver = '2.6.7' }
                $dest = Join-Path $psfzfDir $ver
                New-Item -ItemType Directory -Path $dest -Force | Out-Null
                Copy-Item "$tmp\*" $dest -Recurse -Force -Exclude '.git','.github','tests','helpers'
                Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
                Write-Item "PSFzf 模块安装完成" 'ok'
            } catch { Write-Item "PSFzf 安装失败 (fzf 仍可用)" 'fail' }
        } else { Write-Item "PSFzf 已存在" 'skip' }
    }
    if (Want-Tool 'mdcat' 'Markdown 渲染 md') {
        if (Get-Command mdcat -ErrorAction SilentlyContinue) { Write-Item "mdcat 已存在" 'skip' }
        else {
            try {
                $ver = '2.9.1'
                $url = "https://github.com/BIRSAx2/mdcat/releases/download/mdcat-$ver/mdcat-$ver-x86_64-pc-windows-msvc.zip"
                $tmp = Join-Path $env:TEMP "mdcat-$(Get-Random)"
                New-Item -ItemType Directory -Path $tmp -Force | Out-Null
                Get-FileWithProgress -Url $url -OutFile "$tmp\mdcat.zip" | Out-Null
                Expand-Archive "$tmp\mdcat.zip" -DestinationPath $tmp -Force
                $binDir = Join-Path (Split-Path $PROFILE -Parent) 'bin'
                New-Item -ItemType Directory -Path $binDir -Force | Out-Null
                Copy-Item "$tmp\mdcat.exe" $binDir -Force
                Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
                Write-Item "mdcat $ver 安装完成" 'ok'
            } catch { Write-Item "mdcat 安装失败" 'fail' }
        }
    }
}

# ===== [n] 部署 profile + 主题 + 片段 =====
Write-Phase "部署配置 (profile + 主题 + profile.d)"
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

# 备份
if (Test-Path $PROFILE) {
    $backup = "$PROFILE.pwsh-pretty-backup"
    if (-not (Test-Path $backup)) { Copy-Item $PROFILE $backup -Force; Write-Item "已备份原 profile" 'ok' }
    else { Write-Item "备份已存在，保留首次备份" 'skip' }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
# 主 profile
[System.IO.File]::WriteAllText($PROFILE, [System.IO.File]::ReadAllText((Join-Path $scriptDir 'config\profile.ps1')), $utf8NoBom)
# 主题
Copy-Item (Join-Path $scriptDir 'config\my-minimal.omp.json') (Join-Path $profileDir 'my-minimal.omp.json') -Force
# profile.d 片段
$dstFragments = Join-Path $profileDir 'profile.d'
New-Item -ItemType Directory -Path $dstFragments -Force | Out-Null
Get-ChildItem (Join-Path $scriptDir 'config\profile.d') -Filter '*.ps1' | ForEach-Object {
    [System.IO.File]::WriteAllText((Join-Path $dstFragments $_.Name), [System.IO.File]::ReadAllText($_.FullName), $utf8NoBom)
}
Write-Item "profile + 主题 + $((Get-ChildItem (Join-Path $scriptDir 'config\profile.d') -Filter '*.ps1').Count) 个片段已部署" 'ok'

# ===== [n] Windows Terminal 字体 =====
if (-not $SkipFont) {
    Write-Phase "配置 Windows Terminal 字体"
    $wt = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wt) {
        try {
            Copy-Item $wt "$wt.pwsh-pretty-backup" -Force -ErrorAction SilentlyContinue
            $json = Get-Content $wt -Raw | ConvertFrom-Json
            if (-not $json.profiles.defaults) {
                $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([PSCustomObject]@{}) -Force
            }
            $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([PSCustomObject]@{ face = 'JetBrainsMono Nerd Font' }) -Force
            $json | ConvertTo-Json -Depth 32 | Set-Content $wt -Encoding UTF8
            Write-Item "默认字体已设为 JetBrainsMono Nerd Font" 'ok'
        } catch { Write-Item "自动配置失败，请手动设置字体" 'fail' }
    } else { Write-Item "未找到 Windows Terminal，请手动设置字体" 'skip' }
}

Show-Done "安装完成！请完全关闭并重新打开 Windows Terminal。"
Write-Host "   $($script:UI.Gray)卸载: .\uninstall.ps1   文档: docs/$($script:UI.Reset)"
Write-Host ""
