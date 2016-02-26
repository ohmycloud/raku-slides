title:  S07-Lists

date: 2016-01-23

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>但是怎么说, 总觉得, 我们之间留了太多空白格！</blockquote>

**push** 和 **append** 的表现不同, **push** 一次只添加单个参数到列表末端, **append** 一次可以添加多个参数。

``` perl
use v6;

my @d = ( [ 1 .. 3 ] );
@d.push( [ 4 .. 6 ] );
@d.push( [ 7 .. 9 ] );


for @d -> $r {
    say "$r[]";
}
# 1
# 2
# 3
# 4 5 6
# 7 8 9

for @d -> $r { say $r.WHAT() }
# (Int)
# (Int)
# (Int)
# (Array) 整个数组作为单个参数
# (Array)

say @d.perl;
# [1, 2, 3, [4, 5, 6], [7, 8, 9]]
```

使用 **append** 一次能追加多个元素:

``` perl
use v6;

my @d =  ( [ 1 .. 3 ] );
@d.append( [ 4 .. 6 ] );
@d.append( [ 7 .. 9 ] );

for @d -> $item {
    say "$item[]";
}
# 打印 1\n2\n3\n4\n5\n6\n7\n8\n9
# [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

这跟[The single argument rule](https://design.perl6.org/S07.html#The_single_argument_rule)有关。

## 设计大纲

Perl 6 提供了很多跟列表相关的特性, 包括 `eager`, `lazy`, `并行计算`, 还有紧凑型阵列和多维数组存储。

### Sequences vs. Lists

在 Perl 6 中, 我们使用项 `sequence` 来来指某个东西, 当需要的时候产生一个值的序列。即序列是惰性的。注意, 只能要求生成一次。我们使用项`list`来指能保存值的东西。

``` perl
(1, 2, 3)    # 列表, 最简单的 list
[1, 2, 3]    # 数组, Scalar 容器的列表
|(1, 2)      # a Slip, 一个展开到周围列表中的列表
$*IN.lines   # a Seq, 一个可以被连续处理的序列
(^1000).race # a HyperSeq, 一个可以并行处理的序列
```



### [The single argument rule](https://design.perl6.org/S07.html#The_single_argument_rule)

在 Perl 中 **@** 符号标示着 "这些"(**these**), 而 **$**符号标示着 "这个"(**the**)。这种**复数**/**单数**的明显差别出现在语言中的各种地方, Perl  中的很多便捷就是来源于这个特点。展平(Flattening)就是 @-like 的东西会在特定上下文中自动把它的值并入周围的列表中。之前这在 Perl 中既功能强大又很有迷惑性。在直截了当的发起知名的"单个参数规则"之前, Perl 6 在发展中通过了几次跟 flattening 有关的模仿。

对单个参数规则最好的理解是通过 **for**循环迭代的次数。对于 **for**循环, 要迭代的东西总是被当作单个参数。因此有了单个参数规则这个名字。

``` perl
for 1, 2, 3   { }   # 含有 3 个元素的列表, 3 次迭代
for (1, 2, 3) { }   # 含有 3 个元素的列表, 3 次迭代
for [1, 2, 3] { }   # 含有 3 个元素的数组(存放在 Scalar 中),  3次迭代
for @a, @b    { }   # 含有 2 个元素的列表, 2 次迭代
for (@a,)     { }   # 含有 1 个元素的列表, 1 次迭代
for (@a)      { }   # 含有 @a.elems 个元素的列表, @a.elems 次迭代
for @a        { }   # 含有 @a.elems 个元素的列表, @a.elems 次迭代
```

前两个是相同的, 因为圆括号事实上不构建列表, 而只是分组。是中缀操作符 `infix:<,>`组成的列表。第三个也执行了 3 次迭代, 因为在 Perl 6 中 `[...]` 构建了一个数组但是没有把它包裹进 `Scalar` 容器中。第四个会执行 2 次迭代, 因为参数是一个含有两个元素的列表, 而那两个元素恰好是数组, 它俩都有 @ 符号, 但是都没有导致展开。第 五 个同样, `infix:<,>` 很高兴地组成了只含一个元素的列表。

单个参数规则也考虑了 Scalar 容器。因此:

``` perl
for $(1, 2, 3) { }  # Scalar 容器中的一个列表, 1 次迭代  
for $[1, 2, 3] { }  # Scalar 容器中的一个数组, 1 次迭代  
for $@a        { }  # Scalar 容器中的一个数组, 1 次迭代  
```

``` perl
> for $(1, 2, 3) -> $i { say $i.elems }
3
> for $(1, 2, 3) -> $i { say $i }
(1 2 3)
> for $(1, 2, 3) -> $i { say $i.WHAT }
(List)
> for $(1, 2, 3) -> $i { say $i.perl }
$(1, 2, 3)

> for $[1, 2, 3] -> $i { say $i }
[1 2 3]
> for $[1, 2, 3] -> $i { say $i.perl }
$[1, 2, 3]
> for $[1, 2, 3] -> $i { say $i.WHAT }
(Array)
> for $[1, 2, 3] -> $i { say $i.elems }
3

