# 60-pget.ps1 — pget: fzf 驱动的包管理 TUI (scoop 主 / winget 可选)
# 用法:
#   pget [关键词]       用 fzf 模糊搜索 scoop 包，Tab 多选，Enter 安装
#   pget -w [关键词]    改用 winget 搜索 (较慢，走微软源)
#   pget -h             帮助
# 依赖: fzf + scoop (winget 可选)

if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Command scoop -ErrorAction SilentlyContinue)) {

    function pget {
        [CmdletBinding()]
        param(
            [switch]$w,           # 用 winget 而非 scoop
            [switch]$h,           # 帮助
            [Parameter(ValueFromRemainingArguments)] [string[]]$Query
        )

        if ($h) {
            Write-Host @"
pget — fzf 驱动的包管理 TUI

  pget [关键词]      用 fzf 搜索 scoop 包；Tab 多选，Enter 安装，Esc 退出
  pget -w [关键词]   改用 winget 搜索 (较慢)
  pget -h            显示本帮助

颜色: 绿色 ✔ = 已安装   蓝色 = scoop   紫色 = winget
"@
            return
        }

        $q = ($Query -join ' ').Trim()
        $esc = [char]27
        $fzfOpts = @(
            '--ansi','--multi','--height=90%','--layout=reverse','--border',
            '--prompt=pkg> ',
            "--header=Tab:多选  Enter:安装  Esc:退出",
            # 预览放右侧、占 60% 宽，足够完整显示 scoop info
            '--preview-window=right,60%,wrap'
        )

        if ($w) {
            # ---- winget 后端 (较慢，走微软源) ----
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Write-Warning 'winget 未安装'; return }
            Write-Host "正在用 winget 搜索 '$q' (较慢)..." -ForegroundColor DarkGray
            $raw = winget search $q --disable-interactivity 2>$null
            # winget 表格: Name  Id  Version  ... 取 Id 列
            $lines = $raw | Select-Object -Skip 2 | Where-Object { $_ -match '\S' }
            $items = foreach ($l in $lines) {
                $cols = @(($l -split '\s{2,}') | Where-Object { $_ })
                if ($cols.Count -ge 2) { "{0}{1}{2}`t{3}" -f "$esc[35m", $cols[1], "$esc[0m", $cols[0] }
            }
            if (-not $items) { Write-Host '无结果' -ForegroundColor Yellow; return }
            $sel = $items | fzf @fzfOpts --with-nth=1,2 --preview="echo {1}"
            $picked = $sel | ForEach-Object { (($_ -replace "$esc\[[\d;]*m") -split "`t")[0] }
            foreach ($p in $picked) {
                if ($p) { Write-Host ">> winget install $p" -ForegroundColor Cyan; winget install --id $p -e }
            }
        }
        else {
            # ---- scoop 后端 (本地索引，快；scoop search 返回对象) ----
            $installed = @{}
            foreach ($it in (scoop list 6>$null)) { if ($it.Name) { $installed[$it.Name] = $true } }

            $results = @(scoop search $q 6>$null | Where-Object { $_.Name })
            if (-not $results) { Write-Host "无结果" -ForegroundColor Yellow; return }
            $items = foreach ($r in $results) {
                $mark = if ($installed[$r.Name]) { " $esc[32m✔$esc[0m" } else { '' }
                $src  = if ($r.Source) { $r.Source } else { '' }
                # 用 TAB 分列：第1列彩色名(仅显示)，后面附版本/源/标记
                "{0}{1}{2}`t{3}`t{4}{5}" -f "$esc[34m", $r.Name, "$esc[0m", $r.Version, $src, $mark
            }
            $sel = $items | fzf @fzfOpts --with-nth=1,2,3 --preview="scoop info {1} 2>`$null"
            $picked = $sel | ForEach-Object { (($_ -replace "$esc\[[\d;]*m") -split "`t")[0].Trim() }
            foreach ($p in $picked) {
                if ($p) { Write-Host ">> scoop install $p" -ForegroundColor Cyan; scoop install $p }
            }
        }
    }
}
