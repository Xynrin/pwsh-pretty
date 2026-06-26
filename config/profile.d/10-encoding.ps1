# 10-encoding.ps1 — 强制 UTF-8 (修复 ls 图标 / 中文文件名乱码)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
