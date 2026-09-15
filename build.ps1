<#
.SYNOPSIS
    批量编译本目录下所有 .typ 文档为 PDF（自动跳过模板文件 template.typ）。

.DESCRIPTION
    遍历脚本所在目录下的 *.typ 文件，逐个调用 typst compile 生成同名 PDF。
    任一文件编译失败时，脚本汇总失败列表并以非零码退出。

.PARAMETER TypstPath
    typst 可执行文件路径，默认使用 PATH 中的 "typst"。

.PARAMETER OutputDir
    输出 PDF 的目录；留空表示与源文件同目录。

.PARAMETER Only
    只编译指定文件（不含 .typ 扩展名），例如 -Only 平方根。

.EXAMPLE
    ./build.ps1
    ./build.ps1 -Only 韦达定理
    ./build.ps1 -OutputDir dist
#>
[CmdletBinding()]
param(
    [string]$TypstPath = "typst",
    [string]$OutputDir = "",
    [string]$Only = ""
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

if ($Only -ne "" -and -not $Only.EndsWith(".typ")) { $Only += ".typ" }

$files = Get-ChildItem -LiteralPath $root -Filter *.typ -File | Sort-Object Name
$failed = @()

foreach ($f in $files) {
    if ($f.Name -eq "template.typ") {
        Write-Host "  跳过模板文件: $($f.Name)"
        continue
    }
    if ($Only -ne "" -and $f.Name -ne $Only) { continue }

    $out = if ($OutputDir -ne "") {
        Join-Path $OutputDir ($f.BaseName + ".pdf")
    } else {
        Join-Path $f.DirectoryName ($f.BaseName + ".pdf")
    }

    Write-Host "==> 编译 $($f.Name) -> $(Split-Path $out -Leaf)"
    & $TypstPath compile $f.FullName $out 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    [失败] $($f.Name)" -ForegroundColor Red
        $failed += $f.Name
    } else {
        Write-Host "    [成功]" -ForegroundColor Green
    }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "编译失败: $($failed -join ', ')" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "全部编译完成 ✔" -ForegroundColor Green
