# ============================================================
#  pwsh-pretty  PowerShell 7 美化配置 (主入口)
#  https://github.com/Xynrin/pwsh-pretty
#
#  本文件按文件名顺序加载 profile.d/ 下的所有 *.ps1 片段。
#  想增删功能，只需在 profile.d/ 里加/删一个片段，无需改这里。
# ============================================================

$profileDir = Split-Path $PROFILE -Parent
$fragmentsDir = Join-Path $profileDir 'profile.d'

if (Test-Path $fragmentsDir) {
    Get-ChildItem -Path $fragmentsDir -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
        try {
            . $_.FullName
        } catch {
            Write-Warning "pwsh-pretty: 加载片段 $($_.Name) 失败: $($_.Exception.Message)"
        }
    }
}
