# 故障排查 / Troubleshooting

## 图标显示成方块 □ 或问号

Windows Terminal 字体不是 Nerd Font。打开 `设置 (Ctrl+,) → 默认值 → 外观 → 字体`，选 **JetBrainsMono Nerd Font**。安装脚本会尝试自动设置，但如果你的某个配置文件单独覆盖了字体，需要手动改。

## 中文 / 非 ASCII 字符乱码

profile 启动时已强制 UTF-8。如果仍乱码：
1. 确认安装后**重开了终端**
2. 确认字体是 Nerd Font
3. 检查 `[Console]::OutputEncoding` 是否为 `utf-8`

## 安装时卡在下载

多半是网络受限。加 `-Proxy` 指向本地代理：
```powershell
.\install.ps1 -Proxy http://127.0.0.1:7897
```
一键脚本则先设环境变量：
```powershell
$env:PWSH_PRETTY_PROXY='http://127.0.0.1:7897'
```

## 为什么不用 Terminal-Icons / glow

- **Terminal-Icons**：构建版只发布在 PowerShell Gallery，其 CDN（`*.azureedge.net`）在部分网络下不可达。改用 eza（GitHub + scoop），更可靠。
- **md 渲染用 mdcat 而非 glow**：项目固定使用 mdcat 2.9.1。

## oh-my-posh / 某工具 找不到

开一个**新终端**，让更新后的 `PATH`（scoop shims）生效。若仍不行，手动 `scoop install <包名>`。

## fzf 的 Ctrl+R / Ctrl+T 不生效

1. 确认 fzf 已安装：`Get-Command fzf`
2. 键绑定只在交互式终端（ConsoleHost）注册，确认你在正常的 Windows Terminal 里
3. 检查绑定：`Get-PSReadLineKeyHandler | Where-Object Key -in 'Ctrl+r','Ctrl+t'`

本项目用 PSReadLine 原生键绑定调用 fzf，不依赖 PSFzf 模块。

## 提交 issue 时请附上

- `$PSVersionTable.PSVersion`
- 是否使用了 `-Proxy`
- 完整的报错文本
