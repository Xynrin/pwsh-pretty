# pwsh-pretty

[English](./README.md) | **简体中文**

一键美化 Windows 上的 PowerShell 7：漂亮的极简提示符、带图标的 `ls`、命令历史预测，并自动配置 Windows Terminal 字体。对国内网络环境友好（基于 scoop，支持代理）。

## 效果

```
   ~/code/myproject    main *
❯ 
```

- **极简两行提示符**：第一行是带圆角背景胶囊的路径 + Git 分支状态，第二行是输入箭头（命令成功为绿色，失败为红色）
- **带图标的 `ls`**：使用 [eza](https://github.com/eza-community/eza)，文件/文件夹有彩色图标，目录优先排序
- **历史预测**：输入时行尾灰字提示历史命令，按 `→` 接受
- **UTF-8 编码**：修复中文文件名和图标乱码

## 依赖

| 工具 | 用途 | 安装方式 |
|---|---|---|
| [scoop](https://scoop.sh) | 包管理器 | 脚本自动安装 |
| [oh-my-posh](https://ohmyposh.dev) | 提示符引擎 | scoop |
| [eza](https://github.com/eza-community/eza) | 现代化 ls | scoop |
| JetBrainsMono Nerd Font | 图标字体 | scoop (nerd-fonts 桶) |

## 安装

> 前提：已安装 [PowerShell 7+](https://github.com/PowerShell/PowerShell)，并在 PowerShell 7 (`pwsh`) 中运行。

```powershell
git clone https://github.com/Xynrin/pwsh-pretty.git
cd pwsh-pretty
.\install.ps1
```

### 使用代理（国内推荐）

如果你的网络需要代理才能访问 GitHub：

```powershell
.\install.ps1 -Proxy http://127.0.0.1:7897
```

### 跳过字体安装

如果你已经装过 Nerd Font：

```powershell
.\install.ps1 -SkipFont
```

安装完成后，**完全关闭并重新打开 Windows Terminal** 即可生效。

## 卸载

```powershell
.\uninstall.ps1
```

这会恢复你安装前的 profile 和 Windows Terminal 配置（安装时已自动备份），并删除部署的主题文件。

如果想连同 oh-my-posh / eza / 字体一起卸载：

```powershell
.\uninstall.ps1 -RemoveTools
```

## 常见问题

**`ls` 图标显示成方块 □？**
Windows Terminal 字体没切到 Nerd Font。打开 `设置 (Ctrl+,) → 默认值 → 外观 → 字体`，选 `JetBrainsMono Nerd Font`。

**提示符的图标 / 中文乱码？**
确认字体是 Nerd Font；profile 已自动设置 UTF-8 编码，重开终端即可。

**为什么用 eza 而不是 Terminal-Icons？**
Terminal-Icons 的构建版只发布在 PowerShell Gallery，在部分网络环境下无法访问；而 eza 通过 scoop 从 GitHub 安装，更可靠，效果也更好。

**安装时卡在下载？**
加上 `-Proxy` 参数指定你的代理地址。

## 自定义提示符

主题文件在 `config/my-minimal.omp.json`（安装后位于 `$PROFILE` 同目录）。想改颜色，编辑其中的 `background` / `foreground` 字段。改完重开终端生效。

也可以换用 oh-my-posh 的其它内置主题，运行 `Get-PoshThemes` 预览。

## 许可证

[MIT](./LICENSE)
