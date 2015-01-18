Perl6 中的标量、数组和散列怎样进行插值？
分类: Perl6
日期: 2013-06-25 09:29
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101d32j.html
Perl 6 中的标量、数组、散列如何插值？ 标量、数组和散列插值

将标量放在 双引号 中会进行插值，就跟Perl 5 中一样：
use v6;

my $name = "Foo";
say "Hello $name, how are you?";



这会打印:
Hello Foo, how are you?


数组和散列不是这样进行插值的，在字符串中，任何放进花括号中的东西都会被插值
，所以如果你有一个数组，您能这样写：

  use v6;

my @names = ;
say "Hello {@names}, how are you?";


to get this output:
Hello Foo Bar Moo, how are you?

这里的问题是基于输出结果你不知道数组是有3个元素还是2个：
"Foo Bar" 和 "Moo", 或仅仅一个元素: "Foo Bar Moo".


 

内插表达式

上面的就不是个问题！ 在用双引号引起来的字符串中，你可以将任何表达式放在花括号中。表达式会被计算，其结果会被插值 ：

你可以这样写:
use v6;

my @names = ;
say "Hello {
 


join(', ', @names)

 
} how are you?";



输出如下:
Hello Foo, Bar, Moo how are you?


然而这依然没有准确地显示有几个值，这显得稍微复杂了。

作为旁注，万一你更喜欢面向对象的代码，你也可以像下面这样写:
say "Hello { @names
.join
(', ') } how are you?";



结果一样.

  调试打印

 

对于基本的调试目的，做好使用数组的 .perl 方法：

 

say "Names: { @names.perl }";


那会打印：
Names: Array.new("Foo", "Bar", "Moo")


假使你想同时看到变量名呢？那你可以依赖 数组在双引号字符串中不插值 这点这样写：

 

say " @names = { @names.perl }";


那会打印：
@names = Array.new("Foo", "Bar", "Moo")
 仅仅是表达式
use v6;

say "Take 1+4";



会打印：
Take 1+4
就像我所写的，你
可以将任何表达式放进花括号
中，你也可以这样写： 
 

use v6;

say "Take {1+4}";


那会打印：
Take 5
 插值散列

  use v6;

my %phone = (
      foo => 1,
      bar => 2,
);

say "%phone = { %phone } ";


会打印：


%phone = foo    1 bar  2


这分不清哪些是键，哪些是值

  对于调试目的，你最好用 .perl 方法：

 say "%phone = { %phone.perl } ";


会打印:
%phone = ("foo" => 1, "bar" => 2).hash
 插值多维数组

 
use v6;

my @matrix = (
    [1, 2],
    [3, 4],
);

say "@matrix = { @matrix.perl }";


输出:
@matrix = Array.new([1, 2], [3, 4])


I think it makes it very clear what is in the array.