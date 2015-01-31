# 2010 年 Perl6 圣诞月历(廿三)一些精彩的排序示例

继续我们的圣诞礼物。

排序是一个非常非常常见的编程任务。Perl6 加强了它的 .sort 功能来帮助大家更好的排序。

最最正常的默认写法是这样的：
```perl
my @sorted = @unsorted.sort; # 或者 这样
sort @unsorted;
```
和 Perl5 一样，也是可以自定义函数的：
$^a 和 $^b 没有特殊的意义, 只是两个占位符.相当于形式参数 $x, $y 

    # 数值比较
    my @sorted = @unsorted.sort: { $^a <=> $^b };
	
    # 或者用函数调用的形式
    my @sorted = sort { $^a <=> $^b }, @unsorted;
	
    # 字符串比对 ( 跟Perl5的cmp一样 )
    my @sorted = @unsorted.sort: { $^a leg $^b };
	
    # 类型依赖比对
    my @sorted = @unsorted.sort: { $^a cmp $^b };

试试看:
```perl
> my @unsorted = <2 1 3 5 9 7>;
2 1 3 5 9 7
> my @sorted = @unsorted.sort: { $^a <=> $^b};
1 2 3 5 7 9
> my @sorted = @unsorted.sort: { $^b <=> $^a};
9 7 5 3 2 1
> my @sorted = sort { $^a <=> $^b}, @unsorted;
1 2 3 5 7 9
> my @sorted = sort { $^b <=> $^a}, @unsorted;
9 7 5 3 2 1
```
	
你也可以把 : 换成 () ，然后再跟上一些方法进行后续处理，比如：

    my @topten = @scores.sort( { $^b <=> $^a } ).list.munch(10);

小提示： $a 和 $b 不再像在 Perl5 中那样有**特殊含义**了，在 sort 代码块里用别的命名变量 $var 、**位置变量 $^var** 或者其他任何的都跟在其他代码段里一样。

你可以直接在排序的时候直接就做好变换函数：

    my @sorted = @unsorted.sort: { foo($^a) cmp foo($^b) };

不过 foo() 会重复执行，如果列表不大也就罢了，如果比较大的话……如果 foo() 还是个计算密集型的……你懂的！

在这种情况下，Perl5 里有个习惯就是使用施瓦茨( Schwartzian )变换。施瓦茨变换的做法就是 decorate-sort-undecorate， foo() 函数只用执行一次：

    @sorted =
        map  { $_->[0] }
        sort { $a->[1] cmp $b->[1] }
        map  { [$_, foo($_)] }
        @unsorted;

Perl6 里，你一样可以使用施瓦茨变换，不过 Perl6 内置了一些智能方法。如果你有一个函数，它接受的参数个数是** 0 或 1 ** ，Perl6 会自动的替你启用施瓦茨变换。

现在让我们来看一些例子吧。

### 不区分大小写的排序:

把每个元素都改成小写，然后把数组按照**小写**的次序排好返回。

    my @sorted = @unsorted.sort: { .lc };
	my @sorted = @unsorted.sort: { $^a.lc <=> $^b.lc}; # 同上
	my @sorted = @unsorted.sort: { $^a.lc }; # 与上面相同, $^a 只是一个占位符
	
### 单词长度排序：

把每个元素的单词按照从短到长排序。

    my @sorted = @unsorted.sort: { .chars };

### 或者从长到短。
    my @sorted = @unsorted.sort: { -.chars };

### 多次排序比较：

你可以在 sort 代码块里放多个比较函数，sort 会顺序执行直到退出。比如在单词长度的基础上，再按照 ASCII 码的顺序排序。

    .say for @a.sort: { $^a.chars, $^a } ;

不过，在 Rakudo 里好像运行有点问题……它只会比较长度不会比较数值，也就是说， 10 排在 2 的前面。（没关系，TMTONTDI）

perl6 里的 sort 本身是稳定工作的，你可以重复使用。

    .say for @a.sort.sort: { $^a.chars };

不过这样 sort 有两次调用，no fashion ！所以你还可以这么写：

    .say for @a.sort: { $^a.chars <=> $^b.chars || $^a leg $^b };

不过这下你有**两个**参数了，perl6 没法自动给你启动施瓦茨变换了。

又或者，你可以加上一个给自然数排序的**函数**：

    .say for @a.sort: { $^a.chars.&naturally, $^a };

“给自然数排序？”我好像听到你们的哭声了，“哪里有？”

很高兴你们这么问，现在继续解决这个问题。

自然数排序

标准的词法排序是按照 ASCII 次序的。先是自然数，然后是大写字母，最后是小写字母。所以人们在排序的时候经常得到这样的结果：

    0
    1
    100
    11
    144th
    2
    21
    210
    3rd
    33rd
    AND
    ARE
    An
    Bit
    Can
    and
    by
    car
    d1
    d10
    d2

完全正确，但是没用……尤其是对非程序员来说，更郁闷了就……

真正的自然排序，应该是先按数学量级排自然数，然后才是大小写字母。比如上面那个例子，应该排成这样：

    0
    1
    2
    3rd
    11
    21
    33rd
    100
    144th
    210
    An
    AND
    and
    ARE
    Bit
    by
    Can
    car
    d1
    d2
    d10

所以，我们必须的在排序的时候加上一点转换了。

我使用 .subst 方法，这是我们所熟悉的 s/// 操作符的面向对象形式。

    .subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)

第一部分，捕获一个连续的数字，然后由 ->$/{} 构成一个尖块，意思是：“传递匹配到 $/ 的数组到 {} 代码里”。然后代码里替换成用 0 按照数量级排序的顺序联结的字符串。这个 0 是以 ASCII 字符串出现，联结在原始字符串上的。最后 :g 表示全局替换。

如果也不区分大小写，那么：

    .lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)

改成子例程的方式：

    sub naturally ($a) {
        $a.lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)
    }

看起来很不错了，不过还有点小问题，比如 THE 、 The 和 the 会按照他们在列表里的顺序返回，而不是我们预计的顺序。有个简单的解决办法，就是在转换过的元素的结尾，加上一个中断。所以最终结果是：

    sub naturally ($a) {
        $a.lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g) ~ "\x0" ~ $a
    }

然后你看，这个子例程只有一个参数，所以我们还可以用上施瓦茨变换了：

    .say for <0 1 100 11 144th 2 21 210 3rd 33rd AND ARE An Bit Can and by car d1 d10 d2>.sort: { .&naturally };

或者用来给 ip 排序：

    my @ips = ((0..255).roll(4).join('.') for 0..99);
    .say for @ips.sort: { .&naturally };
    4.108.172.65
    5.149.121.70
    10.24.201.53
    11.10.90.219
    12.83.84.206
    12.124.106.41
    12.162.149.98
    14.203.88.93
    16.18.0.178
    17.68.226.104
    21.201.181.225
    23.61.166.202

以及目录排序啊等等各种数字与字母的混合体~~

最后，圣诞快乐，排序快乐，愿施瓦茨与你同在！
