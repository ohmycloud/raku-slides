title:  reddit-Random Bag System

date: 2016-01-28

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>原来！</blockquote>

#### 描述

有 7 块板子放在一个"袋子"中, 随机从袋子中移除一个板子展示到玩家面前直到袋子变空。当袋子变空时, 它会被重新装填, 如果需要额外的板子, 则重复前面那个过程。

#### 输出

使用随机 bag 系统随机输出 50 块板子。

板子如下:

- O
- I
- S
- Z
- L
- J
- T

#### 输出样本

- `LJOZISTTLOSZIJOSTJZILLTZISJOOJSIZLTZISOJTLIOJLTSZO`
- `OTJZSILILTZJOSOSIZTJLITZOJLSLZISTOJZTSIOJLZOSILJTS`
- `ITJLZOSILJZSOTTJLOSIZIOLTZSJOLSJZITOZTLJISTLSZOIJO`



在 Perl 6 中我会这样写 (smls):

``` perl
say (|<O I S Z L J T>.pick(*) xx *).[^50].join;
```

注意:

- | 操作符把每次迭代的项展开进外部的列表中, 以使你不必在结果上显式地调用 .flat 方法
- 使用 `< >` 字符串列表字面量看起来比在字符串字面量上使用 .comb 方法更合适
- xx 操作符每次都会重新计算它左侧的表达式











