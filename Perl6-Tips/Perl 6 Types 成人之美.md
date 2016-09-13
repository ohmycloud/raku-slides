Perl 6 Types: 成人之美

在我的第一次大学编程语言课中， 我被告知 Pascal 语言在其它类型之外还拥有 **Integer**、**Boolen** 和 **Stirng** 类型。我知道了类型本来就该存在因为计算机很笨。当我在 C语言中涉猎的时候，我学到了更多有关 *int*、 *char* 和其它像在暖和的地方里地寄生虫， 还有我课桌底下嗡嗡的金属盒的声音。

Perl 5 没有类型，它给我的感觉就像骑着自行车无拘无束的追风少年，沿着斜坡而下。不久之后我一门心思钻到计算机硬件的缝隙中。我拥有数据并且我能用它做任何我想做的事， 只要我得到的不是错误的数据。当我搞定的时候，我从自行车上掉了下来并刮破了我的膝盖。

有了 Perl 6，鱼和熊掌可以兼得。你可以使用类型来避免它们。你可以拥有一个广域的类型来接收很多种类的值或窄类型。并且你可以享受代表机器智力的类型的速度， 或者你可以享受你自定义的代表你自己意志的类型的精度，类型为人类而生。

## 渐进类型

```perl6
my       $a = "whatever";
my Str   $b = "strings only";
my Str:D $c = "defined strings only";
my int   $d = 14; # native int

sub foo ($x) { $x + 2 }
sub bar (Int:D $x) returns Int { $x + 2 }
```

Perl 6 拥有渐进类型， 这意味着你要么可以使用它们，要么避免使用它们。所以究竟为什么要打扰它们呢？

首先，类型约束了你的变量中能包含的，你的方法或子例程接受的或返回的值的范围。这个函数即作为数据校验又作为安全网以过滤掉不正确代码所生成的垃圾数据。

还有，当使用原生的，机器意志的类型的时候，你可以获得更好地性能并减少内存使用，假如它们对于你得数据来说是合适的工具的话。

## 内置类型

