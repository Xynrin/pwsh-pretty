# 20-prompt.ps1 — Oh My Posh 提示符 (极简两行 + 圆角胶囊主题)
$poshTheme = Join-Path (Split-Path $PROFILE -Parent) 'my-minimal.omp.json'
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $poshTheme) {
        oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}
