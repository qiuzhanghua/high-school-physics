# high-school-physics

高中物理模型讲义（Typst）。每个 `.typ` 文档独立成篇，共用 `template.typ`。

## 目录结构

```
template.typ              文档模板（页面、字体、标题样式、定义/定理等环境）
卷扬机收绳拉船.typ          正文文档
figures/                  插图（CeTZ 绘制，可单独编译预览）
build                     批量编译脚本（Linux / macOS / Git Bash）
build.ps1                 批量编译脚本（Windows PowerShell）
```

## 编译

```bash
./build                  # 编译目录下所有 .typ（自动跳过 template.typ）
./build 卷扬机收绳拉船     # 只编译指定文档（可省略 .typ）
./build -o dist          # 输出 PDF 到 dist/
```

PowerShell 下用 `./build.ps1`（参数为 `-Only 卷扬机收绳拉船`、`-OutputDir dist`）。

编译后 PDF 与源文件同目录（`.gitignore` 已忽略 `*.pdf`）。

## 字体依赖：思源宋体（Source Han Serif）

`template.typ` 里把正文字体写成了

```typst
#let text-fonts = ("New Computer Modern Math", "Source Han Serif")
#let cjk-font = "Source Han Serif"
```

所以中文字形依赖系统里装有 **Source Han Serif**（思源宋体，Google 版的等价字体是
`Noto Serif CJK SC`）。**缺失时 Typst 不会报错，而是静默回退到系统其他中文字体**，
版面会悄悄变样——换机器编译前最好先查一下。

### 检查是否已装

```bash
typst fonts | grep -i "source han serif"      # Linux / macOS
typst fonts | Select-String "Source Han Serif" # Windows PowerShell
```

只要列出 `Source Han Serif`（或 `Noto Serif CJK SC`）即可。本仓库已在 macOS 上实测：

- 本机装的是**可变字体**（`SourceHanSerifVF-*.ttf`），weight 250–900 全档可用；
- 正文默认 = weight 400（Regular），`#strong[...]` = 700（Bold），正常；
- 用到的 521 个非 ASCII 字符（简体、繁体、中文标点、希腊字母、数学符号）**全部有字形**；
- `Source Han Serif CN / TC / TW` 这几个**族名**查不到，但字形已被 `SC`（简体）与
  `HC / HK`（繁体、港区）覆盖，不影响使用；`Source Han Serif Light / Medium / Bold`
  这类"按字重命名的族"也查不到，属正常——字重请用 `weight:` 选择，不要换族名。

### 下载安装

| 来源 | 地址 |
|---|---|
| Adobe 官方（思源宋体，含各语言子集与可变字体） | <https://github.com/adobe-fonts/source-han-serif/releases> |
| Google Noto（等价字体 `Noto Serif CJK SC`） | <https://github.com/notofonts/noto-cjk/releases> |

装完后：

- **Windows**：右键 `.ttf` / `.otf` → "为所有用户安装"（或直接选字体文件安装）；
- **macOS**：双击字体文件 → "安装字体"（或放到 `~/Library/Fonts/`）；
- **Linux**：把字体文件复制到 `~/.local/share/fonts/`（或 `/usr/share/fonts/`），
  然后执行 `fc-cache -fv`。

### 字符覆盖自检（可选）

想把仓库里用到的所有非 ASCII 字符丢给 Typst 渲染一遍、看有没有缺字，可以跑：

```bash
python3 - <<'PY'
import glob, io
chars = set()
for p in ["卷扬机收绳拉船.typ", "template.typ"] + glob.glob("figures/*.typ"):
    chars |= {c for c in io.open(p, encoding="utf-8").read() if ord(c) > 0x2000}
io.open("/tmp/cover.typ", "w", encoding="utf-8").write(
    '#set page(width: 18cm, height: auto, margin: 1cm)\n'
    '#set text(font: ("New Computer Modern Math", "Source Han Serif"), lang: "zh", size: 16pt)\n'
    + "".join(sorted(chars)))
print("待检测字符数:", len(chars))
PY
typst compile /tmp/cover.typ /tmp/cover.pdf    # 输出里出现 warning/missing 才说明缺字
```

### 换字体

若目标机器上确实没有思源宋体，也可以改用其他中文字体（把 `template.typ` 顶部的
`text-fonts` / `cjk-font` 换掉即可），例如 `"Noto Serif CJK SC"`、`"Source Han Sans SC"`、
`"Sarasa Gothic SC"`。注意只改字体**列表的最后一项**，不要用
`#set text(font: ...)` 做单字体覆盖，否则会顶掉数学字体、中文失去 CJK 回退。

## 插图依赖：CeTZ

