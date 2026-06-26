# 55-fastfetch-waifu.ps1 — ff: fastfetch 看板娘 (随机二次元图片 + 系统信息)
# 移植自 shorin-arch-setup 的 f.fish。
# 用法:
#   ff            随机展示一张二次元图片 + 系统信息
#   ff -NoImage   只显示系统信息 (纯 fastfetch)
#   ff -h         帮助
# 图片源: nekos.best (SFW)。后台异步补货，无网自动降级。

if (Get-Command fastfetch -ErrorAction SilentlyContinue) {

    # 移除可能存在的旧 ff 别名，改用函数
    if (Test-Path Alias:ff) { Remove-Item Alias:ff -Force -ErrorAction SilentlyContinue }

    function ff {
        [CmdletBinding()]
        param([switch]$NoImage, [switch]$h)

        if ($h) {
            Write-Host @"
ff — fastfetch 看板娘

  ff            随机展示一张二次元图片 + 系统信息
  ff -NoImage   只显示系统信息 (纯 fastfetch)
  ff -h         显示本帮助

图片源 nekos.best (SFW)，缓存于 ~\.cache\fastfetch_waifu。
后台自动补货；无网络时自动降级为纯系统信息。
若图片显示为乱码，说明终端不支持 sixel —— 用 ff -NoImage，
或在 Windows Terminal 设置里启用 sixel 支持。
"@
            return
        }

        # ---- 配置 ----
        $cacheDir = Join-Path $env:USERPROFILE '.cache\fastfetch_waifu'
        $usedDir  = Join-Path $cacheDir 'used'
        $minTrigger   = 5     # 库存低于此值触发补货
        $batchSize    = 8     # 每次补货下载张数
        $maxStock     = 40    # 待用上限
        $maxUsed      = 20    # 已用上限
        $categories   = 'waifu','neko','kitsune'

        New-Item -ItemType Directory -Path $cacheDir, $usedDir -Force -ErrorAction SilentlyContinue | Out-Null

        # ---- 纯系统信息模式 ----
        if ($NoImage) { fastfetch; return }

        # ---- 选一张已缓存的图片显示 ----
        $stock = @(Get-ChildItem $cacheDir -Filter '*.png' -File -ErrorAction SilentlyContinue)
        if ($stock.Count -gt 0) {
            $pick = $stock | Get-Random
            # 用 sixel 协议显示图片 logo（WT 需启用 sixel；失败时 fastfetch 会回退）
            fastfetch --logo-type sixel --logo "$($pick.FullName)" 2>$null
            if ($LASTEXITCODE -ne 0) { fastfetch }   # 协议不支持则降级
            # 用过的移到 used 目录
            try { Move-Item $pick.FullName (Join-Path $usedDir $pick.Name) -Force -ErrorAction SilentlyContinue } catch {}
        } else {
            # 库存为空：先显示纯信息，下载在后台进行
            fastfetch
        }

        # ---- 后台异步补货 (不阻塞当前终端) ----
        if ($stock.Count -lt $minTrigger) {
            $sb = {
                param($cacheDir, $usedDir, $batchSize, $maxStock, $maxUsed, $categories, $proxy)
                try {
                    $proxyArg = if ($proxy) { @('-x', $proxy) } else { @() }
                    # 网络探测：通则补货 (用 curl.exe，nekos.best 会拦截 PowerShell 原生请求)
                    $probe = curl.exe -s -o $null -w "%{http_code}" --max-time 6 @proxyArg 'https://nekos.best/api/v2/waifu' 2>$null
                    if ($probe -ne '200') { return }
                    $have = @(Get-ChildItem $cacheDir -Filter '*.png' -File -ErrorAction SilentlyContinue).Count
                    if ($have -lt $maxStock) {
                        for ($i = 0; $i -lt $batchSize; $i++) {
                            try {
                                $cat = $categories | Get-Random
                                $json = (curl.exe -s --max-time 10 @proxyArg "https://nekos.best/api/v2/$cat" 2>$null) -join ''
                                # 用正则提取 url，避开 JSON 里日文 artist_name 的编码问题
                                $url = if ($json -match '"url":"(https://[^"]+\.png)"') { $Matches[1] } else { $null }
                                if ($url) {
                                    $name = "waifu_$([DateTimeOffset]::Now.ToUnixTimeMilliseconds())_$(Get-Random).png"
                                    $dst = Join-Path $cacheDir $name
                                    curl.exe -s -L --max-time 20 @proxyArg -o $dst $url 2>$null
                                    if (-not (Test-Path $dst) -or (Get-Item $dst).Length -lt 1024) { Remove-Item $dst -Force -ErrorAction SilentlyContinue }
                                }
                            } catch {}
                            Start-Sleep -Milliseconds 300
                        }
                    }
                    # 清理 used 超量 (按时间删最旧)
                    $usedFiles = @(Get-ChildItem $usedDir -Filter '*.png' -File | Sort-Object LastWriteTime)
                    if ($usedFiles.Count -gt $maxUsed) {
                        $usedFiles | Select-Object -First ($usedFiles.Count - $maxUsed) | Remove-Item -Force -ErrorAction SilentlyContinue
                    }
                } catch {}
            }
            $proxy = if ($env:HTTPS_PROXY) { $env:HTTPS_PROXY } else { $null }
            Start-Job -ScriptBlock $sb -ArgumentList $cacheDir, $usedDir, $batchSize, $maxStock, $maxUsed, $categories, $proxy | Out-Null
        }
    }
}