> my  @a = 1,2,3
[1 2 3]
> for $@a -> $a  { say $a.perl }
$[1, 2, 3]
```

贯穿 Perl 6 语言, 单个参数规则(**Single argument rule**) 始终如一地被实现了。例如, 我们看 **push** 方法:

``` perl
@a.push: 1, 2, 3;       # pushes 3 values to @a
@a.push: [1, 2, 3];     # pushes 1 Array to @a
@a.push: @b;            # pushes 1 Array to @a
@a.push: @b,;           # same, trailing comma doesn't make > 1 argument
@a.push: $(1, 2, 3);    # pushes 1 value (a List) to @a
@a.push: $[1, 2, 3];    # pushes 1 value (an Array) to @a
```

此外, 列表构造器(例如 `infix:<,>` 操作符) 和数组构造器(`[…]`环缀)也遵守这个规则:

``` perl
    [1, 2, 3]               # Array of 3 elements
    [@a, @b]                # Array of 2 elements
    [@a, 1..10]             # Array of 2 elements
    [@a]                    # Array with the elements of @a copied into it
    [1..10]                 # Array with 10 elements
    [$@a]                   # Array with 1 element (@a)
    [@a,]                   # Array with 1 element (@a)
    [[1]]                   # Same as [1]
    [[1],]                  # Array with a single element that is [1]
    [$[1]]                  # Array with a single element that is [1]
```

所以, 要让最开始的那个例子工作, 使用:

``` perl
my @d = ( [ 1 .. 3 ], );  # [[1 2 3]]
@d.push: [ 4 .. 6 ];
@d.push: [ 7 .. 9 ];
# [[1 2 3] [4 5 6] [7 8 9]]
```

或者

``` perl
my @d = ( $[ 1 .. 3 ]);
@d.push: [ 4 ..6 ];
@d.push: [ 7 ..9 ];
```

## User-level Types

### List

**List** 是不可变的, 可能是无限的, 值的列表。组成 List 最简单的一种方法是使用 `infix:<,>` 操作符:

``` perl
1, 2, 3
```

**List** 可以被索引, 并且, 假设它是有限的, 也能询问列表中元素的个数:

``` perl
say (1, 2, 3)[1];    # 2
say (1, 2, 3).elems; # 3
```

因为**List**是不可变的, 对它进行 push、pop、shift、unshift 或 splice 是不可能的。 **reverse** 和 **rotate** 操作会返回新的 **Lists**。

虽然**List**自身是不可变的, 但是它包含的元素可以是可变的, 包括 `Scalar` 容器:

``` perl
my $a = 2;
my $b = 4;

($a, $b)[0]++;
($a, $b)[1] *= 2;
say $a; # 3
say $b; # 8
```

在 **List** 中尝试给不可变值赋值会导致错误:

``` perl
(1, 2, 3)[0]++; # Dies: 不能给不可变值赋值
```

### Slip

**Slip** 类型是 **List** 的一个子类。**Slip** 会把它的值并入周围的 **List** 中。

``` perl
(1, (2, 3), 4).elems      # 3
(1, slip(2, 3), 4).elems  # 4
```

把 **List** 强转为 **Slip** 是可能的, 所以上面的也能写为:

``` perl
(1, (2, 3).Slip, 4).elems # 4
```

在不发生 flattening 的地方使用 **Slip** 是一种常见的获取 flattening 的方式:

``` perl
my @a = 1, 2, 3;
my @b = 4, 5;

.say for @a.Slip, @b.Slip;  # 5 次迭代
```

这有点啰嗦, 使用 `prefix:<|>`来做 **Slip** 强转:

``` perl
my @a = 1, 2, 3;
my @b = 4, 5;

.say for |@a, |@b; # 5 次迭代
```

`|`在如下形式中也很有用:

``` perl
my @prefixed-values = 0, |@values;
```

这儿, 单个参数规则会使 @prefixed-values 拥有两个元素, 即 0 和 @values。

**Slip** 类型也可以用在 `map`、`gather/take`、和 `lazy`循环中。下面是一种 `map`能把多个值放进它的结果流里面的方法:

``` perl
my @a = 1, 2;
say @a.map({ $_ xx 2 }).elems;      # 2
say @a.map({ |($_ xx 2) }).elems;   # 4
```

因为 `$_ xx 2` 产生一个含有两个元素的列表(**List**)。

### Array

**Array** 是 **List** 的一个子类, 把赋值给数组的值放进 Scalar 容器中, 这意味着数组中的值可以被改变。**Array** 是 @-sigil 变量得到的默认类型。

``` perl
my @a = 1, 2, 3;
say @a.WHAT;     # (Array)
@a[1]++;         # Scalar 容器中的值可变
say @a;          # 1 3 3
```

如果没有 shape 属性, 数组会自动增长:

``` perl
my @a;
@a[5] = 42;
say @a.elems;  # 6
```

**Array**支持 `push`、`pop`、`shift`、`unshift` 和 `splice`。

给数组赋值默认是迫切的(**eager**), 并创建一组新的 Scalar 容器:

``` perl
my @a = 1, 2, 3;
my @b = @a;

