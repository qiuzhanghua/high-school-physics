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
# 各仓差异全部来自仓库根目录的 .template.conf 的 KEY=VALUE：
#   TAG=v1.0.2          源仓版本（不同占位符替换）
#   EQNUM='"(1)"'       替换 lib.typ 里的 @@EQNUM@@（公式编号）
#   TEXTSIZE=16pt       替换 @@TEXTSIZE@@（正文字号）
# conf 里没写的占位符用下面的 DEFAULTS 兜底；想新增可变项，在 lib.typ 写
# @@新键名@@ 并把它加进 DEFAULTS 即可。
#
set -euo pipefail

CHECK=0
case "${1:-}" in
  -h|--help)
    sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  --check) CHECK=1 ;;
  "") ;;
  *) echo "未知参数：$1（用 --help 查看用法）" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$ROOT/.template.conf"
[ -f "$CONF" ] || { echo "缺少 $CONF" >&2; exit 1; }

# conf 里没写时的兜底值（Typst 字面量）
DEFAULTS="EQNUM=none TEXTSIZE=12pt"

# shellcheck disable=SC1090
. "$CONF"
: "${TAG:?$CONF 里缺少 TAG}"
REPO_URL="${TYPST_NOTES_REPO:-qiuzhanghua/typst-notes}"

default_of() {
  local kv
  for kv in $DEFAULTS; do
    [ "${kv%%=*}" = "$1" ] && { printf '%s' "${kv#*=}"; return 0; }
  done
  return 1
}

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

# 参与替换的键 = conf 里出现的键 + DEFAULTS 里的键，去掉 TAG，排序保证可复现
KEYS="$( { grep -oE '^[A-Z_][A-Z0-9_]*' "$CONF" || true
           for kv in $DEFAULTS; do printf '%s\n' "${kv%%=*}"; done; } \
         | grep -vx TAG | sort -u)"

SED_ARGS=()
PARAM_DESC=""
for k in $KEYS; do
  v="${!k:-$(default_of "$k")}"
  case "$v" in
    *'|'*) echo "conf 里的 $k 含有 '|'，无法用于替换" >&2; exit 1 ;;
  esac
  SED_ARGS+=(-e "s|@@$k@@|$v|g")
  PARAM_DESC="$PARAM_DESC $k=$v"
done
PARAM_DESC="${PARAM_DESC# }"

BANNER="// ============================================================
// template.typ — 自动生成，请勿手工修改
// 源：typst-notes@$TAG（lib.typ）
// 重新生成：./sync-template.sh（Windows 用 ./sync-template.ps1）
// 本仓参数：$PARAM_DESC
// ============================================================"

{ printf '%s\n\n' "$BANNER"; sed "${SED_ARGS[@]}" "$BODY_TMP"; } > "$TMP"

if LEFT="$(grep -oE '@@[A-Z_]+@@' "$TMP" | sort -u | tr '\n' ' ')" && [ -n "$LEFT" ]; then
  echo "警告：这些占位符没有对应取值，将原样留在 template.typ 里：$LEFT" >&2
  echo "      在 .template.conf 里写上对应 KEY=VALUE 即可。" >&2
fi

if [ -f "$ROOT/template.typ" ] && cmp -s "$TMP" "$ROOT/template.typ"; then
  echo "template.typ 已是最新（typst-notes@$TAG）"
  exit 0
fi

if [ "$CHECK" -eq 1 ]; then
  MSG="template.typ 与 typst-notes@$TAG 不一致，请运行 ./sync-template.sh 后提交"
  echo "$MSG" >&2
  # 在 GitHub Actions 里额外的注解，让失败信息直接标在 diff 上
  [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error::$MSG"
  exit 1
fi

mv "$TMP" "$ROOT/template.typ"
echo "已更新 template.typ（typst-notes@$TAG，$PARAM_DESC）"
