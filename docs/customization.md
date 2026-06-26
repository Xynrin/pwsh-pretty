# 自定义 / Customization

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
