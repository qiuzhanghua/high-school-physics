#!/usr/bin/env bash
#
# build.sh — 批量编译本目录下所有 .typ 文档为 PDF（Linux / macOS / Git Bash）
#
# 用法：
#   ./build.sh                     编译全部文档（自动跳过 template.typ）
#   ./build.sh 平方根               只编译指定文档（可省略 .typ 扩展名）
#   ./build.sh --only 韦达定理1     同上，选项形式
#   ./build.sh --output dist        输出 PDF 到指定目录
#   TYPST=typst ./build.sh          指定 typst 可执行文件（默认从 PATH 查找）
#   ./build.sh --help               显示帮助
#
set -u

TYPST="${TYPST:-typst}"
OUTPUT_DIR=""
ONLY=""
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ANSI 颜色（仅终端输出时启用）
if [ -t 1 ]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
else
  GREEN=""; RED=""; NC=""
fi

usage() {
  cat <<'EOF'
用法: ./build.sh [选项] [文档名]

选项:
  -o, --output DIR   输出 PDF 到 DIR（默认与源文件同目录）
  -n, --only NAME    只编译指定文档（NAME 可省略 .typ 扩展名）
  -h, --help         显示本帮助

示例:
  ./build.sh                     # 编译全部
  ./build.sh 平方根               # 只编译 平方根.typ
  ./build.sh -o dist 韦达定理     # 编译 韦达定理.typ 输出到 dist/
  TYPST=/opt/typst ./build.sh    # 指定 typst 路径
EOF
  exit 0
}

# ---- 参数解析 ----
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage ;;
    -o|--output)
      [ $# -ge 2 ] || { echo "错误: $1 需要一个参数" >&2; usage; }
      OUTPUT_DIR="$2"; shift 2 ;;
    --output=*)
      OUTPUT_DIR="${1#*=}"; shift ;;
    -n|--only)
      [ $# -ge 2 ] || { echo "错误: $1 需要一个参数" >&2; usage; }
      ONLY="$2"; shift 2 ;;
    --only=*)
      ONLY="${1#*=}"; shift ;;
    -*)
      echo "未知参数: $1" >&2; usage ;;
    *)
      [ -z "$ONLY" ] || { echo "错误: 多余参数 $1" >&2; usage; }
      ONLY="$1"; shift ;;
  esac
done

# 补全 .typ 扩展名
if [ -n "$ONLY" ] && [[ "$ONLY" != *.typ ]]; then
  ONLY="$ONLY.typ"
fi

# ---- 检查 typst ----
if ! command -v "$TYPST" >/dev/null 2>&1; then
  echo "错误: 找不到 typst 可执行文件（$TYPST）。" >&2
  echo "  Linux:   安装请见 https://github.com/typst/typst/releases 或系统包管理器" >&2
  echo "  macOS:   brew install typst" >&2
  exit 1
fi

# ---- 输出目录 ----
if [ -n "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR" || exit 1
fi

# ---- 编译 ----
failed=0
count=0
matched=0
for f in "$ROOT"/*.typ; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  if [ -n "$ONLY" ] && [ "$name" != "$ONLY" ]; then continue; fi
  [ "$name" = "template.typ" ] && { echo "  跳过模板文件: $name"; continue; }
  matched=1

  if [ -n "$OUTPUT_DIR" ]; then
    out="$OUTPUT_DIR/${name%.typ}.pdf"
  else
    out="${f%.typ}.pdf"
  fi

  echo "==> 编译 $name -> $(basename "$out")"
  if "$TYPST" compile "$f" "$out"; then
    echo "    ${GREEN}[成功]${NC}"
    count=$((count + 1))
  else
    echo "    ${RED}[失败] $name${NC}" >&2
    failed=1
  fi
done

if [ -n "$ONLY" ] && [ "$matched" -eq 0 ]; then
  echo "错误: 未找到文档 $ONLY" >&2
  exit 1
fi

if [ "$failed" -ne 0 ]; then
  echo "" >&2
  echo "${RED}存在编译失败，请检查上方错误信息。${NC}" >&2
  exit 1
fi

echo ""
echo "${GREEN}全部编译完成 ✔（共 $count 个文档）${NC}"
