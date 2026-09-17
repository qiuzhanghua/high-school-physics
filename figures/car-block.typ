// 收绳拉物体（汽车水平拉绳，绳跨过定滑轮拉物体 M）—— 模型示意图
//
// 主文档以 `#import` 引入并放在 `#figure` 中；
// 单独编译本文件时会自带一个 `#figure`，便于预览。
//
// 依赖：CeTZ 0.5.2（Typst 官方包仓库预览包 @preview/cetz:0.5.2，
// 其自身依赖 @preview/oxifmt:1.0.0）。
// 首次编译时 Typst 自动下载并缓存，之后可离线编译。
//
// 图中约定（按教材原图）：
//   汽车在左侧水平面上，以速率 v 水平向左运动（远离滑轮）；
//   定滑轮固定在右上方（比汽车高），绳从车尾斜向上跨过滑轮，再竖直向下悬挂物体 M；
//   theta 是绳与水平方向的夹角（锐角），顶点在绳与汽车的连接处；
//   汽车向左运动时 x 增大，theta 越来越小（x -> oo 时 theta -> 0）。

#import "@preview/cetz:0.5.2": canvas, draw, vector, angle as cetz-angle

// 单独编译时置 true，自带图注；被主文档 `#import` 时置 false。
#let with-preview = true

#let car-block-figure() = canvas(length: 1cm, {
  import draw: *

  // ---- 配色 ----
  let c-sky = rgb("#f4f9fd")
  let c-ground = rgb("#eee6d8")
  let c-ground-line = rgb("#8a6f4a")
  let c-stroke = rgb("#1d3557")
  let c-aux = rgb("#c1121f")
  let c-rope = rgb("#7a4a25")
  let c-car = rgb("#2b5d8b")
  let c-block = rgb("#5c6b7a")
  let c-hatch = rgb("#b9a98f")

  // ---- 关键点 ----
  let hook = (-1.3, 0.3) // 绳与汽车的连接点（车尾）
  let P = (2.0, 2.6) // 定滑轮中心（右上方，比汽车高）
  let bw = 0.6 // 物体 M 的边长
  let M-x = P.at(0) - bw / 2 // M 上表面左端 x
  let M-y = -1.9 // M 上表面 y

  // ---- 背景、地面与平台 ----
  rect((-3.6, -2.7), (3.2, 3.15), fill: c-sky, stroke: none)
  // 地面（平台顶面，汽车行于其上）
  line((-3.6, 0), (-1.15, 0), stroke: (paint: c-ground-line, thickness: 1pt))
  // 平台：右侧竖直面 + 底面
  line((-1.15, 0), (-1.15, -1.2), (-3.6, -1.2), (-3.6, 0),
    fill: c-ground, stroke: none, close: true)
  line((-1.15, 0), (-1.15, -1.2), stroke: (paint: c-ground-line, thickness: 1pt))
  line((-3.6, -1.2), (-1.15, -1.2), stroke: (paint: c-ground-line, thickness: .8pt))
  // 平台侧面阴影线
  for i in range(0, 7) {
    line((-1.15 + 0.16 * i, -1.08), (-1.31 + 0.16 * i, -0.72),
      stroke: (paint: c-hatch, thickness: .5pt))
  }

  // ---- 滑轮挂架（固定在右上方的支架上）----
  line((2.0, 2.6), (2.0, 3.05), stroke: (paint: c-stroke, thickness: 1.3pt))
  line((1.4, 3.05), (2.8, 3.05), stroke: (paint: c-ground-line, thickness: 2.2pt))
  circle(P, radius: .3, fill: white, stroke: (paint: c-stroke, thickness: 1.4pt))
  circle(P, radius: .075, fill: c-stroke)

  // ---- 汽车（车尾在右侧，与绳相连）----
  line((-1.15, 0.3), (-1.15, 0.82), (-1.7, 0.82), (-2.1, 0.56),
    (-2.5, 0.56), (-2.5, 0.3), close: true,
    fill: c-car, stroke: (paint: c-stroke, thickness: .9pt))
  circle((-1.45, 0.3), radius: .14, fill: c-stroke)
  circle((-2.05, 0.3), radius: .14, fill: c-stroke)

  // ---- 绳：车尾 → 滑轮 → 物体 M ----
  line(hook, P, (P.at(0), M-y), stroke: (paint: c-rope, thickness: 1.5pt))
  // 物体 M
  line((M-x, M-y), (M-x, M-y - bw), (M-x + bw, M-y - bw), (M-x + bw, M-y),
    close: true, fill: c-block, stroke: (paint: c-stroke, thickness: .9pt))

  // ---- 汽车速度 v（水平向左，远离滑轮）----
  line((-2.2, 1.15), (-2.85, 1.15), stroke: (paint: c-car, thickness: 1.2pt),
    mark: (end: "stealth"), mark-size: .18, mark-fill: c-car, mark-stroke: none)
  content((-3.0, 1.15), text(fill: c-car, size: 9pt)[$v$], anchor: "east")

  // ---- 夹角 theta：绳与水平方向的夹角（锐角，顶点在车尾连接处）----
  // 水平参考线向右延伸，theta 即绳与水平面之间的那个小角
  line((hook.at(0), hook.at(1)), (hook.at(0) + 1.6, hook.at(1)),
    stroke: (paint: c-aux, thickness: .5pt, dash: "dashed"))
  cetz-angle.angle(
    hook, (hook.at(0) + 1.6, hook.at(1)), P,
    radius: 0.95,
    label: $theta$,
    direction: "ccw",
    label-radius: 72%,
    stroke: (paint: c-aux, thickness: .8pt),
  )

  // ---- 汽车速度沿绳方向的分量 v cos theta ----
  let 绳向 = vector.norm(vector.sub(P, hook))
  let 绳法 = (-绳向.at(1), 绳向.at(0))
  let p1 = vector.add(hook, vector.scale(绳向, 1.35))
  line(hook, p1, stroke: (paint: c-aux, thickness: .8pt, dash: "dashed"))
  content(vector.add(vector.add(p1, vector.scale(绳法, 0.3)), (-0.2, 0)),
    text(fill: c-aux, size: 8pt)[$v cos theta$],
    anchor: "east", angle: calc.atan2(绳向.at(0), 绳向.at(1)))

  // ---- 文字标注 ----
  content((-1.85, 1.0), text(fill: c-car, size: 9pt)[汽车], anchor: "north")
  content((M-x - 0.15, M-y - bw / 2), text(fill: c-block, size: 9pt)[$M$],
    anchor: "east")
})

// 单独编译本文件时，自带图注便于预览。
#if with-preview {
  figure(
    car-block-figure(),
    caption: [汽车在左侧、以速率 $v$ 向左运动（远离滑轮），通过定滑轮拉物体 $M$],
  )
}
