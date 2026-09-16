// 卷扬机收绳拉船 —— 模型示意图
//
// 主文档以 `#include` 引入，并由 `#figure` 包裹、统一加图注；
// 单独编译本文件时会自带一个 `#figure`，便于预览。
//
// 依赖：CeTZ 0.3.4（Typst 官方包仓库预览包 @preview/cetz:0.3.4）。
// 首次编译时 Typst 自动下载并缓存，之后可离线编译。
//
// 图中约定：
//   水面为 y = 0；滑轮在 P(0, 2.2)，即水面之上 h = 2.2 的岸顶，与岸顶等高；
//   B 是 P 正下方水面上的点，用作 h 与 x 两条尺寸线的基准；
//   船到滑轮的水平距离为 x；theta 是绳与水平方向的夹角，顶点画在船头，
//   与正文题注「绳与水平方向夹角 theta」一致；
//   收绳速率 u 沿绳指向滑轮，船速 v 沿水平方向指向滑轮。

#import "@preview/cetz:0.3.4": canvas, draw, vector, angle as cetz-angle

// 单独编译时置 true，自带图注；被主文档 `#include` 时置 false，
// 由主文档的 `#figure` 统一加图注。
#let with-preview = true

#let 卷扬机收绳拉船图() = canvas(length: 1cm, {
  import draw: *

  // ---- 配色 ----
  let c-sky = rgb("#f4f9fd")
  let c-water = rgb("#d7ebfa")
  let c-water-line = rgb("#2477b2")
  let c-land = rgb("#f3e9d9")
  let c-land-line = rgb("#8a6f4a")
  let c-stroke = rgb("#1d3557")
  let c-aux = rgb("#c1121f") // 辅助线 / 尺寸标注
  let c-rope = rgb("#7a4a25")
  let c-boat = rgb("#2b5d8b")
  let c-drum = rgb("#5c6b7a")

  // ---- 关键点 ----
  let P = (0, 2.2) // 滑轮中心（岸顶，水面之上 h = 2.2）
  let B = (0, 0) // 滑轮正下方水面上的点：h 与 x 的尺寸基准
  let winch = (-3.2, 2.56) // 卷扬机（绞盘）中心，坐在岸顶 y = 2.2 上
  let bow = (6.9, 0.32) // 船头系绳点
  let deck-stern = (8.3, -0.25) // 船尾甲板点
  let deck-bow = bow // 船头甲板点

  // ---- 背景 ----
  rect((-5.8, -2.6), (8.6, 3.9), fill: c-sky, stroke: none)
  // 水（水面在 y = 0）
  rect((-5.8, -2.2), (8.6, 0), fill: c-water, stroke: none)
  line((-5.8, 0), (8.6, 0), stroke: (paint: c-water-line, thickness: 1pt))
  // 岸：岸壁与岸顶平台（岸顶 y = 2.2，与滑轮等高）
  line((0, 0), (-5.8, 0), (-5.8, 2.2), (0, 2.2),
    fill: c-land, stroke: none, close: true)
  line((-5.8, 2.2), (0, 2.2), stroke: (paint: c-land-line, thickness: 1pt))
  line((0, 0), (-5.8, 0), stroke: (paint: c-land-line, thickness: 1pt))

  // ---- 岸壁立柱与滑轮 ----
  // 立柱只从水面（y = 0）立到滑轮（y = 2.2），不再伸到水面以下
  line((0, 0), (0, 2.2), stroke: (paint: c-stroke, thickness: 1.6pt))
  circle(P, radius: .3, fill: white, stroke: (paint: c-stroke, thickness: 1.4pt))
  circle(P, radius: .075, fill: c-stroke)

  // ---- 卷扬机（绞盘 + 摇柄）----
  rect(
    (winch.at(0) - .36, winch.at(1) - .36),
    (winch.at(0) + .36, winch.at(1) + .36),
    fill: c-drum,
    stroke: (paint: c-stroke, thickness: 1pt),
    radius: .07,
  )
  line(winch, (-3.6, 3.26), stroke: (paint: c-stroke, thickness: 1.4pt))
  line((-3.6, 3.26), (-3.85, 3.16), stroke: (paint: c-stroke, thickness: 1.4pt))

  // ---- 船体 ----
  // 船身所在水域：水线约 y = -1.05，船底曲线最低点 ≈ -1.05（船浮在水上）
  // 三次贝塞尔采样成折线：CeTZ 的曲线段在填充闭合时有兼容问题，故手动采样
  let 三次点(a, b, c1, c2, t) = {
    let u = 1 - t
    let (w0, w1, w2, w3) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
    (
      w0 * a.at(0) + w1 * c1.at(0) + w2 * c2.at(0) + w3 * b.at(0),
      w0 * a.at(1) + w1 * c1.at(1) + w2 * c2.at(1) + w3 * b.at(1),
    )
  }
  let 船底点 = range(0, 25).map(i => 三次点(deck-bow, deck-stern, (7.6, -1.1), (8.45, -0.5), i / 24))
  line(..船底点, deck-bow, fill: c-boat, stroke: none, close: true)
  // 船舷
  line(deck-stern, deck-bow, stroke: (paint: c-boat, thickness: 1.4pt))
  // 桅杆与旗
  line((7.45, -0.18), (7.45, 1.2), stroke: (paint: c-stroke, thickness: 1pt))
  line((7.45, 1.2), (8.15, 1.0), (7.45, 0.8), fill: rgb("#e63946"), stroke: none, close: true)

  // ---- 绳：卷扬机 → 滑轮 → 船头 ----
  line(winch, P, bow, stroke: (paint: c-rope, thickness: 1.6pt))

  // ---- 夹角 theta：绳与水平方向的夹角（顶点在船头，与正文一致）----
  // 水平参考线自船头向左（指向滑轮）延伸，theta 就是它与绳之间的锐角
  line((bow.at(0), bow.at(1)), (bow.at(0) - 2.2, bow.at(1)),
    stroke: (paint: c-aux, thickness: .5pt, dash: "dashed"))
  cetz-angle.angle(
    bow, P, (bow.at(0) - 2.2, bow.at(1)),
    radius: 1.15,
    label: $theta$,
    direction: "ccw",
    label-radius: 72%,
    stroke: (paint: c-aux, thickness: .8pt),
  )

  // ---- 尺寸标注辅助函数 ----
  // 在 a、b 之间画带双箭头的尺寸线，法向偏移 off；文字可附加旋转
  let 尺寸线(a, b, 文字, off, 旋转: 0deg) = {
    let d = vector.sub((b.at(0), b.at(1)), (a.at(0), a.at(1)))
    let n = vector.norm((-d.at(1), d.at(0))) // 单位法向量
    let p1 = vector.add((a.at(0), a.at(1)), vector.scale(n, off))
    let p2 = vector.add((b.at(0), b.at(1)), vector.scale(n, off))
    line(a, p1, stroke: (paint: c-aux, thickness: .5pt))
    line(b, p2, stroke: (paint: c-aux, thickness: .5pt))
    line(p1, p2,
      stroke: (paint: c-aux, thickness: .8pt),
      mark: (start: "stealth", end: "stealth"),
      mark-size: .16, mark-fill: c-aux, mark-stroke: none)
    let mid = vector.scale(vector.add(p1, p2), .5)
    content(mid, text(fill: c-aux, size: 9pt)[#文字],
      angle: 旋转, frame: "rect", padding: .06, fill: c-sky, stroke: none)
  }

  // h：水面（B）→ 滑轮（尺寸线在立柱右侧，文字竖排）
  尺寸线(B, P, $h$, -0.4, 旋转: 90deg)
  // x：滑轮正下方水面点 → 船头（负偏移，尺寸线放在水线以下）
  尺寸线(B, (bow.at(0), B.at(1)), $x$, -0.75)

  // ---- 文字标注 ----
  content((-3.15, 3.5), text(fill: c-stroke, size: 9pt)[卷扬机])
  content((7.75, 1.65), text(fill: c-boat, size: 9pt)[船])
  content((-5.55, 1.85), text(fill: c-land-line, size: 9pt)[岸])
  // 收绳速率 u：贴在绳的上方，随绳倾斜。
  // Typst 的 calc.atan2(a, b) 等价于标准 atan2(y: b, x: a)，且返回角度；
  // 绳自卷扬机到滑轮向右下走，故取 (水平跨度, 落差) 得顺时针的小角度。
  let 绳角 = calc.atan2(P.at(0) - winch.at(0), winch.at(1) - P.at(1))
  content((-1.45, 2.62), text(fill: c-rope, size: 9pt)[收绳速率 $u$], angle: 绳角)
  // 船速 v：船头下方指向滑轮的箭头 + 文字
  line((6.85, -1.62), (5.65, -1.62), stroke: (paint: c-boat, thickness: 1pt),
    mark: (end: "stealth"), mark-size: .16, mark-fill: c-boat, mark-stroke: none)
  content((5.35, -1.62), text(fill: c-boat, size: 9pt)[$v$])
})

// 单独编译本文件时，自带图注便于预览。
#if with-preview {
  figure(
    卷扬机收绳拉船图(),
    caption: [卷扬机以速率 $u$ 收绳，绳绕过定滑轮拉动水面的船],
  )
}
