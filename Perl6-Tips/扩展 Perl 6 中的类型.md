# 扩展 Perl 6 中的类型

## 使用继承

```perl6
class BetterInt is Int {
    method even { self %% 2 }
}

my BetterInt $x .= new: 42;
say $x.even; 

$x .= new: 71;
say $x.even;

say $x + 42;

# OUTPUT:
# True
# False
# 113
```

`my BetterInt $x` 约束 `$x` 只能包含  *BetterInt* 或它的子类这种类型的对象。`.= new: 42` 等价于 `= BetterInt.new: 42`。
下面的子例程期望接收一个 *Int* 型的参数，但是你给它传递一个 *BetterInt* 类型的参数它会很高兴:

```perl6
sub foo(Int $x) { say "\$x is $x"}

my BetterInt $x .= new: 42;
foo $x;

# OUTPUT:
# $x is 42
```

## But... But... But...

另外一个选择是掺合进一个角色(role)。*but* 中缀操作符创建对象的一份拷贝并为该对象添加一个方法:

```perl6
my $x = 42 but role { method even { self %% 2 } };
say $x.even;

# OUTPUT:
# True
```

当然角色不一定是内联的。这儿有另外一个例子使用了一个预定义的角色并且还展示了我们的对象确实被拷贝了一份：

```perl6
role Better {
    method better { "Yes, I am better" }
}

class Foo {
    has $.attr is rw
}

my $original = Foo.new: :attr<original>;
my $copy     = $original but Better;
$copy.attr   = 'copy'; 

say $original.attr;  # still 'original'
say $copy.attr;      # this one is 'copy'

say $copy.better;
say $original.better; # fatal error: can't find method

# OUTPUT:
# original
# copy
# Yes, I am better
# Method 'better' not found for invocant of class 'Foo'
#   in block <unit> at test.p6 line 18
```

这看起来挺不错的，但是对于我们原来的目标来说，这个方法还是相当弱的：

```perl6
my $x = 42 but role { method even { self %% 2 } };
say $x.even; # True
$x = 72;
say $x.even; # No such method!
```

那个角色被混合进我们容器里面存储的对象中了；所以一旦我们在容器中放进了一个新的值，或高级点的东西，那么 *.even* 方法就不见了，除非我们再次把那个角色混合进来。

## 子例程

你知道你可以把子例程当做方法用嘛？ 你接收那个对象作为子例程的第一个位置参数并且你甚至能继续使用链式方法调用，但是不能把那些链子分解成多行：

```perl6
sub even { $^a %% 2 };
say 42.&even.uc;

# OUTPUT:
# TRUE
```

这确实是为核心类型添加额外功能的一种得体方式。我们的子例程定义中的 `$^a` 引用第一个参数（我们在调用的那个对象）并且整个子例程也可以被写为：

```perl6
sub ($x) { $x %% 2 }
```

## 飞龙在天

不管[Javaccript 的那些人们怎么跟你说](http://shop.oreilly.com/product/9780596517748.do), 然而扩充原生类型是危险的。因为你正影响程序的所有部分。甚至看不到你的扩充的模块也受到影响。

现在我有权告诉你，我跟你说过，你工作的核电厂融化了，让我们看看一些代码：

```perl6
# Foo.pm6
unit module Foo;
sub fob is export {
    say 42.even;
}

# Bar.pm6
unit module Bar;
use MONKEY-TYPING;
augment class Int {
    method even { self %% 2 }
}

# test.p6
use Foo;
use Bar;

say 72.even;
fob;

# OUTPUT:
# True
# True
```

所有的行为都发生在 *Bar.pm6* 中。首先，我们写了一行 *use MONKEY-TYPING* 声明，它告诉我们正在做一些危险的行为。然后我们在类 **class Int** 的前面使用了 *augment* 关键字以扩充这个已经存在的类。我们的扩充添加了一个叫 *even* 的方法以告诉我们那个 Int 是否是偶数。

所有的整数都可以使用 *even* 方法了，这虽然达到了我们的要求但是有点危险。


##  我邪恶了

我们来扩充 [Cool 类型](http://docs.perl6.org/type/Cool)以涵盖所有的西文排版行长单位：

```perl6
use MONKEY-TYPING;
augment class Cool {
    method even { self %% 2 }
}

.say for 72.even, '72'.even, pi.even, ½.even;

# OUTPUT:
# Method 'even' not found for invocant of class 'Int'
# in block <unit> at test.p6 line 8
```

糟糕，程序奔溃了！原因是在我们扩充 **Cool** 类型的时候，派生自 **Cool** 的所有类型已经成型了(composed)。所以为了让它能工作，我们必须使用 `.^compose` 元对象协议方法来重新构成它们：

```perl6
use MONKEY-TYPING;
augment class Cool {
    method even { self %% 2 }
}

.^compose for Int, Num, Rat, Str, IntStr, NumStr, RatStr;

.say for 72.even, '72'.even, pi.even, ½.even;

# OUTPUT:
# True
# True
# False
# False
```

它现在能工作了！Int, Num, Rat, Str, IntStr, NumStr, RatStr 类型拥有了 `.even` 方法(注意：这些不是继承自 Cool 的仅有的类型)! 这既邪恶又让人吃惊。

## 结论

当扩充 Perl 6 的核心类型或其它任意类的功能时，你有几种选择。

- 使用 **is Class** 子类
- 使用 **but Role** 混合一个角色
- 使用 `$objec.&sub` 调用子例程作为方法使用
- 使用  augment（注意安全）

[Perl 6 — There Is More Than One Way To Extend it](http://blogs.perl.org/users/zoffix_znet/2016/04/extra-typical-perl-6.html).
































