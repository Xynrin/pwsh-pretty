# 30-eza.ps1 — eza: 现代化 ls，带图标和颜色
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
    function ll { & $ezaCmd @ezaBase -l @args }                # 长格式
    function la { & $ezaCmd @ezaBase -la @args }               # 含隐藏文件
    function lt { & $ezaCmd @ezaBase --tree --level=2 @args }  # 树状视图
}
