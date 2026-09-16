#import "template.typ": *
// 图由 图/卷扬机收绳拉船.typ 绘制，使用 CeTZ 0.3.4（Typst 官方包仓库的预览包）。
// 首次编译时 Typst 会自动下载该包并缓存到本地，之后离线可用；
// 若处于离线或受限网络环境，安装方法见 README.md。
#import "图/卷扬机收绳拉船.typ": 卷扬机收绳拉船图
#import "图/收绳拉物体.typ": 收绳拉物体图

#set document(title: [卷扬机收绳拉船])

#show: template.with(
  heading2-align: left, // 二级标题对齐方式：left / center
  first-line-indent: 2em, // 首行缩进（none 表示不缩进）
  page-numbering: "第 1 页", // 标准页码格式（none 表示不显示页码）
  equation-numbering: "(1)", // 公式编号格式（none 表示不编号）
  reset-page: true, // 是否将页码重置为 1
  text-size: 12pt, // 正文字号
)

= 卷扬机收绳拉船

== 模型描述

- 岸上（或拖船上）有一个卷扬机，以恒定速率 $u$ 收绳。
- 绳绕过滑轮，拉着水面上的船。
- 绳与水平方向（或船的运动方向）成 $theta$ 角。
- 船沿水平方向运动，速度为 $v$。

#figure(
  卷扬机收绳拉船图(),
  caption: [卷扬机收绳拉船模型：滑轮高 $h$，船到滑轮水平距离 $x$，绳与水平方向夹角 $theta$，收绳速率 $u$，船速 $v$],
)

== 关键分析

设滑轮高度为 $h$，船到滑轮水平距离为 $x$，绳长 $L$ 满足：

$ L^2 = x^2 + h^2 $

对时间求导：

$ 2 L (dif L)/(dif t) = 2 x (dif x)/(dif t) $

即：

$ L (dif L)/(dif t) = x v $

其中 $v = (dif x)/(dif t)$ 是船的水平速度。因为绳在缩短，$ (dif L)/(dif t) = -u $（$u$ 为收绳速率），所以：

$ L (-u) = x v $

$ v = - (L u)/x $

负号表示船在向滑轮靠近（$x$ 减小）。取大小：

$ v = (L u)/x $

又因为 $ cos theta = x/L $
所以：

$ v = u / cos theta $

== 结论

#rect(stroke: 0.5pt, inset: 6pt, $ v = u / cos theta $)

其中：

- $v$：船的水平速度
- $u$：收绳速率（绳长缩短的速率）
- $theta$：绳与船运动方向（水平方向）的夹角

*注意*：这里 $v > u$，因为船的水平速度比收绳速率大。当 $theta -> 0$ 时，$v -> u$；当 $theta -> 90 degree$ 时，$v -> oo$（实际上船会飞起来，物理上不现实，但公式说明角度越大，船速越快）。

== 如果船不是沿水平方向运动

如果船的运动方向与绳成 $theta$ 角，而不是与水平方向成 $theta$，则一般关系为：

设船速为 $v$，绳与船速方向的夹角为 $theta$，收绳速率为 $u$。

则船沿绳方向的速度分量为：

$ v_("沿绳,船") = v cos theta $

绳长变化率：

$ (dif L)/(dif t) = -u $

而绳长变化率等于“滑轮端沿绳速度”减去“船端沿绳速度”。如果滑轮端固定（不动），则：

$ (dif L)/(dif t) = - v_("沿绳,船") = - v cos theta $

所以：

$ - v cos theta = -u $

#rect(stroke: 0.5pt, inset: 6pt, $ v = u / cos theta $)

*这个公式是通用的*：只要滑轮端固定，船沿绳方向的分量就是 $v cos theta$，它等于收绳速率 $u$。

== 如果滑轮端也在运动

如果拖船（滑轮端）也在运动，速度为 $v_1$，船速度为 $v_2$，绳与拖船速度方向夹角为 $alpha$，与船速度方向夹角为 $beta$，收绳速率为 $u$，则：

$ v_1 cos alpha - v_2 cos beta = u $

（假设拖船沿绳方向的分量大于船沿绳方向的分量，绳在缩短）

或者：

$ v_2 cos beta = v_1 cos alpha - u $

== 典型例题

*题目*：岸上卷扬机以 $u = 2 upright("m/s")$ 收绳，绳绕过定滑轮拉船。当绳与水平方向夹角 $theta = 60 degree$ 时，求船的速度。

*解*：

