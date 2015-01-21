# Perl 6 Tips - 元操作符
我们习惯了很多语言的快捷操作符。

## examples/arrays/assignment_shortcut.p6
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
在Perl 6 中扩展了点操作符的功能， 允许在对象上进行方法调用 。想想下面的例子。subst方法能够用一个字符串替换另外一个，但是并 **不改变**原来的字符串 。默认地，它返回**改变了**的字符串.

如果你想改变原字符串，你可以写为 $str = $str.subst('B', 'X'); 或者你可以写成它的 shortcut version.

examples/arrays/assignment_operators.p6
```perl
#!/usr/bin/env perl6k
use v6;

my $str = 'ABBA';
say $str.subst('B', 'X');      # AXBA
say $str;                      # ABBA

say $str .= subst('B', 'X');   # AXBA
say $str;                      # AXBA
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
这甚至可以有效地使用 **逗号操作符** 向数组中压入更多值。
```perl
  my @a = (1, 2, 3);
  @a ,= 4;
  @a.say;
``` 
##  反转关系操作符
等号(==)操作符在Perl6 中用于 **比较数字** ，eq用于 **比较字符串** 。 这两个操作符的相反版本就是在原先的操作符前面加上感叹号 ( ! ), 所以它们看起来就是 !== 和 !eq .

幸运的是，那些都有它们的快捷写法，可以写为 ** != ** 和 ** ne ** 。

其他操作符也有相应的反转版本，所以你可以写 !>= ，它的意思是不大于 (对于数字) 并且你可以写!gt ，对于字符串来说是一样的. 我没有全部摊出我们为什么需要这个。

一个我能明白的优点是如果你创建了一个叫做 I 的操作符，然后你会自动得到一个看起来像 !I 的操作符，那是它的**反转**。

examples/arrays/negated_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

# 相等
say 1 ==  1 ?? 'y' !! 'n';              # y
say 1 !== 1 ?? 'y' !! 'n';              # n
say 1 !=  1 ?? 'y' !! 'n';              # n

say 'ac' eq  'dc' ?? 'y' !! 'n';        #n
say 'ac' !eq 'dc' ?? 'y' !! 'n';        #y

say 1 <  2  ?? 'y' !! 'n';              # y
####say 1 !< 2  ?? 'y' !! 'n';          # n

say 1 <=  2  ?? 'y' !! 'n';             # y
####say 1 !<= 2  ?? 'y' !! 'n';         # n

say 1 >=  2  ?? 'y' !! 'n';             # n
####say 1 !>= 2  ?? 'y' !! 'n';         # y
```
## 反转操作符
反转操作符会反转两个操作数的意思. 所以就像交换 $b cmp $a 中参数的值，你可以写为 $a **Rcmp** $b.
我想知道这是否会在诸如 gt 之类的操作符上有效？ 我能使用 $x Rgt $y代替 $y gt $x 吗 ?为什么那很好？

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

examples/arrays/reversed_operators.p6.out

    Increase
    Decrease
    Decrease
    Increase

## Hyper 操作符 —— 超运算符
Hyper操作符真的很有趣。 超运算符允许你拓展一个标量操作符的功能，而能够**操作列表**。

这个操作符其实是一个Unicode字符，但是使用常规的双尖括号也能工作。正常情况下，箭头是指向**内侧**的（例如>>+<<），向着操作符的方向，并且操作符的两边有两个列表。这会将常规的中缀操作符应用到取自两侧列表中的成对儿元素上，并 返回一个**同等长度**的列表 。如果一侧的列表比另一侧的长度长，perl 抛出一个异常： "Non-dwimmy hyperoperator cannot be used on arrays of different sizes or dimensions."  dwim=do what i mean，按照我的意思做。 前面那句话意思是，超运算符没有按照我的意思做，它不能用在大小和维数**不同**的数组上。

examples/arrays/hyper.p6  
```perl
#!/usr/bin/env perl6
use v6;

my @x = (1, 2) >>+<< (3, 4);
say @x.perl;  # Array.new(4, 6)

#my @d = (1, 2) >>+<< (3);
#say @d.perl;  # [4, 6]
# Non-dwimmy hyperoperator cannot be used  on arrays of different sizes or dimensions.

my @z = (1, 2, 3, 4) >>+>> (1, 2);
say @z.perl;          # Array.new(2, 4, 4, 6)，列表(1,2)被自动循环使用为(1,2,1,2)


@z = (1, 2, 3, 4) <<+>> (1, 2);
say @z.perl;          # Array.new(2, 4, 4, 6)

@z = (4) <<+>> (1, 2);
say @z.perl;          # Array.new(5, 6)


my @y = (1, 2) >>+>> 1;
say @y.perl;          # Array.new(2, 3)
```
examples/arrays/hyper.p6.out

    Array.new (4, 6)
    Array.new(2, 4, 4, 6)
    Array.new(2, 4, 4, 6)
    Array.new(5, 6)
    Array.new(2, 3)

## Reduction 操作符
examples/arrays/reduction_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

say [+] 1, 2;    # 3
say [+] 1..10;   # 55

# 阶乘
say [*] 1..5;    # 120

say [**] 2,2,2;  # 16      == 2**2**2

my @numbers = (2, 4, 3);

# 检查数字是否是递增顺序
say [<] @numbers;          # False   

say [<] sort @numbers;     # True
```
输出

examples/arrays/reduction_operators.p6.out

    3
    55
    120
    16
    False
    True

## Reduction Triangle operators
 操作符前的 ~ 符号用于列表元素的字符串化，并在打印时在值之间 插入空格 。

examples/arrays/triangle_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

say ~[\+] 1..5;  # 1 3 6 10 15 (1 1+2 1+2+3 ... 1+2+3+4+5)
say ~[\*] 1..5;  # 1 2 6 24 120
```
输出：

examples/arrays/triangle_operators.p6.out

    1 3 6 10 15
    1 2 6 24 120

## 交叉操作符 Cross operators

examples/arrays/cross_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

my @x = (1, 2) X+ (4, 7);
say @x.perl;              #Array.new(5, 8, 6, 9) ，等价于 1+4,1+7,2+4,2+7

my @y = 1, 2 X** 4, 7;
say @y.perl;              # Array.new(1 ,1, 16, 128)

my @str = 1, 2 X~ 4, 7;
say @str.perl;            # ["14", "17", "24", "27"]

# 不带任何特殊操作符 (is the same with X, should be)
my @z = 1, 2 X 4, 7;
say @z.perl;              # [1, 4, 1, 7, 2, 4, 2, 7]
```
输出：
examples/arrays/cross_operators.p6.out

    Array.new(5, 8, 6, 9)
    Array.new(5, 8, 6, 9)
    Array.new("14", "17", "24", "27")
    Array.new(1, 4, 1, 7, 2, 4, 2, 7)

## 积的交叉
```perl
> my @y = 1, 2 X* 4, 7;
4 7 8 14
```