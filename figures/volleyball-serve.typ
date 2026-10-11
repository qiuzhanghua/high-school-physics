// 排球水平发球的最低高度 —— 模型示意图
//
// 主文档以 `#import` 引入并放在 `#figure` 中；
// 单独编译本文件时会自带一个 `#figure`，便于预览。
//
// 依赖：CeTZ 0.5.2（Typst 官方包仓库预览包 @preview/cetz:0.5.2，
// 其自身依赖 @preview/oxifmt:1.0.0）。
// 首次编译时 Typst 自动下载并缓存，之后可离线编译。
//
// 图中约定（按题目取 g = 10 "m/s"^2）：
//   排球场半场长 l = 9 "m"，球网高 h = 2.25 "m"；
//   运动员在自己端线处把球沿水平方向击出（竖直初速度为 0）；
//   临界情形：球恰好擦网而过，并且恰好落在对方端线上，
//   此时发球高度最低：
//     H = 4h/3 = 3.0 "m"， v = sqrt(3 g l^2 slash (2h)) ≈ 23.2 "m/s"

#import "@preview/cetz:0.5.2": canvas, draw

// 单独编译时置 true，自带图注；被主文档 `#import` 时置 false。
#let with-preview = true

#let volleyball-serve-figure() = canvas(length: 1cm, {
  import draw: *

  // ---- 配色 ----
  let c-sky = rgb("#f4f9fd")
  let c-court = rgb("#eaf3e6") // 界内地面
  let c-out = rgb("#eeeeea") // 界外地面
  let c-line = rgb("#4f7a3a")
  let c-net = rgb("#8fa3b4")
  let c-stroke = rgb("#1d3557")
  let c-aux = rgb("#c1121f")
  let c-ball = rgb("#e08a1e")
  let c-body = rgb("#2b5d8b")

  // ---- 物理参数（题目给定，g 取 10）----
  let l = 9.0 // 半场长
  let h = 2.25 // 网高
  let g = 10.0
  let H = 4.0 / 3.0 * h // 最低发球高度 = 3.0
  let v = calc.sqrt(3 * g * l * l / (2 * h)) // ≈ 23.24
  let t1 = calc.sqrt(2 * (H - h) / g) // 球落到网高所用时间
  let t2 = calc.sqrt(2 * H / g) // 球落地所用时间

  // ---- 坐标变换：世界坐标 (m) → 画布坐标 (cm) ----
  // 竖直方向适当放大（约 2.3 倍），使平抛轨迹的弯曲看得清；
  // 横向总跨度控制在 A4 正文宽度以内（否则会被页面截断）。
  let sx = 0.66
  let sy = 1.5
  let w2c(p) = (p.at(0) * sx, p.at(1) * sy)

  // ---- 背景：天空 + 界内/界外地面 ----
  let xMin = -2.3
  let xMax = 2 * l + 1.3
  let yBot = -0.62
  let yTop = H + 1.35
  rect(w2c((xMin, yBot)), w2c((xMax, yTop)), fill: c-sky, stroke: none)
  rect(w2c((xMin, yBot)), w2c((0, 0)), fill: c-out, stroke: none)
  rect(w2c((0, yBot)), w2c((2 * l, 0)), fill: c-court, stroke: none)
  rect(w2c((2 * l, yBot)), w2c((xMax, 0)), fill: c-out, stroke: none)
  line(w2c((xMin, 0)), w2c((xMax, 0)), stroke: (paint: c-line, thickness: 1.1pt))

  // 端线（自己 x = 0、对方 x = 2l）：地面上的短竖线 + 文字
  for xb in (0, 2 * l) {
    line(w2c((xb, -0.08)), w2c((xb, 0.12)), stroke: (paint: c-line, thickness: 2.4pt))
    content((w2c((xb, 0)).at(0), w2c((0, -0.36)).at(1)),
      text(fill: c-line, size: 8pt)[端线])
  }

  // ---- 球网：网面（有宽度）+ 网顶白带 ----
  let netW = 0.24
  let nb = w2c((l, 0))
  let nt = w2c((l, h))
  rect((nb.at(0) - netW / 2, nb.at(1)), (nt.at(0) + netW / 2, nt.at(1)),
    fill: c-net, stroke: (paint: c-stroke, thickness: .8pt))
  line((nb.at(0) - netW / 2 - 0.08, nt.at(1)), (nt.at(0) + netW / 2 + 0.08, nt.at(1)),
    stroke: (paint: white, thickness: 2.2pt))

  // ---- 运动员（简笔）----
  let person(x, label) = {
    let root = w2c((x, 0))
    line(root, (root.at(0), root.at(1) + 0.62), stroke: (paint: c-body, thickness: 1.4pt))
    line(root, (root.at(0) - 0.16, root.at(1) - 0.36), stroke: (paint: c-body, thickness: 1.1pt))
    line(root, (root.at(0) + 0.16, root.at(1) - 0.36), stroke: (paint: c-body, thickness: 1.1pt))
    line((root.at(0) - 0.18, root.at(1) + 0.5), (root.at(0) + 0.18, root.at(1) + 0.5),
      stroke: (paint: c-body, thickness: 1.1pt))
    circle((root.at(0), root.at(1) + 0.78), radius: .17,
      fill: c-body, stroke: (paint: c-stroke, thickness: .6pt))
    content((root.at(0), root.at(1) + 1.1), text(fill: c-body, size: 8pt)[#label])
  }
  person(-1.5, [发球者])
  person(2 * l - 3.4, [接球者])

  // ---- 发球点与水平初速度 v ----
  let serveC = w2c((0, H))
  circle(serveC, radius: .1, fill: c-ball, stroke: (paint: c-stroke, thickness: .6pt))
  line(serveC, (serveC.at(0) + 1.5, serveC.at(1)),
    stroke: (paint: c-ball, thickness: 1.3pt),
    mark: (end: "stealth"), mark-size: .2, mark-fill: c-ball, mark-stroke: none)
  content((serveC.at(0) + 0.75, serveC.at(1) + 0.26), text(fill: c-ball, size: 9pt)[$v$])

  // ---- 球的轨迹：x = v t, y = H - (g/2) t^2（t 从 0 到落地）----
  let pts = range(0, 61).map(i => {
    let t = t2 * i / 60
    w2c((v * t, H - g * t * t / 2))
  })
  line(..pts, stroke: (paint: c-ball, thickness: 1.5pt))

  // ---- 两个临界点 ----
  let atNet = w2c((l, h))
  circle(atNet, radius: .09, fill: c-ball, stroke: (paint: c-stroke, thickness: .6pt))
  content((atNet.at(0) + 0.16, atNet.at(1) + 0.44), text(fill: c-aux, size: 8.5pt)[恰好擦网], anchor: "west")
  let atEnd = w2c((2 * l, 0))
  circle(atEnd, radius: .09, fill: c-ball, stroke: (paint: c-stroke, thickness: .6pt))
  content((atEnd.at(0), atEnd.at(1) + 0.34), text(fill: c-aux, size: 8.5pt)[恰好压底线])

  // ---- 水平参考虚线 ----
  // 发球高度参考（到网所在竖直面）
  line((serveC.at(0), serveC.at(1)), (atNet.at(0), serveC.at(1)),
    stroke: (paint: c-aux, thickness: .5pt, dash: "dashed"))
  // 网高水平参考（从网到对方端线），球过网后即降到此线以下
  line((atNet.at(0), atNet.at(1)), (atEnd.at(0), atNet.at(1)),
    stroke: (paint: c-aux, thickness: .5pt, dash: "dashed"))

  // ---- 竖直尺寸线 ----
  let dimY(xw, y0, y1, label, dx) = {
    let a = w2c((xw, y0))
    let b = w2c((xw, y1))
    let a2 = (a.at(0) + dx, a.at(1))
    let b2 = (b.at(0) + dx, b.at(1))
    line(a, a2, stroke: (paint: c-aux, thickness: .4pt))
    line(b, b2, stroke: (paint: c-aux, thickness: .4pt))
    line(a2, b2, stroke: (paint: c-aux, thickness: .8pt),
      mark: (start: "stealth", end: "stealth"), mark-size: .16,
      mark-fill: c-aux, mark-stroke: none)
    content((a2.at(0) + (if dx > 0 { 0.1 } else { -0.1 }), (a2.at(1) + b2.at(1)) / 2),
      text(fill: c-aux, size: 8.5pt)[#label],
      anchor: if dx > 0 { "west" } else { "east" })
  }
  // 发球高度 H：在发球点左侧
  dimY(0, 0, H, $H$, -0.55)
  // 网高 h：在网右侧
  dimY(l, 0, h, $h$, 0.55)
  // 从发球高度到网顶的落差 H - h：在网左侧（紧靠网）
  dimY(l, h, H, $H - h$, -0.5)

  // ---- 半场长 l：两段水平尺寸线（网恰在中点）----
  let dimX(x0, x1, label, dy, label-dy) = {
    let a = w2c((x0, 0))
    let b = w2c((x1, 0))
    let y = a.at(1) + dy
    line(a, (a.at(0), y), stroke: (paint: c-aux, thickness: .4pt))
    line(b, (b.at(0), y), stroke: (paint: c-aux, thickness: .4pt))
    line((a.at(0), y), (b.at(0), y), stroke: (paint: c-aux, thickness: .8pt),
      mark: (start: "stealth", end: "stealth"), mark-size: .16,
      mark-fill: c-aux, mark-stroke: none)
    content(((a.at(0) + b.at(0)) / 2, y + label-dy),
      text(fill: c-aux, size: 8.5pt)[#label])
  }
  dimX(0, l, $l$, -0.34, -0.16)
  dimX(l, 2 * l, $l$, -0.34, -0.16)
})

// 单独编译本文件时，自带图注便于预览。
#if with-preview {
  figure(
    volleyball-serve-figure(),
    caption: [排球水平发球：球恰好擦网而过，并恰好落在对方端线上，此时发球高度最低],
  )
}
