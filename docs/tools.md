# 增强工具 / Enhanced Tools

pwsh-pretty 在核心美化（提示符 + `ls`）之外，可选集成以下命令行工具。安装时会逐个询问，已安装的会自动跳过；profile 按"工具是否存在"条件加载，没装的不会报错。

| 工具 | 命令 / 快捷键 | 作用 | 安装来源 |
|---|---|---|---|
| [bat](https://github.com/sharkdp/bat) | `cat <file>` | 语法高亮 + 行号的 cat | scoop |
| [mdcat](https://github.com/BIRSAx2/mdcat) | `md <file.md>` | 终端内渲染 Markdown | GitHub release 2.9.1 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z <关键词>` | 智能 cd，按使用频率跳转 | scoop |
| [fzf](https://github.com/junegunn/fzf) + [PSFzf](https://github.com/kelleyma49/PSFzf) | `Ctrl+T` / `Ctrl+R` | 模糊查找文件 / 历史命令 | scoop + GitHub |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | `ff` | 系统信息展示 | scoop |

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

### fzf + PSFzf — 模糊查找
- `Ctrl+T`：在当前目录模糊查找文件，插入到命令行
- `Ctrl+R`：模糊搜索命令历史

PSFzf 模块从 GitHub 安装（PowerShell Gallery 在部分网络下不可达）。即使 PSFzf 安装失败，fzf 本身仍可独立使用。

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
