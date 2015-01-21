# Perl 5 to Perl 6 - 数组 

> 分类: Perl6

> 日期: 2013-06-25 12:20 

 
## 创建数组, Data::Dumper, 调试打印

 

在Perl6 中创建数组跟在Perl5 中一样， 对于调试打印我们会使用Perl6 的.perl方法来代替Perl5中的Data::Dumper .
```perl
use v6;

my @numbers = ("one", "two", "three");
say @numbers.perl;   # Array.new("one", "two", "three")
```

在Perl6中，列表周围的圆括号不再需要了 ：
```perl
use v6;

my @digits = 1, 3, 6;
say @digits.perl;  # Array.new(1, 3, 6)
```
 qw() 不再使用

Perl 5 中的 qw() 操作符被 尖括号 取代：
```perl
use v6;

my @names = <foo bar baz> ;
say @names.perl;  # Array.new("foo", "bar", "baz")
```
## 字符串中的数组插值

在*双引号字符串*中，数组**不再**插值：
```perl
use v6;

my @names = "red","yellow","green";
say "@names";  # @names
```

你可以放心地写下这样的句子而 不转义 @ 符号:
```perl
use v6;

my @names = ;
say joe@names.org;    # joe@names.org
```

如果你确实要内插数组的值，你必须将数组放在一对 花括号 中：
```perl
use v6;

my @names = < foo bar baz > ;
say "names: {@names}"; # names: foo bar baz
```


##  取数组元素, 魔符不变

 

当在Perl 6 中访问 数组 的元素时， 元素前的符号不会改变 ！这对Perl 5 程序员来说会很奇怪，但是长期看来它有优势。
```perl
use v6;

my @names = < foo bar baz > ;
say @names[0];    # foo
```

## 内插一个数组元素

  作为一个特殊情况，一个数组元素能被内插在双引号字符串中而不使用花括号。术语 post-circumfix 对于方括号或花括号来说是一个一般称谓. 一般地,带有前置符号的变量可以被内插.
```perl
use v6;

my @names = < foo bar baz >;
say "name:@names[0]";   # name: foo
```
## 数组中元素的个数

在  Perl 6 中,推荐使用 elems()方法 和相关的函数来得到数组的元素个数。实际上，我认为面向对象的写法更美观:
```perl
use v6;

my @names = < foo bar baz >;
say elems @names;    # 3
say @names.elems;    # 3
```
## 范围

范围在Perl 6 中跟Perl 5 很像：
```perl
use v6;

my @d = 1..11;
say @d.perl;    # Array.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
```
这同样作用于标量变量的任意一边:
```perl
use v6;

my $start = 1;
my $end = 11;

my @d = $start .. $end;
say @d.perl;  # Array.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
```
ranges一个很有意思的方面可能是，你能对单个或两个范围的 *终点* 使用 ^ 符号告诉它们 **排除**终点 ：
```perl
use v6;

my $start = 1;
my $end = 11;

my @d = $start ^..^ $end; # 1的终点是1，11的终点是11，排除这两个值
say @d.perl;              # Array.new(2, 3, 4, 5, 6, 7, 8, 9, 10)
```

范围操作符同样对 字符 有效：
```perl
use v6;

my @chars = ('a' .. 'd');
say @chars.perl;    # Array.new("a", "b", "c", "d")
```
## for  和 foreach 循环

Perl 5 中C风格的for 循环现在叫做loop，但是我不会在这儿展示它。
```perl
use v6;

for 1..3 -> $i {
    say $i; 
}
```
输出为
```perl
1
2
3
```

这同样对数组有效:
```perl
use v6;

my @names = < foo bar baz >;
for @names -> $n {
    say $n;
}
```
输出:
```perl
foo
bar
baz
```

顺便提一下, 这是你*不用使用my*声明一个变量的情况之一 。循环变量自动被声明好了，并且作用到for循环块中。 遍历数组的索引

如果你想遍历数组的索引，你可以使用范围，从0一直到最大的索引值。最大索引值比数组元素的个数少1.你可以用 @names.elems -1 作为最优的范围 ,或者你可以使用 ^   符号告诉范围**排除**最后一个值：
```perl
use v6;

my @names = < foo bar baz >;
for 0 ..^ @names.elems -> $i {
    say "$i {@names[$i]}";
}
```

输出:
```perl
0 foo
1 bar
2 baz
```

或者这样： 
```perl
use v6;

my @names = < foo bar baz >;
for @names.keys -> $i {
    say "$i {@names[$i]}";
}
```

从散列中借来的keys()方法会返回数组所有的索引 。即使你的数组含有‘空’值，即带有undef的元素，keys()仍旧会包含这样的元素的索引。 

## split

split() 表现的就像Perl 5 中split的副本一样，但是默认行为不再应用，无论如何，你应该查看文档：
```perl
use v6;

say "a,b,c".split(',').perl;  # ("a", "b", "c").list
```