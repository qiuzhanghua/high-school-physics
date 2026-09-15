// ============================================================
// template.typ — 高中数学文档共享模板
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
//   #theorem[……]      #proof[……]
// ============================================================

// QED
#let qed = box(width: 100%, align(right)[$square$])

// ---- 环境：定义 ----
#let definition(body) = block(
  fill: rgb("#e8f4f8"),
  stroke: rgb("#2c3e50") + .5pt,
  inset: (x: 12pt, y: 8pt),
  radius: 4pt,
)[
  #strong[定义] #body
]

// ---- 环境：重点提示框 ----
#let important-block = block.with(
  fill: none,
  stroke: gray + .3pt,
  inset: 10pt,
  radius: 4pt,
)

// ---- 环境：示例 ----
#let example(body) = block(
  fill: rgb("#f8f9fa"),
  stroke: rgb("#6c757d") + .3pt,
  inset: (x: 12pt, y: 8pt),
  radius: 4pt,
)[
  #text(fill: rgb("#0d6efd"), weight: "bold")[示例] #body
]

// ---- 环境：定理 ----
#let theorem(body) = block(
  fill: rgb("#f0f4ff"),
  stroke: rgb("#2e4a7a") + 1.5pt,
  radius: 4pt,
  inset: 10pt,
  spacing: 10pt,
)[
  #text(weight: "bold", size: 1.1em, fill: rgb("#2e4a7a"))[定理] \
  #body
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

// ---- 文档模板 ----
#let template(
  body,
  heading2-align: center, // 二级标题对齐方式：left / center
  first-line-indent: none, // 首行缩进（none 表示不缩进）
  page-numbering: none, // 标准页码格式（none 表示不显示页码）
  page-footer: none, // 自定义右对齐页脚，如 "第 1 页"（设置后取代标准页码）
  equation-numbering: none, // 公式编号格式（none 表示不编号）
  reset-page: false, // 是否将页码重置为 1
  text-size: 12pt, // 正文字号
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

  // 字体：数学字体在前、中文字体殿后，保证公式用 Latin Modern Math
  // 或者 New Computer Modern Math
  // 中文用 Sarasa Gothic SC 回退。不要再执行 `#set text(font: ...)`
  // 之类的单字体覆盖，那会替换掉整个字体列表，导致中文失去 CJK 回退。
  // 使用操作系统的中文字体回退，似乎没有什么问题。
  // "Noto Sans SC", "Sarasa Gothic SC", "Source Han Serif"
  set text(
    font: ("New Computer Modern Math", "Source Han Serif"),
    size: text-size,
  )

  set math.equation(numbering: equation-numbering)

  show heading.where(level: 1): it => {
    set text(24pt, weight: "bold")
    align(center)[#it]
  }

  show heading.where(level: 2): it => {
    set text(20pt, weight: "bold")
    align(heading2-align)[#it]
  }

  body
}
