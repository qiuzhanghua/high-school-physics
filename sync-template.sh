#!/usr/bin/env bash
#
# sync-template.sh — 从 typst-notes 源仓重新生成本仓的 template.typ
#
# 用法：
#   ./sync-template.sh            重新生成 template.typ（内容不变时不写入）
#   ./sync-template.sh --check    只校验是否与源一致，不一致则退出码 1（给 CI 用）
#   ./sync-template.sh --help     显示帮助
#
# 源仓查找顺序：
#   1. $TYPST_NOTES_DIR/lib.typ
#   2. 同级目录 ../typst-notes/lib.typ
#   3. 从 GitHub 取（$TYPST_NOTES_REPO，默认 qiuzhanghua/typst-notes）
#
# 每仓差异只来自仓库根目录的 .template.conf（TAG 与 EQNUM 两项）。
#
set -euo pipefail

CHECK=0
case "${1:-}" in
  -h|--help)
    sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  --check) CHECK=1 ;;
  "") ;;
  *) echo "未知参数：$1（用 --help 查看用法）" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$ROOT/.template.conf"
[ -f "$CONF" ] || { echo "缺少 $CONF" >&2; exit 1; }

# shellcheck disable=SC1090
. "$CONF"
: "${TAG:?$CONF 里缺少 TAG}"
: "${EQNUM:?$CONF 里缺少 EQNUM}"
REPO_URL="${TYPST_NOTES_REPO:-qiuzhanghua/typst-notes}"

SRC=""
SRC_URL=""
if [ -n "${TYPST_NOTES_DIR:-}" ] && [ -f "$TYPST_NOTES_DIR/lib.typ" ]; then
  SRC="$TYPST_NOTES_DIR/lib.typ"
elif [ -f "$ROOT/../typst-notes/lib.typ" ]; then
  SRC="$ROOT/../typst-notes/lib.typ"
else
  URL="https://raw.githubusercontent.com/$REPO_URL/$TAG/lib.typ"
  echo "本地没有源仓，从 $URL 取…" >&2
  SRC_URL="$URL"
fi

TMP="$(mktemp)"
BODY_TMP="$(mktemp)"
trap 'rm -f "$TMP" "$BODY_TMP"' EXIT

if [ -n "$SRC" ]; then
  cp "$SRC" "$BODY_TMP"
else
  curl -fsSL "$SRC_URL" -o "$BODY_TMP" || { echo "取不到 $SRC_URL" >&2; exit 1; }
fi
if ! grep -q '@@EQNUM@@' "$BODY_TMP"; then
  echo "警告：源里没有 @@EQNUM@@ 占位符，公式编号将沿用源内默认值" >&2
fi

BANNER="// ============================================================
// template.typ — 自动生成，请勿手工修改
// 源：typst-notes@$TAG（lib.typ）
// 重新生成：./sync-template.sh（Windows 用 ./sync-template.ps1）
// 本仓公式编号默认值：$EQNUM
// ============================================================"

{ printf '%s\n\n' "$BANNER"; sed "s|@@EQNUM@@|$EQNUM|g" "$BODY_TMP"; } > "$TMP"

if [ -f "$ROOT/template.typ" ] && cmp -s "$TMP" "$ROOT/template.typ"; then
  echo "template.typ 已是最新（typst-notes@$TAG）"
  exit 0
fi

if [ "$CHECK" -eq 1 ]; then
  echo "template.typ 与 typst-notes@$TAG 不一致，请运行 ./sync-template.sh 后提交" >&2
  exit 1
fi

mv "$TMP" "$ROOT/template.typ"
echo "已更新 template.typ（typst-notes@$TAG，公式编号 $EQNUM）"