`figures/` 下的插图用 [CeTZ](https://typst.app/universe/package/cetz/) 绘制，目前已指定
**0.5.2** 版本（`#import "@preview/cetz:0.5.2": ...`）。

> **版本注意**
>
> - CeTZ 0.3.1 / 0.3.2 在 **Typst 0.15 及以上**无法渲染，画布会报
>   `expected path or string, found array`（旧版用 `..vertices` 展开交给 `path()`，
>   而 Typst 0.15 已改为 `std.curve()`）。请使用 0.3.3+。
> - 0.5.2 要求 Typst ≥ 0.14（其 `typst.toml` 声明 `compiler = "0.14.0"`），
>   本仓库用 Typst 0.15.1 实测通过。升级前后渲染几乎完全一致：139 万像素中仅 1 个
>   像素有 ±1 的灰度取整差异（0.5 版提高了浮点取整精度），版面、字号、线宽、箭头均无变化。
> - 从 0.4 起 CeTZ 增加了一个第三方依赖 **`@preview/oxifmt:1.0.0`**
>   （0.3.4 依赖的是 `oxifmt:0.2.1`）。首次编译时 Typst 会一并下载；若离线安装，
>   两个包都要放好，否则会报 `failed to load package`。

### 正常情况下：什么都不用做

Typst 编译时会自动从官方包仓库下载 `@preview/cetz:0.5.2` 及其依赖
`@preview/oxifmt:1.0.0` 并缓存到本地，之后同一台机器上离线也能编译。
直接 `./build` 即可，无需任何额外参数。

包下载地址（自动下载用的就是这个）：

```
https://packages.typst.org/preview/cetz-0.5.2.tar.gz
https://packages.typst.org/preview/oxifmt-1.0.0.tar.gz
```

### 手动下载（首次编译无法联网 / 公司网络受限时）

在**能联网的机器或终端**上执行以下任一方式，把包放进 Typst 的包缓存目录。
**两个包都要装**：`cetz` 和它依赖的 `oxifmt`。

#### 方式一：直接下载 tar.gz 解包

```bash
# 1. 下载（两个包）
curl -LO https://packages.typst.org/preview/cetz-0.5.2.tar.gz
curl -LO https://packages.typst.org/preview/oxifmt-1.0.0.tar.gz

# 2. 建好缓存目录
#    Linux
mkdir -p ~/.cache/typst/packages/preview/cetz/0.5.2
mkdir -p ~/.cache/typst/packages/preview/oxifmt/1.0.0
#    macOS
mkdir -p ~/Library/Caches/typst/packages/preview/cetz/0.5.2
mkdir -p ~/Library/Caches/typst/packages/preview/oxifmt/1.0.0
#    Windows (PowerShell)
#    mkdir -Force "$env:LOCALAPPDATA\typst\packages\preview\cetz\0.5.2"
#    mkdir -Force "$env:LOCALAPPDATA\typst\packages\preview\oxifmt\1.0.0"

# 3. 解包到对应目录（tar.gz 内直接是 src/、typst.toml 等文件）
tar -xzf cetz-0.5.2.tar.gz   -C ~/Library/Caches/typst/packages/preview/cetz/0.5.2    # macOS
tar -xzf oxifmt-1.0.0.tar.gz -C ~/Library/Caches/typst/packages/preview/oxifmt/1.0.0  # macOS
# Linux 把路径换成 ~/.cache/typst/... 即可
```

解包后目录应为：

```
<packages>/preview/
├── cetz/0.5.2/
│   ├── src/
│   ├── typst.toml
│   └── LICENSE
└── oxifmt/1.0.0/
    ├── oxifmt.typ
    ├── typst.toml
    └── LICENSE
```

#### 方式二：从 GitHub 源码仓库下载

```bash
curl -LO https://codeload.github.com/cetz-package/cetz/zip/refs/tags/v0.5.2
unzip v0.5.2            # 得到 cetz-0.5.2/
cp -R cetz-0.5.2/src cetz-0.5.2/typst.toml cetz-0.5.2/LICENSE \
      ~/Library/Caches/typst/packages/preview/cetz/0.5.2/    # macOS 路径按上表替换
```

（`oxifmt` 不在同一仓库，仍按方式一下载；它只有 `oxifmt.typ` + `typst.toml`，直接解包即可。）

#### 方式三：跟随上游最新版

CeTZ 上游 master 与 0.5.x 同步演进。若想改用别的版本，把两张图里的 `0.5.2`
换成目标版本号，并按方式一/二把对应版本放进缓存；同时确认该版本依赖的
`oxifmt` 版本（见包内 `src/deps.typ`）也已装好。

### 校验是否装好

```bash
typst compile figures/winch-boat.typ /tmp/fig.pdf   # 应无报错，/tmp/fig.pdf 非空
```

### 离线/受限网络的另一种办法：本地包目录

若不想动全局缓存，也可以把包放在仓库外的任意目录，编译时显式指定：

```bash
typst compile --package-path /path/to/packages 卷扬机收绳拉船.typ
```

只要该目录下是 `preview/cetz/0.5.2/...` 与 `preview/oxifmt/1.0.0/...` 这一结构即可
（缺 `oxifmt` 会报 `failed to load package`）。本仓库**不再**内置该目录，
需要时请自行放置，或用上面的方式装进缓存。
