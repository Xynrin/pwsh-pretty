<div align="center">

# ✨ pwsh-pretty

**一条命令，把朴素的 PowerShell 7 变成好看又顺手的终端。**

极简提示符 · 带图标的 `ls` · 历史命令预测 · 自动配置 Windows Terminal 字体。
专为 **Windows + PowerShell 7** 打造，对**国内网络环境友好**（基于 scoop，支持代理）。

[English](./README.md) | **简体中文**

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/平台-Windows-0078D6?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/许可证-MIT-green)
![Maintained](https://img.shields.io/badge/维护中-是-brightgreen)

</div>

---

## 📸 效果预览

![pwsh-pretty 预览](./assets/preview.png)

路径被放在一个圆角彩色胶囊里，不会和上一行命令的输出糊在一起。第二行的箭头会根据上条命令的结果变色——**成功为绿色，失败为红色**，不用看退出码就知道结果。`ls` 显示彩色 Nerd Font 图标，目录优先排序。

---

## 📑 目录

- [功能特性](#-功能特性)
- [会安装什么](#-会安装什么)
- [环境要求](#-环境要求)
- [快速开始](#-快速开始)
- [可选参数](#-可选参数)
- [卸载](#-卸载)
- [自定义](#-自定义)
- [常见问题](#-常见问题)
- [项目结构](#-项目结构)
- [设计取舍](#-设计取舍)
- [贡献](#-贡献)
- [许可证](#-许可证)

---

## 🌟 功能特性

| | 特性 | 说明 |
|---|---|---|
| 🎯 | **极简两行提示符** | 圆角胶囊里的路径 + Git 分支状态；输入箭头按退出码变色 |
| 🎨 | **带图标的 `ls`** | 基于 [eza](https://github.com/eza-community/eza)，彩色图标，附带 `ll` / `la` / `lt`，目录优先 |
| ⌨️ | **历史预测** | 输入时行尾灰字提示历史命令，按 `→` 接受 |
| 🈶 | **默认 UTF-8** | 修复中文文件名和图标乱码（经典的 `gb2312` 问题） |
| 🔤 | **自动配置字体** | 自动把 Windows Terminal 默认字体设为 Nerd Font |
| 🌐 | **网络友好** | 基于 scoop，支持 `-Proxy` 参数，墙内可用 |
| ↩️ | **完全可逆** | 安装前自动备份；`uninstall.ps1` 可一键还原 |

---

## 📦 会安装什么

| 工具 | 用途 | 来源 |
|---|---|---|
| [scoop](https://scoop.sh) | 包管理器 | 缺失时自动安装 |
| [oh-my-posh](https://ohmyposh.dev) | 提示符引擎 | scoop |
| [eza](https://github.com/eza-community/eza) | 现代化 `ls` | scoop |
| JetBrainsMono Nerd Font | 图标字体 | scoop · `nerd-fonts` 桶 |

另外会在你的 `$PROFILE` 同目录部署两个文件：
- `Microsoft.PowerShell_profile.ps1` — 把一切串起来的配置文件
- `my-minimal.omp.json` — oh-my-posh 主题

---

## ✅ 环境要求

- **Windows 10 / 11**
- **[PowerShell 7+](https://github.com/PowerShell/PowerShell)** — 在 `pwsh` 里运行安装脚本，不是老的 Windows PowerShell 5.1
- **[Windows Terminal](https://aka.ms/terminal)**（推荐，字体与配色支持更好）

> 查看版本：`$PSVersionTable.PSVersion` 应显示 `7.x`。

---

## 🚀 快速开始

### 方式 A —— 一键脚本（推荐）

在 **PowerShell 7** 里运行：

```powershell
irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

需要代理？先设置：

```powershell
$env:PWSH_PRETTY_PROXY='http://127.0.0.1:7897'; irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

> 想跳过字体？运行前设置 `$env:PWSH_PRETTY_SKIPFONT='1'`。

### 方式 B —— 克隆后运行

```powershell
git clone https://github.com/Xynrin/pwsh-pretty.git
cd pwsh-pretty
.\install.ps1
```

然后**完全关闭并重新打开 Windows Terminal**，搞定。

> 首次运行如果提示禁止运行脚本：
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

---

## ⚙️ 可选参数

### 使用代理（国内推荐）

```powershell
.\install.ps1 -Proxy http://127.0.0.1:7897
```

代理会在安装期间应用到 scoop、git 和字体下载。

### 已经装过 Nerd Font？

```powershell
.\install.ps1 -SkipFont
```

跳过字体下载和 Windows Terminal 字体配置。

---

## 🧹 卸载

```powershell
.\uninstall.ps1
```

恢复安装时备份的 profile 和 Windows Terminal 配置，并删除部署的主题。终端回到安装前的样子。

如果想连工具一起卸载：

```powershell
.\uninstall.ps1 -RemoveTools   # 同时卸载 oh-my-posh、eza 和字体
```

---

## 🎨 自定义

主题文件位于 `config/my-minimal.omp.json`（安装后会复制到 `$PROFILE` 同目录）。

**改胶囊颜色** —— 编辑 `path` 段的 `background`：

```jsonc
{
  "type": "path",
  "background": "#3A6EA5",   // ← 改这里（十六进制颜色）
  "foreground": "#ffffff"
}
```

**换成其它内置主题** —— 列出 oh-my-posh 自带的全部主题：

```powershell
Get-PoshThemes
```

然后把 profile 里的 `$poshTheme` 指向你喜欢的那个。

**profile 提供的 `ls` 系列命令：**

| 命令 | 作用 |
|---|---|
| `ls` | 图标 + 颜色，目录优先 |
| `ll` | 长格式 |
| `la` | 长格式，含隐藏文件 |
| `lt` | 树状视图（2 层） |

---

## 🛠 常见问题

<details>
<summary><b>图标显示成方块 □ 或问号</b></summary>

Windows Terminal 字体不是 Nerd Font。打开 `设置 (Ctrl+,) → 默认值 → 外观 → 字体`，选 **JetBrainsMono Nerd Font**。安装脚本会尝试自动设置，但如果你的某个配置文件单独覆盖了字体，需要手动改。
</details>

<details>
<summary><b>中文 / 非 ASCII 字符乱码</b></summary>

profile 启动时已强制 UTF-8。如果仍乱码，确认安装后重开了终端，且字体是 Nerd Font。
</details>

<details>
<summary><b>安装时卡在下载</b></summary>

多半是网络受限。加 `-Proxy http://127.0.0.1:<端口>` 指向你的本地代理重新运行。
</details>

<details>
<summary><b>为什么不用 Terminal-Icons？</b></summary>

Terminal-Icons 的构建版只发布在 PowerShell Gallery，其后端 CDN（`*.azureedge.net`）在部分网络下经常无法访问。eza 通过 scoop 从 GitHub 安装，更可靠，输出也更好看。
</details>

<details>
<summary><b>安装后找不到 oh-my-posh</b></summary>

开一个新终端，让更新后的 `PATH`（scoop shims）生效。若仍不行，手动运行 `scoop install oh-my-posh`。
</details>

---

## 📂 项目结构

```text
pwsh-pretty/
├── install.ps1              # 一键安装（自适应，支持代理）
├── uninstall.ps1            # 恢复备份，可选 -RemoveTools
├── config/
│   ├── profile.ps1          # PowerShell profile 模板
│   └── my-minimal.omp.json  # oh-my-posh 主题（圆角胶囊）
├── README.md                # 英文
├── README.zh-CN.md          # 本文件
├── LICENSE                  # MIT
├── .gitattributes           # .ps1 用 CRLF，其它用 LF
└── .gitignore
```

---

## 🤔 设计取舍

- **用 scoop 而非 winget/PSGallery** —— scoop 从 GitHub releases 拉取，常见代理下可达；PSGallery 的 CDN 往往不行。
- **用 eza 而非 Terminal-Icons** —— 独立二进制，没有模块加载的坑，可从 GitHub 安装。
- **手写极简主题** —— 而不是信息很满的内置主题，让路径始终好找、提示符不碍事。
- **profile 里强制 UTF-8** —— 中文 Windows 上"图标乱码"最常见的根因。

---

## 🤝 贡献

欢迎 issue 和 PR！如果你遇到网络/工具的边缘情况，请附上：
- `$PSVersionTable.PSVersion`
- 是否用了 `-Proxy`
- 完整的报错文本

---

## 📄 许可证

[MIT](./LICENSE) © Xynrin
