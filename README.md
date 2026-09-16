# high-school-physics

高中物理模型讲义（Typst）。每个 `.typ` 文档独立成篇，共用 `template.typ`。

## 目录结构

```
template.typ              文档模板（页面、字体、标题样式、定义/定理等环境）
卷扬机收绳拉船.typ          正文文档
图/                       插图（CeTZ 绘制，可单独编译预览）
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

## 插图依赖：CeTZ

`图/` 下的插图用 [CeTZ](https://typst.app/universe/package/cetz/) 绘制，目前已指定
**0.3.4** 版本（`#import "@preview/cetz:0.3.4": ...`）。

> 注意：CeTZ 0.3.1 / 0.3.2 在 **Typst 0.15 及以上**无法渲染，画布会报
> `expected path or string, found array`（旧版用 `..vertices` 展开交给 `path()`，
> 而 Typst 0.15 已改为 `std.curve()`）。请使用 0.3.3+ ，本文档用 0.3.4。

### 正常情况下：什么都不用做

Typst 编译时会自动从官方包仓库下载 `@preview/cetz:0.3.4` 并缓存到本地，
之后同一台机器上离线也能编译。直接 `./build` 即可，无需任何额外参数。

包下载地址（自动下载用的就是这个）：

```
https://packages.typst.org/preview/cetz-0.3.4.tar.gz
```

### 手动下载（首次编译无法联网 / 公司网络受限时）

在**能联网的机器或终端**上执行以下任一方式，把包放进 Typst 的包缓存目录。

#### 方式一：直接下载 tar.gz 解包

```bash
# 1. 下载
curl -LO https://packages.typst.org/preview/cetz-0.3.4.tar.gz

# 2. 建好缓存目录
#    Linux
mkdir -p ~/.cache/typst/packages/preview/cetz/0.3.4
#    macOS
mkdir -p ~/Library/Caches/typst/packages/preview/cetz/0.3.4
#    Windows (PowerShell)
#    mkdir -Force "$env:LOCALAPPDATA\typst\packages\preview\cetz\0.3.4"

# 3. 解包到该目录（tar.gz 内直接是 src/、typst.toml 等文件）
tar -xzf cetz-0.3.4.tar.gz -C ~/.cache/typst/packages/preview/cetz/0.3.4   # Linux
tar -xzf cetz-0.3.4.tar.gz -C ~/Library/Caches/typst/packages/preview/cetz/0.3.4   # macOS
```

解包后目录应为：

```
<packages>/preview/cetz/0.3.4/
├── src/
├── typst.toml
└── LICENSE
```

#### 方式二：从 GitHub 源码仓库下载

```bash
curl -LO https://codeload.github.com/cetz-package/cetz/zip/refs/tags/v0.3.4
unzip v0.3.4            # 得到 cetz-0.3.4/
cp -R cetz-0.3.4/src cetz-0.3.4/typst.toml cetz-0.3.4/LICENSE \
      ~/Library/Caches/typst/packages/preview/cetz/0.3.4/    # macOS 路径按上表替换
```

#### 方式三：跟随上游最新版

`typst.toml` 里声明的 `compiler` 只是最低版本；CeTZ 上游仓库的 master 对应
0.5.x，与 Typst 0.15 兼容。若想改用更新版本，把文档中的 `0.3.4` 换成新版号，
并按方式一/二把对应版本放进缓存即可。

### 校验是否装好

```bash
typst compile 图/卷扬机收绳拉船.typ /tmp/fig.pdf   # 应无报错，/tmp/fig.pdf 非空
```

### 离线/受限网络的另一种办法：本地包目录

若不想动全局缓存，也可以把包放在仓库外的任意目录，编译时显式指定：

```bash
typst compile --package-path /path/to/packages 卷扬机收绳拉船.typ
```

只要该目录下是 `preview/cetz/0.3.4/...` 这一结构即可。本仓库**不再**内置该目录，
需要时请自行放置，或用上面的方式装进缓存。
