# 自定义 / Customization

## 模块化结构 (profile.d)

pwsh-pretty 的 profile 是模块化的。主 `$PROFILE` 只负责按文件名顺序加载同目录 `profile.d/` 下的所有 `*.ps1` 片段：

```text
$PROFILE 所在目录/
├── Microsoft.PowerShell_profile.ps1   # 主入口，自动加载下面的片段
├── my-minimal.omp.json                # 提示符主题
└── profile.d/
    ├── 10-encoding.ps1    # UTF-8 编码
    ├── 20-prompt.ps1      # oh-my-posh 提示符
    ├── 30-eza.ps1         # eza (ls 系列)
    ├── 40-psreadline.ps1  # 补全 / 历史预测
    └── 50-tools.ps1       # bat / mdcat / zoxide / fzf / fastfetch
```

**想加功能**：在 `profile.d/` 丢一个新的 `60-xxx.ps1`，下次开终端自动加载。
**想关某功能**：删掉或重命名（如改成 `.ps1.off`）对应片段即可。
编号决定加载顺序，留有间隔（10/20/30…）方便插入。

---

## 修改提示符

主题文件位于 `config/my-minimal.omp.json`，安装后复制到 `$PROFILE` 同目录。

### 改胶囊颜色
编辑 `path` 段的 `background`（十六进制颜色）：
```jsonc
{
  "type": "path",
  "background": "#3A6EA5",   // ← 路径胶囊背景色
  "foreground": "#ffffff"    // ← 文字颜色
}
```
`git` 段同理，还支持按状态变色（`background_templates`）。改完重开终端生效。

### 换成内置主题
oh-my-posh 自带 100+ 主题，预览全部：
```powershell
Get-PoshThemes
```
然后把 profile 里的 `$poshTheme` 指向你喜欢的 `.omp.json`。

## ls 系列命令

profile 用 eza 定义了这些命令：

| 命令 | 作用 |
|---|---|
| `ls` | 图标 + 颜色，目录优先 |
| `ll` | 长格式 |
| `la` | 长格式，含隐藏文件 |
| `lt` | 树状视图（2 层） |

想改默认参数，编辑 profile 里 `$ezaBase` 那一行。

## 历史预测视图

profile 默认用 `InlineView`（行尾灰字单条建议）。想换成下拉列表式：
```powershell
Set-PSReadLineOption -PredictionViewStyle ListView
```
改 profile 里对应那行即可。

## 编码

profile 开头强制 UTF-8，修复中文文件名和图标乱码。这是中文 Windows 上最常见的"图标乱码"根因，建议保留。
