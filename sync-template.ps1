<#
.SYNOPSIS
    从 typst-notes 源仓重新生成本仓的 template.typ（Windows PowerShell 版）。

.DESCRIPTION
    与 sync-template.sh 行为一致：读取仓库根目录的 .template.conf（TAG、EQNUM），
    把源仓 lib.typ 里的 @@EQNUM@@ 占位符替换掉，连同自动生成的说明头一起写入
    template.typ。内容无变化时不写入。

.PARAMETER Check
    只校验是否与源一致，不一致则退出码 1（给 CI 用）。

.EXAMPLE
    ./sync-template.ps1
    ./sync-template.ps1 -Check
#>
[CmdletBinding()]
param([switch]$Check)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$conf = Join-Path $root ".template.conf"
if (-not (Test-Path -LiteralPath $conf)) { throw "缺少 $conf" }

$cfg = @{}
foreach ($line in Get-Content -LiteralPath $conf) {
    if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
    if ($line -match '^\s*([A-Z_]+)=(.*)$') {
        $v = $Matches[2].Trim()
        if ($v.Length -ge 2) {
            $q = $v.Substring(0, 1)
            if (($q -eq '"' -or $q -eq "'") -and $v.EndsWith($q)) { $v = $v.Substring(1, $v.Length - 2) }
        }
        $cfg[$Matches[1]] = $v
    }
}
if (-not $cfg.ContainsKey("TAG")) { throw ".template.conf 里缺少 TAG" }
if (-not $cfg.ContainsKey("EQNUM")) { throw ".template.conf 里缺少 EQNUM" }
$tag = $cfg["TAG"]
$eqnum = $cfg["EQNUM"]
$repoUrl = if ($env:TYPST_NOTES_REPO) { $env:TYPST_NOTES_REPO } else { "qiuzhanghua/typst-notes" }

$body = $null
if ($env:TYPST_NOTES_DIR -and (Test-Path -LiteralPath (Join-Path $env:TYPST_NOTES_DIR "lib.typ"))) {
    $body = Get-Content -LiteralPath (Join-Path $env:TYPST_NOTES_DIR "lib.typ") -Raw
} else {
    $sibling = Join-Path (Split-Path -Parent $root) "typst-notes/lib.typ"
    if (Test-Path -LiteralPath $sibling) {
        $body = Get-Content -LiteralPath $sibling -Raw
    } else {
        $url = "https://raw.githubusercontent.com/$repoUrl/$tag/lib.typ"
        Write-Host "本地没有源仓，从 $url 取…" -ForegroundColor Yellow
        $body = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    }
}
if ($body.Contains("@@EQNUM@@")) {
    $body = $body.Replace("@@EQNUM@@", $eqnum)
} else {
    Write-Warning "源里没有 @@EQNUM@@ 占位符，公式编号将沿用源内默认值"
}

$banner = @"
// ============================================================
// template.typ — 自动生成，请勿手工修改
// 源：typst-notes@$tag（lib.typ）
// 重新生成：./sync-template.sh（Windows 用 ./sync-template.ps1）
// 本仓公式编号默认值：$eqnum
// ============================================================
"@
$content = $banner + "`n`n" + $body
$target = Join-Path $root "template.typ"

if (Test-Path -LiteralPath $target) {
    $old = Get-Content -LiteralPath $target -Raw
    if ($old -eq $content) { Write-Host "template.typ 已是最新（typst-notes@$tag）"; return }
}

if ($Check) {
    $msg = "template.typ 与 typst-notes@$tag 不一致，请运行 ./sync-template.ps1 后提交"
    Write-Error $msg
    if ($env:GITHUB_ACTIONS) { Write-Host "::error::$msg" }
    exit 1
}

Set-Content -LiteralPath $target -Value $content -NoNewline
Write-Host "已更新 template.typ（typst-notes@$tag，公式编号 $eqnum）" -ForegroundColor Green