$ v = u / cos theta = 2 / cos 60 degree = 2 / 0.5 = 4 upright("m/s") $

船的速度为 $4 upright("m/s")$，方向水平向岸。

== 易错点

1. *误用 $v = u cos theta$*
  这是最常见的错误。正确的是 $v = u / cos theta$，因为收绳速率是船速沿绳方向的分量，而不是反过来。

2. *忘记绳长变化*
  如果题目说“绳长不变”，则用 $v_1 cos theta_1 = v_2 cos theta_2$；如果说“收绳”“绳缩短”，则用 $v = u / cos theta$。

3. *角度找错*
  $theta$ 是绳与*船运动方向*的夹角，不是绳与水平方向的夹角（除非船沿水平运动）。

4. *符号问题*
  收绳速率 $u$ 取正值，表示绳在缩短；如果绳在伸长，则 $u$ 取负值，或公式中改为 $v = -u / cos theta$。

== 总结

#table(
  columns: 2,
  [*情况*], [*公式*],
  [绳长不变，两端沿绳分量相等], [$v_1 cos theta_1 = v_2 cos theta_2$],
  [滑轮固定，收绳速率 $u$，绳与船速夹角 $theta$], [$v = u / cos theta$],
  [滑轮运动，收绳速率 $u$], [$v_1 cos alpha - v_2 cos beta = u$],
)

== 练 7：绳关联速度的分解（汽车拉物体）

#figure(
  收绳拉物体图(),
  caption: [汽车在左侧、以速率 $v$ 向左运动（远离滑轮），通过定滑轮拉物体 $M$],
)

*题目*：如图所示，在不计滑轮摩擦和绳子质量的条件下，当汽车匀速向左运动时，物体 $M$ 的受力和运动情况是（　　）

+ 绳的拉力等于 $M$ 的重力
+ 绳的拉力大于 $M$ 的重力
+ 物体 $M$ 向上做匀速运动
+ 物体 $M$ 向上做匀加速运动

*解法一（速度分解）*：

绳不可伸长，所以“绳被拉入滑轮的速率”等于“$M$ 上升的速率”。设汽车速度为 $v$，绳与水平方向的夹角为 $theta$。把汽车速度沿绳方向与垂直绳方向分解，*沿绳方向的分量*就是绳被拉动的速率，也就是 $M$ 上升的速率：

$ v_M = v cos theta $

再看 $theta$ 怎样变化：汽车在滑轮左侧、匀速*向左远离*滑轮，水平距离 $x$ 不断增大，而 $tan theta = h/x$（$h$ 为滑轮相对汽车的竖直高度，不变），所以 $theta$ 不断*减小*。极限情形下一看便知：汽车移到无穷远处时绳子几乎水平，$theta -> 0$。

于是 $cos theta$ 不断增大（$theta -> 0$ 时 $cos theta -> 1$），$v_M$ 越来越大。

$arrow.r.double$ 物体 $M$ 向上运动，且速度不断增大，即向上做*加速运动*，*加速度方向向上*。

*解法二（绳长约束求导）*：

设车尾到滑轮的水平距离为 $x$，绳长为 $s$，滑轮比车高 $h$。由勾股定理

$ s^2 = x^2 + h^2 $

其中 $h$ 是定值。两边对时间 $t$ 求导（$x$、$s$ 都是 $t$ 的函数）：

$ 2 s (dif s)/(dif t) = 2 x (dif x)/(dif t) quad ==> quad s (dif s)/(dif t) = x (dif x)/(dif t) $

由题意，水平距离的变化率就是车速（汽车匀速向左）：

$ (dif x)/(dif t) = v $

又因为绳不可伸长，绳的伸长速率就是 $M$ 上升的速率：

$ (dif s)/(dif t) = v_M $

代入 $s (dif s)/(dif t) = x (dif x)/(dif t)$，得

$ s v_M = x v quad ==> quad v_M = x/s v $

由几何关系 $cos theta = x/s$，即得与解法一相同的结果：

$ v_M = v cos theta $

再看 $v_M$ 怎样随时间变化。把 $v_M = (x/s) v$ 中的 $x/s$ 写成 $x$ 的函数：

$ x/s = x/sqrt(x^2 + h^2) = 1/sqrt(1 + h^2/x^2) $

