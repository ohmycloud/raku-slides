# Perl 6专家指南 - 元操作符
> 分类: Perl6



## 元操作符
examples/arrays/assignment_shortcut.p6
```perl
#!/usr/bin/env perl6
use v6;

my $num = 23;
say $num + 19;        # 42
say $num;             # 23

$num += 19;
say $num;             # 42
```

## 赋值时的方法调用
在Perl 6 中它扩展了点操作符的功能，允许在对象上进行方法调用。想想下面的例子。
subst方法能够用一个字符串替换另外一个，但是并不改变原来的字符串。默认地，它返回改变了的字符串.

如果你想改变原字符串，你可以写为 $str = $str.subst('B', 'X'); 或者你可以写成它的 shortcut version.

examples/arrays/assignment_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

my $str = 'ABBA';
say $str.subst('B', 'X');      # AXBA
say $str;                                      # ABBA

say $str .= subst('B', 'X'); # AXBA
say $str;                                      # AXBA
```
## 赋值时调用函数
这也同样可以用于函数中，就如 $lower = min($lower, $new_value); 你可以写为 $lower min= $new_value;

examples/arrays/assignment_function_shortcuts.p6
```perl
#!/usr/bin/env perl6
use v6;

my $lower = 2;
$lower min= 3;
say $lower;                # 2

$lower min= 1;
say $lower;                # 1
```
这甚至可以有效地使用逗号操作符向数组中压入更多值。
```perl
  my @a = (1, 2, 3);
  @a ,= 4;
  @a.say;
``` 
##  反转关系操作符
等号(==)操作符在Perl6 中用于比较数字，eq用于比较字符串。 The negated version are the same just with an exclamation mark ( ! ) in front of them. 所以它们看起来就是 !== 和 !eq.

幸运的是，那些都有它们的快捷写法，可以写为!=和ne。

其他操作符也有相应的反转版本，所以你可以写 !>= ，它的意思是不大于 (对于数字) 并且你可以写!gt ，对于字符串来说是一样的. 我没有全部摊出我们为什么需要这个。

一个我能明白的优点是如果你创建了一个叫做I的操作符，然后你会自动得到一个看起来像!I 的操作符，那是它的反转。

examples/arrays/negated_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

# 相等
say 1 ==  1 ?? 'y' !! 'n'; # y
say 1 !== 1 ?? 'y' !! 'n'; # n
say 1 !=  1 ?? 'y' !! 'n'; # n

say 'ac' eq  'dc' ?? 'y' !! 'n'; #n
say 'ac' !eq 'dc' ?? 'y' !! 'n'; #y

say 1 <  2  ?? 'y' !! 'n'; # y
####say 1 !< 2  ?? 'y' !! 'n'; # n

say 1 <=  2  ?? 'y' !! 'n'; # y
####say 1 !<= 2  ?? 'y' !! 'n'; # n

say 1 >=  2  ?? 'y' !! 'n'; # n
####say 1 !>= 2  ?? 'y' !! 'n'; # y
```
## 反转操作符
反转操作符会反转两个操作数的意思. 所以就像交换 $b cmp $a 中参数的值，你可以写为 $a Rcmp $b.
I wonder if the same would also work on operators such as gt ? Could I use $x Rgt $y meaning $y gt $x ? Why is that good?

examples/arrays/reversed_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

# 宇宙飞船操作符
say 1 <=> 2;  # -1
say 2 <=> 1;  # 1

say 1 R<=> 2;  # 1
say 2 R<=> 1;  # -1
```
输出：
```perl
examples/arrays/reversed_operators.p6.out
Increase
Decrease
Decrease
Increase
```
## Hyper 操作符
Hyper operators are really interesting. They allow the extrapolation of a scalar operator to operate on a list of scalars.

The real operators are actually unicode characters but using regular doubled angle-brackets also work.

Normally the arrows point inside, towards the operator and there are two lists on the two sides of the operator.

This will apply the regular infix operator to the pairs as taken from the two lists on the two sides and return a list with the same length.

If the list on one side is longer than on the other side perl throws an exception "Non-dwimmy hyperoperator cannot be used on arrays of different sizes or dimensions."

In order to make the operator dwimmy you need to turn the arrows around to point to the operand that should dwim. It can be either or both operands. If an operand is being pointed at (that is if it is supposed to dwim) then in case that operand is too short, perl will automatically use the last value of it repeatadly as long as the other side needs pairs.

You can make both sides dwimmy if you don't know up front which one will be longer and if you want to make them work in both ways.

As a special case if one side is a single scalar and if the arrow points in its direction then that value will be paired with each one of the values from the array on the other side.

examples/arrays/hyper.p6
```perl
#!/usr/bin/env perl6
use v6;

my @x = (1, 2) >>+<< (3, 4);
say @x.perl;  # [4, 6]

#my @d = (1, 2) >>+<< (3);
#say @d.perl;  # [4, 6]
# Non-dwimmy hyperoperator cannot be used  on arrays of different sizes or dimensions.

my @z = (1, 2, 3, 4) >>+>> (1, 2);
say @z.perl;          # [2, 4, 5, 6]

@z = (1, 2, 3, 4) <<+>> (1, 2);
say @z.perl;          # [2, 4, 5, 6]

@z = (4) <<+>> (1, 2);
say @z.perl;          # [5, 6]

my @y = (1, 2) >>+>> 1;
say @y.perl;          # [2, 3]
```
examples/arrays/hyper.p6.out
```perl
Array.new(4, 6)
Array.new(2, 4, 4, 6)
Array.new(2, 4, 4, 6)
Array.new(5, 6)
Array.new(2, 3)
```
## Reduction 操作符
examples/arrays/reduction_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

say [+] 1, 2;    # 3
say [+] 1..10;  # 55

# 阶乘
say [*] 1..5;    # 120

say [**] 2,2,2; # 16      == 2**2**2

my @numbers = (2, 4, 3);

# 检查数字是否是递增顺序
say [<] @numbers;          # False   

say [<] sort @numbers; # True
```
输出
```perl
examples/arrays/reduction_operators.p6.out
3
55
120
16
False
True
```
## Reduction Triangle operators
The ~ in front of the operator is only needed for the stringification of the list to inject spaces between the values when printed.

examples/arrays/triangle_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

say ~[\+] 1..5;  # 1 3 6 10 15 (1 1+2 1+2+3 ... 1+2+3+4+5)
say ~[\*] 1..5;  # 1 2 6 24 120
```
输出：
```perl
examples/arrays/triangle_operators.p6.out
1 3 6 10 15
1 2 6 24 120
```

## 交叉操作符 Cross operators

examples/arrays/cross_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

my @x = (1, 2) X+ (4, 7);
say @x.perl;              # [5, 8, 6, 9] 1+4,1+7,2+4,2+7

my @y = 1, 2 X+ 4, 7;
say @y.perl;              # [5, 8, 6, 9]

my @str = 1, 2 X~ 4, 7;
say @str.perl;              # ["14", "17", "24", "27"]

# without any special operator  (is the same with X, should be)
my @z = 1, 2 X 4, 7;
say @z.perl;                  # [1, 4, 1, 7, 2, 4, 2, 7]
```
输出：
```perl
examples/arrays/cross_operators.p6.out
Array.new(5, 8, 6, 9)
Array.new(5, 8, 6, 9)
Array.new("14", "17", "24", "27")
Array.new(1, 4, 1, 7, 2, 4, 2, 7)
```
## 积的交叉
> my @y = 1, 2 X* 4, 7;

4 7 8 14