有一个名副其实的自助式的[Perl 6 中得内置类型](http://docs.perl6.org/type.html)。如果你的子例程只对整数有意义，那么为你的参数使用 **Int** 类型。如果负数没有意义，那么使用 **UInt** - 一个无符号的 **Int** 来进一步限制值的范围。另一方面，如果你想处理一个较广的范围，那么 **Numeric** 类型可能更合适。

如果你想一探究竟，Perl 6 也提供了一系列的映射到你常常见到的，例如 C 语言中的原生类型。使用这些原生类型可能会提供性能提升或内存使用的减少。可用的原生类型有：int，int8，int16，int32，int64，uint，uint8，uint16，uint32，uint64，num，num32，num64。类型名字中的数字表示可得的字节，不含数字的类型是平台无关的。

诸如 int1，int2 和 int4 的子字节类型也计划在未来实现。

## 笑脸符号

```perl6
multi foo (Int:U $x) { 'Y U NO define $x?'         }
multi foo (Int:D $x) { "The Square of $x is {$x2}" }

my Int $x;
say foo $x;
$x = 42;
say foo $x;

# OUTPUT:
# Y U NO define $x?
# The square of 42 is 1764
```

笑脸符号是追加在类型名后面的 *:U*、*:D* 或 `:_` 。 在你没有指定笑脸符号的时候，`:_` 是你获得的默认笑脸符号。*:U* 只指定未定义(undefined)值，而 `:D` 只指定定义(defined)值。

通过在调用者身上使用两个带有 *:U* 和 *:D* 的 multis，我们能知道方法是在类上调用的还是在实例上调用的。如果你在核动力装置上工作，确保你的鲁棒插入子例程绝对不会插入任何未定义的量也是一件好事情，我想。

## Subsets：定制的类型

内置的类型很酷，但是程序员工作的大部分数据没有精确地匹配。这就是 Perl 6 subsets 进场的时候了。

```perl6
subset Prime of Int where *.is-prime;
my Prime $x = 3;
$x = 11; # works
$x = 4;  # 失败，类型不匹配。
```
使用 *subset* 关键字，我们就地创建了一个叫做 **Prime** 的类型。它是 **Int** 类型的一个子集(subset)，所以任何非 Int 数不匹配这个类型。我们还使用 *where* 关键字指定了一个额外的约束；那个约束是在给定值身上调用的 *.is-prime* 方法必须返回一个 true 值。

使用那个单行代码， 我们创建了一个特定的类型并可以像内置类型那样使用它！我们不仅可以用它来指定变量的类型、 子例程/方法的参数类型和返回值类型，我们还能使用智能匹配操作符来测试任意值，就像我们在内置类型中做得那样：

```perl6
subset Prime of Int where *.is-prime;
say "It is an Int" if 'foo' ~~ Int;   # false, it's a Str
say "It's a prime" if 31337 ~~ Prime; # true, it's a prime number
```

如果你的类型是一次性的东西，你只想把它应用到单个变量上呢？ 你一点也不必单独声明一个 subset！就在变量后面使用 *where* 关键字好了，你很好的：

```perl6
multi is-a-prime ( Int $ where *.is-prime --> 'Yup' ) {}
multi is-a-prime ( Any                    --> 'Nope') {}
  
say is-a-prime 3;     # Yup
say is-a-prime 4;     # Nope
say is-a-prime 'foo'; # Nope
```

上面的签名中的 **-->** 是表示返回值类型的另外一种方式，或者在这种情况下，是一种具体的返回值。所以我们拥有了两个含有不同签名的 multies。第一个接收一个 **Int** 类型的质数，第二个接受剩下的任何东西。我们的 multies 函数体中没有任何代码，就写了一个子例程告诉你一个数字是否是质数！

## 打包重用

目前为止我们学到的很酷，但是酷不是 awesome！你可能会很频繁地使用某些你自定义的类型。在厂里面工作，产品号至多有20个字符，以某种格式？ 非常好！我们为它创建一个子类型：

```perl6
subset ProductNumber of Str where { .chars <=20 and m/^ \d**3 <[-#]> / };
my ProductNumber $num = '333-FOOBAR';
```

这好极了，但是我们不想在所有的地方都重复这个 subset。 我们来把它推到一个单独的模块中。我会创建 `/opt/local/Perl6/Company/Types.pm6` 因为 ` /opt/local/Perl6 ` 是包含在我为这个虚构的厂所写的所有 apps 中的模块搜索路径中的路径。在这个文件中，我会有下面的代码：

```Perl6
unit module Company::Types;
my package EXPORT::DEFAULT {
    subset ProductNumber of Str where { .chars <=20 and m/^ \d**3 <[-#]> / };
}
```

我们给我们的模块起了一个名字并默认导出我们可爱的 subsets。我们的代码看起来怎么样了？ 它看起来酷毙了 - 不，等等， AWESOME -- 这一次：

```Perl6
use Company::Types;
my ProductNumber $num1 = '333-FOOBAR'; # succeeds
my ProductNumber $num2 = 'meow';       # fails
```

这样， 我们使用单个 use 语句扩展了 Perl 6 以为我们提供定制的类型，它精确地匹配了我们想要的数据成为什么样子。

## Awesome Error Messages for Subsets

如果你尝试过所有这些例子，你可能注意到一点小瑕疵。你得到的错误信息不够给力！

```perl6
Type check failed in assignment to $num2;
expected Company::Types::EXPORT::DEFAULT::ProductNumber but got Str ("meow")
in block <unit> at test.p6 line 3
```

当给你是你的目标的时候，你肯定有提升那些信息的方法。再次打开我们的 **Company::Types** 文件，并扩展我们的 **ProductNumber** 的 *where* 从句以包括给力的错误信息：

```perl6
subset ProductNumber of Str where {
    .chars <= 20 and m/^ \d**3 <[-#]> /
        or warn 'ProductNumber type expects a string at most 20 chars long'
            ~ ' with the first 4 characters in the format of \d\d\d[-|#]'
};

```
 现在，在东西不匹配我们的类型的时候，信息会在 **Type** 检查信息和栈追踪之前被包括进来， 为我们提供所期望的东西的更多信息。 如果你想，这儿你也可以调用 *fail* 代替 *warn* ，这时 Type check... 信息不会被打印出来，给你更多控制。
 
 ## 结论
 
 结论个大西瓜！