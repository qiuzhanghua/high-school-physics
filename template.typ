// ============================================================
// template.typ — 自动生成，请勿手工修改
// 源：typst-notes@v1.0.0（lib.typ）
// 重新生成：./sync-template.sh（Windows 用 ./sync-template.ps1）
// 本仓公式编号默认值：none
// ============================================================

// ============================================================
// lib.typ — 数理讲义共享模板（单一源；由各仓根目录的 sync-template.sh 分发为 template.typ）
//
// 用法：
//   #import "template.typ": *
//   #set document(title: [Quadratic Equation])  // 可选：设置后页眉右侧显示标题
//
//   #template(
//     heading2-align: left,                 // 二级标题对齐方式：left / center
//     first-line-indent: 2em,               // 首行缩进量（none 表示不缩进）
//     page-numbering: "第 1 页",             // 标准页码格式（none 表示不显示）
//     page-footer: "第 1 页",               // 自定义右对齐页脚（会取代标准页码）
//     equation-numbering: "(1)",            // 公式编号格式（none 表示不编号）
//     reset-page: true,                     // 是否将页码重置为 1
//     text-size: 12pt,                      // 正文字号
//   )[
//     ……正文……
//   ]
//
// 模板内置可直接使用的环境：
//   #definition[……]  #important-block[……]  #example[……]
//   #theorem[……]      #proof[……]           #remark[……]
//   #remark 可带小标题：#remark(title: "级数展开视角")[……]
//
// 填空横线：#blank()；长度可选，如 #blank(1) / #blank(2) / #blank(5)（单位为 em），
//   也可直接给长度 #blank(5em)。（不要用 #underline[#h(3em)]，它不显示横线。）
//
// 自动编号与引用：
//   #definition、#theorem、#remark、#example 都会自动编号
//   （定义 1…、定理 1…、注 1…、示例 1…，四者各自独立计数、整篇连续）。
//   在环境后面紧接一个标签即可引用，例如
//     #definition[……] <def:mean>
//     #theorem[……] <thm:mean>
//     #example[……] <ex:one>
//     由 @def:mean 与 @thm:mean 可知……   // 自动显示为"定义 1""定理 1"
//     #remark(title: "…")[……] <rem:series>
//     见 @rem:series……
//
// 环境的选择：
//   定义/定理 —— 有明确的、待定义或待证明的命题；
//   证明     —— 定理（或例题结论）的论证过程，自动加「证明」与结尾 □；
//   示例     —— 具体的例题、练习；
//   注       —— 补充说明、另一视角、拓展阅读，本身不提新命题，用 #remark。
//
// 数学模式内的中文要用 #cjk[……] 显式指定正文字体，例如 $x_(#cjk[极值点])$，
// 否则中文会掉到系统默认黑体（数学模式不继承正文的字体列表）。
// ============================================================

// QED
#let qed = box(width: 100%, align(right)[$square$])

// ---- 字体 ----
// 正文字体列表：数学字体在前、中文字体殿后。不要在文档里再做
// `#set text(font: ...)` 之类的单字体覆盖，那会替换掉整个列表，
// 使中文失去 CJK 回退。
#let text-fonts = ("New Computer Modern Math", "Source Han Serif")
#let cjk-font = "Source Han Serif"

// ---- 数学模式内的中文 ----
// 数学模式不继承 text-fonts：$x_("极值点")$ 里的中文会落到系统默认黑体，
// 与正文宋体不一致。数学模式内写中文请用 #cjk[极值点]。
#let cjk(body) = text(font: cjk-font, body)

// ---- 填空横线 ----
// 用法：#blank()（默认长度 3）或 #blank(1)、#blank(2)、#blank(4)、#blank(5)…
//   参数是 em 倍数（无单位数字）；也可直接给长度 #blank(5em)。
// 横线前后自带空隙，不会与相邻文字贴住。
// 注意：正文里不要写 #underline[#h(3em)]——Typst 不会给"空内容"画下划线，
// 那样不会显示任何横线（数式里写成 $underline(#h(3em))$ 才有效果）。
// （用 ..args 是因为 Typst 不允许把"带默认值的参数"按位置传入。）
#let blank(..args) = {
  let n = if args.pos().len() > 0 { args.pos().first() } else { args.named().at("n", default: 3) }
  let w = if type(n) == length { n } else { n * 1em }
  h(0.4em) + box(width: w, stroke: (bottom: 0.6pt)) + h(0.4em)
}

// ---- 环境：定义（自动编号，可在后面加标签供 @ 引用） ----
// 用法：#definition[……] <def:名字>   →  显示"定义 1"，@def:名字 引用为"定义 1"
#let definition(body) = figure(
  kind: "definition",
  supplement: [定义],
  numbering: "1",
  caption: none,
  gap: 0pt,
  placement: none,
)[
  #align(left)[
    #block(
      width: 100%,
      fill: rgb("#e8f4f8"),
      stroke: rgb("#2c3e50") + .5pt,
      radius: 4pt,
      inset: (x: 12pt, y: 8pt),
    )[
      #strong[定义 #context counter(figure.where(kind: "definition")).display()] #body
    ]
  ]
]

// ---- 环境：重点提示框 ----
#let important-block = block.with(
  fill: none,
  stroke: gray + .3pt,
  inset: 10pt,
  radius: 4pt,
)

