<div align="center">

# ✨ pwsh-pretty

**Turn a bland PowerShell 7 into a beautiful, productive shell — in one command.**

A clean minimal prompt · icon-rich `ls` · history autosuggestions · automatic Windows Terminal font setup.
Built for **Windows + PowerShell 7**, friendly to **restricted networks** (scoop-based, proxy supported).

**English** | [简体中文](./README.zh-CN.md)

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

</div>

---

## 📸 Preview

![pwsh-pretty preview](./assets/preview.png)

The path sits in a rounded, colored capsule so it never blends into the previous command's output. The arrow on line two turns **green on success** and **red on failure**, giving you instant feedback without reading exit codes. `ls` shows colored Nerd Font icons with directories first.

---

## 📑 Table of Contents

- [Features](#-features)
- [What gets installed](#-what-gets-installed)
- [Requirements](#-requirements)
- [Quick start](#-quick-start)
- [Options](#-options)
- [Uninstall](#-uninstall)
- [Customizing](#-customizing)
- [Troubleshooting](#-troubleshooting)
- [Project structure](#-project-structure)
- [Why these choices](#-why-these-choices)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Features

| | Feature | Detail |
|---|---|---|
| 🎯 | **Minimal two-line prompt** | Path in a rounded capsule + Git branch/status; input arrow colored by exit code |
| 🎨 | **Icon-rich `ls`** | [eza](https://github.com/eza-community/eza) with colored icons, `ll` / `la` / `lt` helpers, directories first |
| ⌨️ | **History autosuggestions** | Inline gray hint from history as you type — press `→` to accept |
| 🈶 | **UTF-8 by default** | Fixes garbled non-ASCII filenames and icons (the classic `gb2312` problem) |
| 🔤 | **Auto font setup** | Sets Windows Terminal's default font to a Nerd Font automatically |
| 🌐 | **Network-friendly** | scoop-based install with an optional `-Proxy` flag — works behind the GFW |
| ↩️ | **Fully reversible** | Backs up your existing config; `uninstall.ps1` restores everything |

---

## 📦 What gets installed

| Tool | Purpose | Source |
|---|---|---|
| [scoop](https://scoop.sh) | package manager | auto-installed if missing |
| [oh-my-posh](https://ohmyposh.dev) | prompt engine | scoop |
| [eza](https://github.com/eza-community/eza) | modern `ls` | scoop |
| JetBrainsMono Nerd Font | icon font | scoop · `nerd-fonts` bucket |

Plus two files deployed next to your `$PROFILE`:
- `Microsoft.PowerShell_profile.ps1` — the profile that wires everything up
- `my-minimal.omp.json` — the oh-my-posh theme

---

## ✅ Requirements

- **Windows 10 / 11**
- **[PowerShell 7+](https://github.com/PowerShell/PowerShell)** — run the installer from `pwsh`, not Windows PowerShell 5.1
- **[Windows Terminal](https://aka.ms/terminal)** (recommended, for proper font & color support)

> Check your version: `$PSVersionTable.PSVersion` should report `7.x`.

---

## 🚀 Quick start

### Option A — one-liner (recommended)

Run this in **PowerShell 7**:

```powershell
irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

Behind a proxy? Set it first:

```powershell
$env:PWSH_PRETTY_PROXY='http://127.0.0.1:7897'; irm https://raw.githubusercontent.com/Xynrin/pwsh-pretty/main/bootstrap.ps1 | iex
```

> Want to skip the font? `$env:PWSH_PRETTY_SKIPFONT='1'` before running.

### Option B — clone & run

```powershell
git clone https://github.com/Xynrin/pwsh-pretty.git
cd pwsh-pretty
.\install.ps1
```

Then **fully close and reopen Windows Terminal**. That's it.

> First run may need to allow scripts:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

---

## ⚙️ Options

### Behind a proxy (recommended in mainland China)

```powershell
.\install.ps1 -Proxy http://127.0.0.1:7897
```

The proxy is applied to scoop, git, and font downloads for the duration of the install.

### Already have a Nerd Font?

```powershell
.\install.ps1 -SkipFont
```

Skips font download and Windows Terminal font configuration.

---

## 🧹 Uninstall

```powershell
.\uninstall.ps1
```

Restores the profile and Windows Terminal settings backed up during install, and removes the deployed theme. Your shell returns to exactly how it was.

To also remove the installed tools:

```powershell
.\uninstall.ps1 -RemoveTools   # also uninstalls oh-my-posh, eza, and the font
```

---

## 🎨 Customizing

The theme lives at `config/my-minimal.omp.json` (and is copied next to your `$PROFILE` on install).

**Change the capsule color** — edit the `background` value of the `path` segment:

```jsonc
{
  "type": "path",
  "background": "#3A6EA5",   // ← change me (hex color)
  "foreground": "#ffffff"
}
```

**Use a different built-in theme instead** — list all bundled oh-my-posh themes:

```powershell
Get-PoshThemes
```

Then point the profile's `$poshTheme` at the one you like.

**`ls` helpers** added by the profile:

| Command | Does |
|---|---|
| `ls` | icons + colors, directories first |
| `ll` | long format |
| `la` | long format incl. hidden files |
| `lt` | tree view (2 levels) |

---

## 🛠 Troubleshooting

<details>
<summary><b>Icons show as boxes □ or question marks</b></summary>

Your Windows Terminal font isn't a Nerd Font. Open `Settings (Ctrl+,) → Defaults → Appearance → Font face` and choose **JetBrainsMono Nerd Font**. The installer tries to set this automatically, but a manual profile may override it.
</details>

<details>
<summary><b>Garbled Chinese / non-ASCII characters</b></summary>

The profile forces UTF-8 on startup. If you still see garbling, make sure you reopened the terminal after install, and that the font is a Nerd Font.
</details>

<details>
<summary><b>Install hangs while downloading</b></summary>

You're likely behind a restrictive network. Re-run with `-Proxy http://127.0.0.1:<port>` pointing at your local proxy.
</details>

<details>
<summary><b>Why not Terminal-Icons?</b></summary>

Terminal-Icons' built module is published only on the PowerShell Gallery, whose CDN (`*.azureedge.net`) is frequently unreachable on some networks. eza installs from GitHub via scoop — more reliable, and arguably nicer output.
</details>

<details>
<summary><b>`oh-my-posh` not found after install</b></summary>

Open a new terminal so the updated `PATH` (scoop shims) is picked up. If it persists, run `scoop install oh-my-posh` manually.
</details>

---

## 📂 Project structure

```text
pwsh-pretty/
├── install.ps1              # one-command installer (adaptive, proxy-aware)
├── uninstall.ps1            # restores backups, optional -RemoveTools
├── config/
│   ├── profile.ps1          # the PowerShell profile template
│   └── my-minimal.omp.json  # the oh-my-posh theme (rounded capsule)
├── README.md                # this file
├── README.zh-CN.md          # 简体中文
├── LICENSE                  # MIT
├── .gitattributes           # CRLF for .ps1, LF for the rest
└── .gitignore
```

---

## 🤔 Why these choices

- **scoop over winget/PSGallery** — scoop pulls from GitHub releases, which stay reachable behind common proxies; PSGallery's CDN often does not.
- **eza over Terminal-Icons** — a standalone binary with no module-loading quirks, installable from GitHub.
- **A hand-written minimal theme** — instead of a busy built-in one, so the path is always easy to spot and the prompt stays out of your way.
- **UTF-8 forced in the profile** — the single most common cause of "broken icons" on Chinese Windows.

---

## 🤝 Contributing

Issues and PRs welcome! If you hit a network/tool edge case, please include:
- `$PSVersionTable.PSVersion`
- whether you used `-Proxy`
- the exact error text

---

## 📄 License

[MIT](./LICENSE) © Xynrin
