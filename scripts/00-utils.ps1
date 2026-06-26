#Requires -Version 7.0
# ============================================================
#  00-utils.ps1  —  公共 UI 库（颜色 / 日志 / spinner / 进度 / banner）
#  被 install.ps1 / uninstall.ps1 dot-source 引用
# ============================================================

# ----- 颜色与符号 -----
$script:Esc = [char]27
$script:UI = @{
    Reset  = "$Esc[0m"
    Bold   = "$Esc[1m"
    Dim    = "$Esc[2m"
    Red    = "$Esc[38;2;255;110;110m"
    Green  = "$Esc[38;2;168;204;140m"
    Blue   = "$Esc[38;2;95;175;255m"
    Cyan   = "$Esc[38;2;86;204;242m"
    Yellow = "$Esc[38;2;229;192;123m"
    Purple = "$Esc[38;2;195;134;241m"
    Gray   = "$Esc[38;2;130;130;130m"
}

# 确保 UTF-8，否则符号/中文乱码
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

# ----- 全局步骤计数 -----
$script:StepTotal = 0
$script:StepIndex = 0
function Set-StepTotal { param([int]$Total) $script:StepTotal = $Total; $script:StepIndex = 0 }

# ----- Banner -----
function Show-Banner {
    param([string]$Subtitle = 'PowerShell 7 美化与增强')
    $u = $script:UI
    Write-Host ""
    Write-Host "$($u.Purple)$($u.Bold)  ╭───────────────────────────────────────────╮$($u.Reset)"
    Write-Host "$($u.Purple)$($u.Bold)  │$($u.Reset)  $($u.Cyan)$($u.Bold)✨  pwsh-pretty$($u.Reset)                             $($u.Purple)$($u.Bold)│$($u.Reset)"
    Write-Host "$($u.Purple)$($u.Bold)  ╰───────────────────────────────────────────╯$($u.Reset)"
    Write-Host "  $($u.Gray)$Subtitle$($u.Reset)"
    Write-Host ""
}

# ----- 分步标题  [n/total] 标题 -----
function Write-Phase {
    param([string]$Title)
    $u = $script:UI
    $script:StepIndex++
    $tag = if ($script:StepTotal -gt 0) { "[$($script:StepIndex)/$($script:StepTotal)]" } else { ">>>" }
    Write-Host ""
    Write-Host "$($u.Blue)$($u.Bold)$tag$($u.Reset) $($u.Bold)$Title$($u.Reset)"
}

# ----- 子项状态行 -----
function Write-Item {
    param([string]$Msg, [ValidateSet('ok','fail','info','skip','work')] [string]$Status = 'info')
    $u = $script:UI
    $sym, $col = switch ($Status) {
        'ok'   { '✓', $u.Green }
        'fail' { '✗', $u.Red }
        'skip' { '·', $u.Gray }
        'work' { '→', $u.Cyan }
        default { '•', $u.Gray }
    }
    Write-Host "   $col$sym$($u.Reset) $Msg"
}

# ----- Spinner：包裹一个耗时操作，转圈直到完成 -----
function Invoke-WithSpinner {
    param(
        [string]$Message,
        [scriptblock]$Action
    )
    $u = $script:UI
    # 非交互 / 重定向环境直接顺序执行，不转圈（避免花屏）
    if ([Console]::IsOutputRedirected -or $Host.Name -ne 'ConsoleHost') {
        Write-Item "$Message ..." 'work'
        & $Action
        return
    }
    $frames = '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏'
    $job = Start-Job -ScriptBlock $Action
    $i = 0
    while ($job.State -eq 'Running') {
        $f = $frames[$i % $frames.Count]
        Write-Host "`r   $($u.Cyan)$f$($u.Reset) $Message ..." -NoNewline
        Start-Sleep -Milliseconds 80
        $i++
    }
    Receive-Job $job -ErrorAction SilentlyContinue | Out-Null
    $failed = $job.State -eq 'Failed'
    Remove-Job $job -Force -ErrorAction SilentlyContinue
    if ($failed) {
        Write-Host "`r   $($u.Red)✗$($u.Reset) $Message      "
    } else {
        Write-Host "`r   $($u.Green)✓$($u.Reset) $Message      "
    }
}

# ----- 带进度的下载 -----
function Get-FileWithProgress {
    param([string]$Url, [string]$OutFile)
    $u = $script:UI
    $name = Split-Path $OutFile -Leaf
    try {
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
        $size = [math]::Round((Get-Item $OutFile).Length / 1MB, 1)
        Write-Item "$name  (${size} MB)" 'ok'
        return $true
    } catch {
        Write-Item "$name  下载失败: $($_.Exception.Message)" 'fail'
        return $false
    }
}

# ----- 询问 (Y/n) -----
function Confirm-Yn {
    param([string]$Question, [bool]$DefaultYes = $true)
    $u = $script:UI
    $hint = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    $ans = Read-Host "   $($u.Yellow)?$($u.Reset) $Question $($u.Gray)$hint$($u.Reset)"
    if ($ans -eq '') { return $DefaultYes }
    return ($ans -match '^[Yy]')
}

# ----- 结束语 -----
function Show-Done {
    param([string]$Message)
    $u = $script:UI
    Write-Host ""
    Write-Host "$($u.Green)$($u.Bold)   ✓ $Message$($u.Reset)"
    Write-Host ""
}