// ---- 环境：示例（自动编号，可在后面加标签供 @ 引用） ----
// 用法：#example[……] <ex:名字>   →  显示"示例 1"，@ex:名字 引用为"示例 1"
#let example(body) = figure(
  kind: "example",
  supplement: [示例],
  numbering: "1",
  caption: none,
  gap: 0pt,
  placement: none,
)[
  #align(left)[
    #block(
      width: 100%,
      fill: rgb("#f8f9fa"),
      stroke: rgb("#6c757d") + .3pt,
      radius: 4pt,
      inset: (x: 12pt, y: 8pt),
    )[
      #text(fill: rgb("#0d6efd"), weight: "bold")[示例 #context counter(figure.where(kind: "example")).display()] #body
    ]
  ]
]

// ---- 环境：定理（自动编号，可在后面加标签供 @ 引用） ----
// 用法：#theorem[……] <thm:名字>   →  显示"定理 1"，@thm:名字 引用为"定理 1"
#let theorem(body) = figure(
  kind: "theorem",
  supplement: [定理],
  numbering: "1",
  caption: none,
  gap: 0pt,
  placement: none,
)[
  #align(left)[
    #block(
      width: 100%,
      fill: rgb("#f0f4ff"),
      stroke: rgb("#2e4a7a") + 1.5pt,
      radius: 4pt,
      inset: 10pt,
    )[
      #text(weight: "bold", size: 1.1em, fill: rgb("#2e4a7a"))[定理 #context counter(figure.where(kind: "theorem")).display()] \
      #body
    ]
  ]
]

// ---- 环境：证明 ----
#let proof(body) = block(
  inset: 10pt,
  spacing: 10pt,
)[
  #text(weight: "bold", style: "italic")[证明] \
  #body \
  #h(1fr) #text(weight: "bold")[□]
]

// ---- 环境：注（补充说明、另一视角、拓展阅读；自动编号） ----
// 用法：#remark[……]  或  #remark(title: "级数展开视角")[……]
//       #remark[……] <rem:名字>   →  显示"注 1"，@rem:名字 引用为"注 1"
#let remark(body, title: none) = figure(
  kind: "remark",
  supplement: [注],
  numbering: "1",
  caption: none,
  gap: 0pt,
  placement: none,
)[
  #align(left)[
    #block(
      width: 100%,
      fill: rgb("#fffdf2"),
      stroke: rgb("#b8860b") + .4pt,
      radius: 4pt,
      inset: (x: 12pt, y: 8pt),
    )[
      #text(weight: "bold", fill: rgb("#8a6d00"))[注 #context counter(figure.where(kind: "remark")).display()#(if title != none [（#title）])] #body
    ]
  ]
]

// ---- 文档模板 ----
#let template(
  body,
  heading2-align: center, // 二级标题对齐方式：left / center
  first-line-indent: none, // 首行缩进（none 表示不缩进）
  page-numbering: none, // 标准页码格式（none 表示不显示页码）
  page-footer: none, // 自定义右对齐页脚，如 "第 1 页"（设置后取代标准页码）
  equation-numbering: none, // 公式编号格式（none 表示不编号）；各仓取值见 .template.conf
  reset-page: false, // 是否将页码重置为 1
  text-size: 12pt, // 正文字号
  title-size: 24pt, // 一级标题（文档大标题）字号
  heading-size: 20pt, // 二级标题（一、二、三…）字号
) = {
  // 页眉：右侧显示文档标题。
  // 需在文档顶层执行 `#set document(title: [……])`，此处自动读取；
  // 未设置标题时页眉留空。
  let header-content = context {
    let t = document.title
    if t == none {
      none
    } else {
      align(right + horizon, t)
    }
  }

  // 页脚：右侧显示“第 1 页”式页码（基于页面计数器）
  let footer-content = if page-footer != none {
    align(right, context numbering(page-footer, here().page()))
  } else {
    none
  }

  set page(
    paper: "a4",
    header: header-content,
    // 注意：无自定义页脚时须用 auto（默认页脚），显式设 none 会连带禁用
    // `page-numbering` 的标准页码（页码默认就渲染在页脚区域）。
    footer: if page-footer == none { auto } else { footer-content },
    numbering: if page-footer != none { none } else { page-numbering },
  )

  if reset-page {
    counter(page).update(1)
  }

  set par(
    first-line-indent: if first-line-indent == none {
      0em
    } else {
      first-line-indent
    },
    spacing: 1em,
    leading: 1em,
  )

  // 字体列表见文件顶部的 text-fonts（数学字体在前、中文宋体殿后），
  // 不要在这里或文档里做单字体覆盖，否则中文会失去 CJK 回退。
  // 备选中文（作为 fallback 追加即可）："Noto Sans SC"、"Sarasa Gothic SC"。
  // lang: "zh" 让 Typst 采用中文排版规则，并把图注前缀本地化为“图 1”。
  set text(
    font: text-fonts,
    size: text-size,
    lang: "zh",
  )

  set math.equation(numbering: equation-numbering)

  show heading.where(level: 1): it => {
    set text(title-size, weight: "bold")
    align(center)[#it]
  }

  show heading.where(level: 2): it => {
    set text(heading-size, weight: "bold")
    align(heading2-align)[#it]
  }

  body
}

// ===== 题型框 / 思路框（供 导数破题思路.typ 等使用）=====
// 绿色题型框：用于放题目
#let problem-box(content) = block(
  fill: rgb("E8F5E9"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  stroke: (left: 4pt + rgb("2E7D32")),
  content,
)

// 黄色思路框：用于放破题思路
#let idea-box(content) = block(
  fill: rgb("FFFDE7"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  stroke: (left: 4pt + rgb("F9A825")),
  content,
)
