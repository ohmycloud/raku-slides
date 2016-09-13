

Perl 6 最近(2015.9)经历的最大的变化就是 Great List Refactor(GLR), 俗称大列表重构。

它还很难解释！但是幸好有某些历史背景能帮助我们。 在 2014 年澳大利亚 Perl Workshop 会议上讨论了很多 GLR 的东西,  Patrick Michaud 在它的博客上写了很多关于 GLR 的内容。



GLE 意图强调性能和列表和相关类型操作的一致性问题。改变这样的基本数据类型将会很痛苦。



通常 Perl 5 这样展开列表:

``` perl
% perl -dE 1 -MData::Dumper

[...snip...]
DB<1> @foos=((1,2),3)

DB<2> say Dumper \@foos
$VAR1 = [
    1,
    2,
    3
];
```

开始, 很多的 Perl 6 行为都模仿这种展平行为但是在去年年底的时候, 使用 non-flatterning(非展平)行为以保留原始数据结构的用法越来越多。



这样做和很多边界情况不一致并且 Rakudo 内部大量使用了一种叫做 `Parcel` 的数据类型, 之后 Parcel 被认为是一个 Bad Idea(糟糕的设计) —  主要是因为性能问题。



2015 年 7 月, Patrick 导入了一个涵盖 "Synopsis 7" 的孪生设计草案, 随后的月份中它变成官方的 S07。



8 月份对于 GLR 是很繁忙的一个月。乔纳森.华盛顿在 Rakudo 仓库下开启了一个单独的 GLR 分支。很多人在那个分支下协同工作。同时在 IRC 频道有俩个机器人, Camelia 和 GLRelia(后者跟踪 GLR 分支)。所以人们能很快尝试并比较在新旧系统中代码的行为。大量的变化和诸如 panda 的软件不得不进行修补以保持功能。



**Parcel** 数据类型变成了 **List**（它是不可变的并使用圆括号）而数组是 List 的一个可变子类, 它使用方括号。数组不再拥有隐式的列表展平行为。简单的数组可以使用 `.flat`方法进行展平。

### Pre GLR

``` perl6
my @array = 1,(2,3),4;       # 1 2 3 4
@array.elems.say;            # 4   
```

### Post GLR

```perl6
my @array = 1,(2,3),4;        # [1 (2 3) 4]
@array.elems.say;             # 3

my @array = (1,(2,3),4).flat; # [1 2 3 4]
```

把列表滑进(Slip)数组中也是可行的:

``` perl6
my @a = 1, (2, 3).Slip, 4;    # [1 2 3 4]
```

还有:

``` perl6
my @a = 1, |(2,3), 4;         # [1 2 3 4]
```

序列(只能够被耗费**一次**)被引入:

``` perl6
my $grep = (1..4).grep(*>2);  # (3 4)
$grep.^name.say;              # Seq
```

而 `.cache`方法能用于阻止 Seq 的消费。

### The Single Argument Rule

传递给诸如 *for*循环迭代器的参数遵守"the single arg rule", 意思是即使第一眼看上去是以多个参数出现的, 也会被当作单个参数。通常这会让 *for* 表现得如程序员所期望的那样除了带有尾随逗号的例子。

``` perl6
my @a = 1,2,3;
my ($i, $j);
for (@a) {
    $i++;
}

for (@a,) { # 这实际上是单个元素列表(single element list)
    $j++;
}

say :$i.gist;  # => 3
say :$j.gist;  # => 1
```

S07 在 2015年9月份被乔纳森-华盛顿重写了。结果就是 S07经历了很多改变。*Parcel* 被移除了, 重新引入进来, 并且最终又被移除了!
