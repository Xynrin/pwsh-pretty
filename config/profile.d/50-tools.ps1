# 50-tools.ps1 — 增强工具 (每个按是否安装条件加载，没装则静默跳过)

# ----- bat: 带语法高亮和行号的 cat -----
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope -Force
    $env:BAT_THEME = 'ansi'
}

# ----- mdcat: 在终端渲染 Markdown (md <file>) -----
$mdcatCmd = $null
if (Get-Command mdcat -ErrorAction SilentlyContinue) {
    $mdcatCmd = 'mdcat'
} elseif (Test-Path (Join-Path (Split-Path $PROFILE -Parent) 'bin\mdcat.exe')) {
    $mdcatCmd = Join-Path (Split-Path $PROFILE -Parent) 'bin\mdcat.exe'
}
if ($mdcatCmd) {
    function md { & $mdcatCmd @args }
}

# ----- zoxide: 智能 cd 跳转 (z <关键词>) -----
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ----- fzf + PSFzf: 模糊查找 (Ctrl+T 找文件, Ctrl+R 搜历史) -----
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'
    if (Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue) {
        Import-Module PSFzf -ErrorAction SilentlyContinue
        try {
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        } catch { }
    }
}

# ----- fastfetch: 系统信息 (ff) -----
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    Set-Alias -Name ff -Value fastfetch -Option AllScope -Force
    # 想开机自动显示，取消下一行注释：
    # if ($Host.Name -eq 'ConsoleHost') { fastfetch }
}
