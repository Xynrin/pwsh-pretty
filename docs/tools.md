# 增强工具 / Enhanced Tools

pwsh-pretty 在核心美化（提示符 + `ls`）之外，可选集成以下命令行工具。安装时会逐个询问，已安装的会自动跳过；profile 按"工具是否存在"条件加载，没装的不会报错。

| 工具 | 命令 / 快捷键 | 作用 | 安装来源 |
|---|---|---|---|
| [bat](https://github.com/sharkdp/bat) | `cat <file>` | 语法高亮 + 行号的 cat | scoop |
| [mdcat](https://github.com/BIRSAx2/mdcat) | `md <file.md>` | 终端内渲染 Markdown | GitHub release 2.9.1 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z <关键词>` | 智能 cd，按使用频率跳转 | scoop |
| [fzf](https://github.com/junegunn/fzf) | `Ctrl+T` / `Ctrl+R` | 模糊查找文件 / 历史命令 | scoop |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | `ff` | 系统信息展示 | scoop |
| pget (内置) | `pget [词]` | fzf 包管理 TUI（搜索→多选→安装） | 依赖 fzf + scoop |

## pget — fzf 包管理 TUI

灵感来自 [shorin-contrib 的 pac](https://github.com/SHORiN-KiWATA/shorin-contrib/blob/main/pacman/pac)，把 fzf 和包管理器组合成一个交互式安装界面。

```powershell
pget              # 浏览全部 scoop 包
pget git          # 搜索含 "git" 的包
pget -w obsidian  # 改用 winget 搜索（较慢，走微软源）
pget -h           # 帮助
```

- 在 fzf 界面里：`Tab` 多选、`Enter` 安装选中的（可批量）、`Esc` 退出
- 已安装的包标记绿色 `✔`；蓝色=scoop，紫色=winget
- 预览窗口显示 `scoop info`
- **默认用 scoop**（本地索引，秒出结果）；`-w` 切到 winget（网络慢，按需用）


## 用法详解

### bat — 更好的 cat
安装后 `cat` 自动指向 bat，带语法高亮和行号。查看原始内容用 `bat --plain` 或 `Get-Content`。

### mdcat — Markdown 渲染
```powershell
md README.md
```
在终端里以富文本样式渲染 Markdown（标题、列表、代码块、链接）。本项目固定使用 mdcat **2.9.1**，从 [BIRSAx2/mdcat](https://github.com/BIRSAx2/mdcat) 的 release 安装，部署到 `$PROFILE` 同目录的 `bin/` 下。

### zoxide — 智能跳转
```powershell
z proj      # 跳转到最常访问的、路径含 "proj" 的目录
z           # 配合 fzf 交互选择
```
zoxide 会记住你 `cd` 过的目录，用 `z 关键词` 即可快速跳转。

### fzf — 模糊查找
- `Ctrl+T`：在当前目录模糊查找文件，插入到命令行
- `Ctrl+R`：模糊搜索命令历史

通过 PSReadLine 原生键绑定直接调用 fzf，**不依赖 PSFzf 模块**（PSFzf 仅发布于 PowerShell Gallery，部分网络不可达，且其 GitHub 源码版需要构建）。这样更轻量、更可靠。

### fastfetch — 系统信息
```powershell
ff          # 显示系统信息（OS、CPU、内存、终端等）
```
默认不在启动时自动运行（避免拖慢开终端）。若想开机自动显示，编辑 profile，取消 fastfetch 区块里那行注释。

## 安装控制

```powershell
.\install.ps1            # 交互式逐个询问
.\install.ps1 -All       # 安装全部增强工具，不询问
.\install.ps1 -CoreOnly  # 只装核心，跳过所有增强工具
```