汽车远离滑轮时 $x$ 不断增大，$h^2 slash x^2$ 减小，故 $x slash s$ *单调增大*（也可直接求导：$dif/(dif x)(x/s) = h^2 slash s^3 > 0$，因为 $h > 0$）。所以 $v_M = (x/s) v$ 随 $x$ 增大而*增大*：$M$ 向上做*加速运动*，加速度方向向上。

*解法二的意义*：它把“绳不可伸长”写成约束方程 $s^2 = x^2 + h^2$，对时间求导一次就同时给出了速度关系和“$v_M$ 如何变化”，不必再单独讨论 $theta$。

*解法三（取微元，小量近似）*：

仍设车尾到滑轮的水平距离为 $x$、绳长为 $s$、滑轮比车高 $h$，则 $x^2 = s^2 - h^2$。

取一段很短的时间 $Delta t$，设这段时间内物体 $M$ 上升 $Delta h$。绳不可伸长，所以绳长由 $s$ 变为 $s + Delta h$，相应地汽车到滑轮的水平距离由 $x$ 变为 $x + Delta x$：

$ (x + Delta x)^2 = (s + Delta h)^2 - h^2 $

展开并利用 $x^2 = s^2 - h^2$：

$ x^2 + 2 x Delta x + (Delta x)^2 = s^2 + 2 s Delta h + (Delta h)^2 - h^2 $

$ 2 x Delta x + (Delta x)^2 = 2 s Delta h + (Delta h)^2 $

因为 $Delta t$ 取得极短，$Delta x$、$Delta h$ 都是小量，它们的平方项是*高阶小量*，可以略去，于是

$ 2 x Delta x approx 2 s Delta h quad ==> quad Delta x = s/x Delta h $

而 $Delta x$、$Delta h$ 是*同一段时间* $Delta t$ 内汽车和 $M$ 的位移，所以 $Delta x slash Delta t = v$、$Delta h slash Delta t = v_M$，两边同除以 $Delta t$：

$ v = s/x v_M quad ==> quad v_M = x/s v $

再由 $cos theta = x/s$，同样得到

$ v_M = v cos theta $

而且从 $Delta x = (s/x) Delta h$ 还能直接看出变化的趋势：汽车越走越远，$x$ 增大、$x/s$ 减小，于是*同样的 $Delta h$ 需要更大的 $Delta x$*（也可读作：$M$ 每上升相同的 $Delta h$，汽车要走的 $Delta x$ 越来越大）。也就是说，汽车以不变的 $v$ 前进时，$M$ 上升得越来越慢——等价地，$v_M = (x/s) v$ 随 $x$ 增大而增大，$M$ 向上做*加速运动*，加速度方向向上。

对 $M$ 用牛顿第二定律（取向上为正），向上的绳拉力 $T$ 与向下的重力 $m g$ 满足：

$ T - m g = m a > 0 quad ==> quad T > m g $

即绳的拉力*大于* $M$ 的重力。

#rect(stroke: 0.5pt, inset: 6pt, [答案：选 *B*（绳的拉力大于 $M$ 的重力）])

*说明*：

- 判断的核心是*角度怎么变*：汽车向左远离滑轮，绳越拉越平，$theta$ 越来越小，所以绳被拉动的速率 $v cos theta$ 越来越大，$M$ 向上加速。
- “拉力与重力谁大”只取决于*加速度方向*：向上加速则 $T > m g$，向上减速则 $T < m g$，匀速则 $T = m g$。
- 选项 A、C、D 都被排除：A 只在 $M$ 匀速时成立；$v_M = v cos theta$ 不是恒量，故 C、D 都不对（$v_M$ 在增大，但增大的快慢在变，加速度不是恒量）。

*易错点*：

1. *把分解对象搞反*，写成 $v_M = v / (cos theta)$，得出 $v_M > v$ 的荒谬结果。判断依据：$M$ 的速度是*汽车速度沿绳方向的分量*，所以带 $cos theta$，且一定不大于 $v$。
2. *凭直觉以为“绳子越拉越斜、$theta$ 变大”*。其实汽车在滑轮另一侧、越走越远，$tan theta = h/x$ 随 $x$ 增大而减小，$theta$ 是*变小*的（极端情况绳子接近水平，$theta -> 0$）。
3. *只比较速度大小、不看加速度*，就断定 $T = m g$（选 A）。$v_M$ 增大说明 $M$ 有向上的加速度，绳的拉力必大于重力。
4. *把 $theta$ 认成绳与竖直方向的夹角*。若误取余角，$cos theta$ 的变化方向会反过来，结论就全错了。本题 $theta$ 是绳与*水平方向*的夹角。
