# 40-psreadline.ps1 — 补全 / 高亮 / 历史预测
Import-Module PSReadLine -ErrorAction SilentlyContinue
# 历史预测仅在交互式终端启用，避免非交互 / 重定向环境报错
if ($Host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineOption -PredictionSource History
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
Set-PSReadLineKeyHandler -Key UpArrow   -Function PreviousHistory
Set-PSReadLineKeyHandler -Key DownArrow -Function NextHistory
