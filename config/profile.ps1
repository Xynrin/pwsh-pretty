# ============================================================
#  pwsh-pretty  PowerShell 7 美化配置
#  https://github.com/Xynrin/pwsh-pretty
#  此文件由 install.ps1 复制到 $PROFILE
# ============================================================

# ===== 强制 UTF-8 编码 (修复 ls 图标 / 中文文件名乱码) =====
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ===== Oh My Posh 提示符 (极简两行 + 圆角胶囊主题) =====
$poshTheme = Join-Path (Split-Path $PROFILE -Parent) 'my-minimal.omp.json'
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $poshTheme) {
        oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# ===== eza: 现代化 ls，带图标和颜色 =====
# 优先用 PATH 里的 eza；否则尝试 scoop 安装路径
$ezaCmd = $null
if (Get-Command eza -ErrorAction SilentlyContinue) {
    $ezaCmd = 'eza'
} elseif (Test-Path "$HOME\scoop\apps\eza\current\eza.exe") {
    $ezaCmd = "$HOME\scoop\apps\eza\current\eza.exe"
}
if ($ezaCmd) {
    $ezaBase = '--icons=always', '--group-directories-first', '--color=always'
    function Invoke-Eza { & $ezaCmd @ezaBase @args }
    Set-Alias -Name ls -Value Invoke-Eza -Option AllScope -Force
    function ll { & $ezaCmd @ezaBase -l @args }                       # 长格式
    function la { & $ezaCmd @ezaBase -la @args }                      # 含隐藏文件
    function lt { & $ezaCmd @ezaBase --tree --level=2 @args }         # 树状视图
}

# ===== PSReadLine 补全 / 高亮 / 历史预测 =====
Import-Module PSReadLine -ErrorAction SilentlyContinue
# 历史预测仅在交互式终端启用，避免非交互 / 重定向环境报错
if ($Host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineOption -PredictionSource History
        # InlineView: 仅在行尾灰字显示一条建议，按 → 接受，不弹多行列表
        Set-PSReadLineOption -PredictionViewStyle InlineView
    } catch { }
}
Set-PSReadLineOption -Colors @{
    Command   = 'Cyan'
    Parameter = 'Gray'
    String    = 'Green'
    Number    = 'Magenta'
    Operator  = 'DarkGray'
    Comment   = 'DarkGreen'
}
Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
# 上下键保持正常的历史翻页行为
Set-PSReadLineKeyHandler -Key UpArrow   -Function PreviousHistory
Set-PSReadLineKeyHandler -Key DownArrow -Function NextHistory

# ============================================================
#  增强工具 (每个都按是否安装条件加载，没装则静默跳过)
# ============================================================

# ----- bat: 带语法高亮和行号的 cat -----
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope -Force
    $env:BAT_THEME = 'ansi'
}

# ----- mdcat: 在终端渲染 Markdown -----
# 优先 PATH 里的 mdcat，其次 pwsh-pretty 部署的本地副本
$mdcatCmd = $null
if (Get-Command mdcat -ErrorAction SilentlyContinue) {
    $mdcatCmd = 'mdcat'
} elseif (Test-Path "$HOME\scoop\apps\mdcat\current\mdcat.exe") {
    $mdcatCmd = "$HOME\scoop\apps\mdcat\current\mdcat.exe"
} elseif (Test-Path (Join-Path (Split-Path $PROFILE -Parent) 'bin\mdcat.exe')) {
    $mdcatCmd = Join-Path (Split-Path $PROFILE -Parent) 'bin\mdcat.exe'
}
if ($mdcatCmd) {
    function md { & $mdcatCmd @args }          # md <file.md> 渲染 markdown
}

# ----- zoxide: 智能 cd 跳转 (z <关键词>) -----
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ----- fzf + PSFzf: 模糊查找 (Ctrl+T 找文件, Ctrl+R 搜历史) -----
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # 预览：文件用 bat，目录用 eza
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline'
    if (Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue) {
        Import-Module PSFzf -ErrorAction SilentlyContinue
        try {
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        } catch { }
    }
}

# ----- fastfetch: 启动时显示系统信息 -----
# 默认不自动运行，避免拖慢启动；输入 `ff` 手动查看
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    Set-Alias -Name ff -Value fastfetch -Option AllScope -Force
    # 想开机自动显示，取消下面一行注释：
    # if ($Host.Name -eq 'ConsoleHost') { fastfetch }
}
