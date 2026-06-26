# pwsh-pretty

**English** | [简体中文](./README.zh-CN.md)

One-command setup to beautify PowerShell 7 on Windows: a clean minimal prompt, icon-rich `ls`, command history prediction, and automatic Windows Terminal font configuration. Friendly to restricted networks (scoop-based, proxy supported).

## Preview

```
   ~/code/myproject    main *
❯ 
```

- **Minimal two-line prompt**: first line shows the path in a rounded background capsule plus Git branch/status; second line is the input arrow (green on success, red on failure)
- **Icon-rich `ls`**: powered by [eza](https://github.com/eza-community/eza) with colored file/folder icons, directories first
- **History prediction**: inline gray suggestion from history as you type, press `→` to accept
- **UTF-8 encoding**: fixes garbled non-ASCII filenames and icons

## Dependencies

| Tool | Purpose | Install |
|---|---|---|
| [scoop](https://scoop.sh) | package manager | auto-installed by script |
| [oh-my-posh](https://ohmyposh.dev) | prompt engine | scoop |
| [eza](https://github.com/eza-community/eza) | modern ls | scoop |
| JetBrainsMono Nerd Font | icon font | scoop (nerd-fonts bucket) |

## Install

> Prerequisite: [PowerShell 7+](https://github.com/PowerShell/PowerShell) installed, and run from PowerShell 7 (`pwsh`).

```powershell
git clone https://github.com/Xynrin/pwsh-pretty.git
cd pwsh-pretty
.\install.ps1
```

### With a proxy

If your network needs a proxy to reach GitHub:

```powershell
.\install.ps1 -Proxy http://127.0.0.1:7897
```

### Skip font install

If you already have a Nerd Font:

```powershell
.\install.ps1 -SkipFont
```

After install, **fully close and reopen Windows Terminal** to apply.

## Uninstall

```powershell
.\uninstall.ps1
```

This restores your pre-install profile and Windows Terminal settings (backed up automatically during install) and removes the deployed theme file.

To also remove oh-my-posh / eza / the font:

```powershell
.\uninstall.ps1 -RemoveTools
```

## FAQ

**`ls` icons show as boxes □?**
The Windows Terminal font isn't set to a Nerd Font. Open `Settings (Ctrl+,) → Defaults → Appearance → Font face` and pick `JetBrainsMono Nerd Font`.

**Garbled icons / non-ASCII characters in the prompt?**
Make sure the font is a Nerd Font; the profile sets UTF-8 automatically — just reopen the terminal.

**Why eza instead of Terminal-Icons?**
Terminal-Icons' built module is published only on the PowerShell Gallery, which is unreachable on some networks. eza installs via scoop from GitHub — more reliable and looks better.

**Stuck while downloading?**
Pass `-Proxy` with your proxy address.

## Customizing the prompt

The theme file is `config/my-minimal.omp.json` (deployed next to `$PROFILE`). To change colors, edit the `background` / `foreground` fields and reopen the terminal.

You can also switch to any built-in oh-my-posh theme — run `Get-PoshThemes` to preview.

## License

[MIT](./LICENSE)
