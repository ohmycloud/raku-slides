Perl 6 中的 .polymod 方法 - 把数字分解成分母

## 命名

`.polymod` 方法接受几个除数并把它的调用者分解成一份一份的:

```perl6
my $seconds = 1 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds

say $seconds.polymod: 60, 60;
say $seconds.polymod: 60, 60, 24;

# OUTPUT:
# (5 4 27)
# (5 4 3 1)
```

这种情况下我们作为参数传递的除数是和时间相关的: 60(每分钟有多少秒)， 60(每小时有多少分钟)，和24(每天有多少小时)。从最小的单位开始， 我们一直前进到最大的单位。

输出和输入的除数是相匹配的 - 从最小的单位到最大的单位： 5 秒，4 分钟，3 小时和 1 天。

## 手工制作

不使用 `.polymod` 而使用一个循环来展示怎么之前的计算:

```perl6
my $seconds = 2 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds

my @pieces;
for 60, 60, 24 -> $divisor {
    @pieces.push: $seconds mod $divisor;
    $seconds div= $divisor
}
@pieces.push: $seconds;

say @pieces;

# OUTPUT:
# [5 4 3 2]
```

## 超越无限

当除数是以惰性列表的形式传递给 `.polymod` 方法时，它会一直运行直到余数为零并不会遍历整个列表:

```perl6
say 120.polymod:      10¹, 10², 10³, 10⁴, 10⁵;
say 120.polymod: lazy 10¹, 10², 10³, 10⁴, 10⁵;
say 120.polymod:      10¹, 10², 10³ … ∞;

# OUTPUT:
# (0 12 0 0 0 0)
# (0 12)
# (0 12)
```

在第一个调用中， 我们让一系列数字按 10 的幂增长。该调用的输出包含了 4 个尾部的零，因为 `.polymod` 方法计算了每个除数。在第二个调用中，我们使用 `lazy` 关键字显式地创建了一个惰性列表， 而现在我们在返回的列表中只有 2 个条目。

第一个除数(10)结果余数为 0，这是返回列表中的第一个条目，对于下一个除数，整除把我们的 120 变成了 12。12 除以 100 的余数为 12， 它是返回列表中的第二个条目。 现在， 12 整除 100 为 0， 它终止了 `.polymod` 的执行并给了我们两个 条目的结果。

在最后一个调用中，我们使用了省略号，它是一个序列操作符，用来创建一系列按 10 的幂增长的数字，但是这一次序列是无限的。因为它是惰性的，结果再一次只有 2 个元素。

## Zip It, Lock It, Put It In The Pocket

单独的数字很好但是对于它们所代表的单位不够具有描述性。我们来使用 Zip 元操作符:

```perl6
my @units  = <ng μg mg g kg>;
my @pieces = 42_666_555_444_333.polymod: 10³ xx ∞;

say @pieces Z~ @units;
# OUTPUT:
# (333ng 444μg 555mg 666g 42kg)
```


## 快速命名

对于被调用者和除数，你不仅仅限于使用 Ints，也可以使用其它类型的数字。

```perl6
say ⅔.polymod: ⅓;

say 5.Rat.polymod: .3, .2;
say 3.Rat.polymod: ⅔, ⅓;

# OUTPUT:
# (0 2)
# (0.2 0 80)
# (0.333333 0 12)
```


```perl6
say 5.Num.polymod: .3, .2;
say 3.Num.polymod: ⅔, ⅓;

# OUTPUT:
# (0.2 0.199999999999999 79)
# (0.333333333333333 2.22044604925031e-16 12)
```

## 使用 Number::Denominate 模块

[Number::Denominate](http://modules.perl6.org/repo/Number::Denominate)

```perl6
use Number::Denominate;

my $seconds = 1 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds

say denominate $seconds;
say denominate $seconds, :set<weight>;

# OUTPUT:
# 1 day, 3 hours, 4 minutes, and 5 seconds
# 97 kilograms and 445 grams
```

你还可以定义自己的单位:

```perl6
say denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );

# OUTPUT:
# 4 foos, 2 boors, and 1 ber
```

[原文地址](http://perl6.party/post/Perl6-.polymod-break-up-a-number-into-denominations)