@a[1]++;
say @b;  # 1, 2, 3
```

注意, `[...]` 数组构造器等价于创建然后再赋值给一个匿名数组。

### Seq

**Seq** 是单次值生产者。大部分列表处理操作返回 **Seq**。

``` perl
say (1, 2, 3).map(* + 1).^name;  # Seq
say (1, 2 Z 'a', 'b').^name;     # Seq
say (1, 1, * + * ... *).^name;   # Seq
say $*IN.lines.^name;            # Seq
```

因为 **Seq** 默认不会记住它的值(values), 所以 **Seq** 只能被使用一次。例如, 如果存储了一个 **Seq**:

``` perl
my \seq = (1, 2, 3).map(* + 1);
```

只有第一次迭代会有效, 之后再尝试迭代就会死, 因为值已经被用完了:

``` perl
for seq { .say }    # 2\n3\n4\n
for seq { .say }    # Dies: This Seq has already been iterated
```

这意味着你可以确信 for 循环迭代了文件的行:

``` perl
for open('data').lines {
    .say if /beer/;
}
```

这不会把文件中的行保持在内存中。此外设立不会把所有行保持在内存中的处理管道也会很容易:

``` perl
my \lines   = open('products').lines;
my \beer    = lines.grep(/beer/);
my \excited = beer.map(&uc);
.say for excited;
```

然而, 任何重用 `lines`、`beer`、或`excited` 的尝试都会导致错误。这段程序在性能上等价于:

``` perl
.say for open('products').lines.grep(/beer/).map(&uc);
```

但是提供了一个给阶段命名的机会。注意使用 Scalar 变量代替也是可以的, 但是单个参数规则需要最终的循环必须为:

``` perl
.say for |$excited;
```

只要序列没有被标记为 `lazy`, 把 **Seq** 赋值给数组就会迫切的执行操作并把结果存到数组中。因此, 任何人这样写就不惊讶了:

``` perl
my @lines   = open('products').lines;
my @beer    = @lines.grep(/beer/);
my @excited = @beer.map(&uc);
.say for @excited;
```

重用这些数组中的任何一个都没问题。当然, 该程序的内存表现完全不同, 并且它会较慢, 因为它创建了所有的额外的 Scalar 容器(导致额外的垃圾回收)和糟糕的位置引用。(我们不得不在程序的生命周期中多次谈论同一个字符串)。

偶尔, 要求 **Seq** 缓存自身也有用。这可以通过在**Seq** 身上调用 `cache`方法完成, 这从 **Seq** 得到一个惰性列表并返回它。之后再调用 `cache`方法会返回同样的惰性列表。注意, 第一次调用 `cache`方法会被算作消费了**Seq**, 所以如果之前已经发生了迭代它就不再有效, 而且之后任何在调用完 `cache`的迭代尝试都会失败。只有 `.cache`方法能被调用多于1 次。

**Seq** 不像 **List** 那样遵守 `Positional` role。 因此, **Seq** 不能被绑定给含有 @ 符号的变量:

``` perl
my @lines := $*IN.lines;  # Dies
```

这样做的一个后果就是, 原生地, 你不能传递 Seq 作为绑定给@符号的参数:

``` perl
sub process(@data) {
    
}
process($*IN.lines);
```

这会极不方便。因此, 签名 binder(它实际使用 ::= 赋值语义而非 :=)会 spot 失败来绑定 @符号参数, 并检查参数是否遵守了 Positional role。 如果遵守了, 那么它会在参数上调用 cache 方法并绑定它的结果代替。

### Iterable

**Seq** 和 **List** 这俩, 还有 Perl 6 中的各种其它类型, 遵守 **Iterable** role。这个 role 的主要意图是获得一个 `iterator`方法。中级 Perl 6 用户很少会关心 `iterator`方法和它返回什么。

**Iterable** 的第二个目的是为了标记出会被按需展开的东西, 使用 `flat`方法或用在它们身上的函数。

``` perl
my @a = 1, 2, 3;
my @b = 4, 5;

for flat @a, @b { }          # 5 次迭代
say [flat @a, @b].elems;     # 5 次迭代
```

**flat** 的另一用途是展开嵌套的列表结构。例如, **Z**(zip)操作符产生一个列表的列表:

``` perl
say (1, 2 Z 'a', 'b').perl;  # ((1, "a"), (2, "b")).Seq
```

**flat** 能用于展开它们, 这在和使用带有多个参数的尖块 for 循环一块使用时很有用:

``` perl
for flat 1, 2 Z 'a', 'b' -> $num, $letter  { }
```

注意 **flat** 也涉及 Scalar 容器, 所以:

``` perl
for flat $(1, 2) { }
```

将只会迭代一次。记住数组把所有东西都存放在 Scalar 容器中, 在数组身上调用 *flat* 总是和迭代数组自身相同。实际上, 在数组上调用 *flat* 返回的同一性。