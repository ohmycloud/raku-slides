# 译文_在 Perl6 中相对于 Perl5 几个非常可喜的变化
> 分类: Perl6

日期: 2013-05-18 23:40
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101cbar.html
译文:在 Perl6 中相对于 Perl5 几个非常可喜的变化
> 扶 凯 2012年05月5日 - 03:04 0
注: 译文 JimmyZ 所推荐的   Perl 6 的一个 blog .相当不错的文章,所以译过来和大家一起分享.
原文链接:http://stevieb-tech.blogspot.de/2012/04/use-perl6-my-first-experience-with.html


我已经使用 Perl 编程的10年了，我已经听说了非常多的关于 Perl6 的东西。这是一些非常热爱它的人，有谁不喜欢吗?（恐惧）。对于我来说，我一直想进一步了解它，但从来没有时间。不要误会，我绝对爱 Perl5 中，并一直会使用它，直到我们到了一天，使用这个达到现在相同的水平，我会让老的代码慢慢逐渐消失。


在过去几周，我一直在看 Perl6 链接中有关 moritz's PerlMonks。下面这里有一些非常有趣的差异，我迄今来所发现。


在这篇文章中，我会接触到一些东西如 strict，sigils，什么是变量对象和方法，类型还有一些控制结构.我会介绍变化相关的基本知识，然后看看新的语言中更先进的方面。当你认为足够好用，可以努力给你的应用从 Perl 5 转换 Perl 6.


## STRICT
开箱即用,第一个很不错的功能是 strict 的严格检查是默认启用的.

    % cat no_strict.pl
     
    #!/home/steve/perl6/perl6
    say $hello;
输出:
    % ./no_strict.pl
    ===SORRY!===
    Variable $hello is not declared at ./no_strict.pl:2
## SIGILS
Perl6， 变量记得本身的 sigils ,不管你怎么样操作和执行什么。


Perl 5 的方法:
```perl
my @a = qw( 1, 2, 3 );
say $a[0];
 
my %h = ( key => 'value' );
say $h{ 'key' };
```
但在 Perl6 中:
```perl
my @a = 1, 2, 3;
say @a [0];
 
my %h = 'key' => 'value';
say %h { 'key' };
```
数组部分的代码和我们想象的一样是正常的.当我们访问哈希的值时,Perl6 中哈希的键要用引号引起来才会自动引用其值 .不然这个时候,其实他会调用子函数,这时会调用 sub key ().但我感觉,这时我们如果要创建功能调度表会快很多.
通过某个键访问哈希值的正确方法是使用引号给键引起来.也可以象下面这样的：
```perl
# the old faithful
say %h{ 'key' };
 
# or the new auto-quote syntax
say %h< key > ;
```
变量是面象对象的（也有方法）
这里有几个例子是有关变量的动作所新加的变量对象的方法。我首先展示数组的几个例子，然后哈希。还值得一提的是有关括号和数组元素的不足。就是少了 qw() 函数。

变量的方法,数组
```perl
my @a = 2, 3, 1;

# number of array elements
say @a.elems;
say scalar @a;
 
# sort array
say @a.sort;
say sort @a;
 
# map array
say @a.map({ $_ + 10 });
say map { $_ + 10, ' ' } @a;
 
# or even
 
say @a.sort.map({ $_ + 10 });
say map { $_ + 10, ' ' } sort @a;
```
我们可以发现一些不同,在 Perl 5 中:

    perl -E 'my @a=qw( 1 2 3 ); my $x=@a; say $x'

但在 Perl6:
    > perl6 -e 'my @a=1,2,3; my $x=@a; say $x'
    2 3
但是，我们还是可以使用数组来进行计算数组元素的个数的数字比较：

    > perl6 -e 'my @a=1,2,3; say "ok" if @a == 3'
    ok
哈希和 Perl 5 的语法接近
```perl
my %h = z => 26, b => 5, c => 2, a => 9;

say %h.keys;
say $_ for keys %h;
# could also be written as:
say keys %h; # but the spacing is different in 5
 
say %h.values;
say $_ for values %h;
 
say %h.keys.sort;
say $_ for sort keys %h;
```
注：大多数变量的对象的方法也仍然作为函数，因此下面是等价的：
```perl
say %h.keys;
say keys %h;
```
一切是一个对象，都有一个类型（可以受到限制-可选）
下面是一个简单明了的例子，解析所谓一切都是对象，都有类型.我会使用一些 Perl6 的语法来尝试着下,这会让我们很惊讶它是如何工作的。这个 WHAT() 的方法调用的时候,会得到这个东西的类型.
```perl
# calling methods on literals w00t! 
 
say 25.WHAT;
say 'string'.WHAT;
say (1,2,3).WHAT;
```
输出:
    Int()
    Str()
    Parcel()
我们可以很方便的做类型的检查:
```perl
my $quote = "I am liking Perl6";
 
if $quote ~~ Str {
    say "it's a string";
}
```
注意括号, 这时在 IF() 条件中,变得非常的短小了.现在,是这样也可以使用的（但也有陷阱），所以建议您不要使用它们。

约束某些变量的类型也很容易。
```perl
# define $x as an Int
my Int $x = 5;
 
# try to assign it a string
$x = "Hello, world!";
```
输出:


Type check failed in assignment to '$x'; expected 'Int' but got 'Str'
  in block   at ./types.pl:15
在 Perl 6 中的类型是一个有着继承层次的结构，但我还不太熟悉。如果我了解更多,我会更新这篇文章。例如，int是 Numeric 的子类。
 
控制结构
我在上面简要介绍了使用 if 语句(不使用括号)。看这个例子：
```perl
my $x = 5;
if ($x < 10){
    # do stuff
}
```
Perl6，为了防止失误，它 完全省略了括号 。这里有一些有趣的变化,这其实是告诉你,它尝试调用'一个函数名'为 "if".象 if, while, for 都这样.

在 Perl 5 中，在大多数情况下，我们会给要使用的元素命名成词法变量,象下面这样的 for 循环中的 $elem：

    for my $elem ( @a ){ say $elem; }
Perl6，避免使用$_,，我们使用 -> ("pointy block"):

    for @a -> $elem { say $elem; }
我确认我上面的 Perl 5 的 for() 代码在我的眼中是没有问题的.但如果我在 Perl 6 中执行这样的写法,没使用后面这种典型的用法的话. Perl 6 会给出如下的提示.

===SORRY!===
This appears to be Perl 5 code
at ./control.pl:15
  在 Perl 6 中，非常的形象,它看起来像的尖尖块在向前移。另一个有关 for() 的需要注意.现在，它只能用于列表。 perl6 对于C风格的for循环,有一个分开的loop() 结构。

另外,可以使用一个以上的循环变量：

```perl
for @a -> $first, $second, $third { 
    say "$first, $second, $third: I'm greedy on each iteration!"; 
}
```

遍历哈希
```perl
for %h.kv -> $k, $v {
    say "$k :: $v"
}
```
```perl
> for @a -> $first, $second, $third { say "$first, $second, $third: I'm greedy on each iteration!"; }
```
```perl
    1, 2, 3: I'm greedy on each iteration!
    4, 5, 6: I'm greedy on each iteration!
    7, 8, 9: I'm greedy on each iteration!
```