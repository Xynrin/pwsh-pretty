<div align="center">

# ✨ pwsh-pretty

**一条命令，把朴素的 PowerShell 7 变成好看又顺手的终端。**

极简提示符 · 带图标的 `ls` · 历史命令预测 · 可选 fzf / bat / mdcat / zoxide / fastfetch。
专为 **Windows + PowerShell 7** 打造，对**国内网络环境友好**（基于 scoop，支持代理）。

[English](./README.md) | **简体中文**

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/平台-Windows-0078D6?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/许可证-MIT-green)

</div>

---

## 📸 效果预览

![pwsh-pretty 预览](./assets/preview.png)

路径在圆角彩色胶囊里，不会和上一行输出糊在一起。箭头**成功为绿、失败为红**。`ls` 显示彩色 Nerd Font 图标，目录优先。

## 🌟 功能特性

- 🎯 **极简两行提示符** —— 路径胶囊 + Git 状态；箭头按退出码变色
- 🎨 **带图标的 `ls`** —— 基于 [eza](https://github.com/eza-community/eza)，附 `ll` / `la` / `lt`
- ⌨️ **历史预测** —— 行尾灰字提示，按 `→` 接受
- 🈶 **默认 UTF-8** —— 修复中文文件名和图标乱码
- 🧰 **可选增强工具** —— fzf、bat、mdcat、zoxide、fastfetch（安装时询问）
- ↩️ **完全可逆** —— 自动备份；`uninstall.ps1` 一键还原

## 🚀 安装

在 **PowerShell 7** 里运行：

```powershell
# 一键脚本（推荐）
irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

使用代理：
```powershell
$env:PWSH_PRETTY_PROXY='http://127.0.0.1:7897'; irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

或克隆后运行：
```powershell
git clone https://github.com/Xynrin/pwsh-pretty.git
cd pwsh-pretty
.\install.ps1          # 交互式；-All 全装，-CoreOnly 只装核心
```

然后**完全关闭并重新打开 Windows Terminal**。

> 首次运行可能需要：`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 🧹 卸载

```powershell
.\uninstall.ps1                # 恢复配置，保留工具
.\uninstall.ps1 -RemoveTools   # 同时卸载已安装的工具
```

## 📚 文档

- **[增强工具](./docs/tools.md)** —— fzf / bat / mdcat / zoxide / fastfetch 用法
- **[自定义](./docs/customization.md)** —— 颜色、主题、`ls` 别名、预测视图
- **[故障排查](./docs/troubleshooting.md)** —— 图标、编码、代理、常见问题

## 🤝 贡献

欢迎 issue 和 PR。请附上 `$PSVersionTable.PSVersion`、是否用了 `-Proxy`、完整报错文本。详见[故障排查](./docs/troubleshooting.md)。

## 📄 许可证

[MIT](./LICENSE) © Xynrin
