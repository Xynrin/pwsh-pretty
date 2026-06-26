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
