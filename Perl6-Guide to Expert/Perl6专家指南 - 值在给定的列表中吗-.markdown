# Perl6专家指南 - 值在给定的列表中吗？
>分类: Perl6
日期: 2013-06-24 21:36
怎样找出一个给定的值是否在一些值的中间？这跟SQL中的IN操作符相似。
在 Perl 6  中，有一个 any() 函数，其功能与SQL 中的IN 关键字相似。让我们看看它如何工作: 它是一个weekday吗?
```perl
use v6;

my @weekdays = ;
my $day = "Tuesday";
say $day eq any(@weekdays)
   
 ??
 "$day is a weekday"    
 !!
 "$day is NOT a weekday";
```
 上面的代码将打印出：
Tuesday is a weekday

perl会尝试使用 eq 让@weekdays中的每一个元素都与$day标量的内容相比较，如果它们中的任意一个为真，表达式即为真。 Perl 6 中的三元操作符
旁注:  ?? !! 对Perl 6 的三元操作符。它语法如下：
```perl
CONDITION   
?? 
   VALUE_IF_TRUE 
!!
    VALUE_IF_FALSE;
```
它仍然是weekday吗?
更完整的例子让我们来看当所有这些值都不匹配时会发生什么:
```perl
use v6;
my @weekdays = ;
my $other = "Holiday";
say $other eq any(@weekdays)
    
 ?? 
"$other is a weekday" 
 !!
 "$other is NOT a weekday";
```
 代码相同但是不会打印匹配值:
Holiday is NOT a weekday
## 使用小于号比较数字
下个例子我们将会看到any函数能用于其它诸如小于号操作符的比较运算符上:
```perl
use v6;

my @numbers = (6, -12, 20);
say any(@numbers)< 0 
    ?? "There is a negative number"
    !! "No negative number here";
```
	结果为:
There is a negative number
你也可以使用其它操作符.
假使没有负数它也有效:
```perl
my @positive_numbers = (6, 12, 20);
say any(@positive_numbers) < 0
    ?? "There is a negative number"
    !! "No negative number here";
```
	输出:
No negative number here
 其它关键字: none, all, one
还有其它函数, 不仅仅是 *any* 函数: (all, one and none)
```perl
use v6;
my @positive_numbers = (6, 12, 20);
say none(@positive_numbers) < 0
    ?? "No negative number here"
    !! "There is a negative number";
```
会打印:
No negative number here
```perl
use v6;

my @positive_numbers = (6, 12, 20);
say all(@positive_numbers) > 0
    ?? "All are positive numbers"
    !! "There is a NOT positive number";
```
会打印:
All are positive numbers

使用最合适的那个函数。  更短的写法
有时候你有一个值，你需要检测它是否等于一个所列值中的任意一个：
```perl
use v6;

my $n = 12;
say ($n == 23 or $n == 42) ?? "ok" !! "not ok";  # not ok
```
使用 any 函数你可以这样写:
```perl
use v6;
my $n = 12;
say $n == any(23, 42)
 ?? "ok" !! "not ok";  # not ok

 any 函数也有一个单管道线的中缀操作符版本，所以你也能这样写:
use v6;
my $n = 12;
say $n == 23|42
 ?? "ok" !! "not ok";  # not ok
```
##  交叉
这些关键词和相关操作所做的实际上是创建了一种叫做Junction的数据类型。它是一个标量，以一种无序的方式存储着多个值。跟集合类似。
第一个例子也可以这样写:
```perl
use v6;
my $weekdays = any ;
my $day = "Tuesday";
say $day eq $weekdays
    ?? "$day is a weekday"
    !! "$day is NOT a weekday";
```
这里我们创建了一个junction而非数组，然后使用该junction进行比较。 Other operations on Junctions
In addition to the comparison operations we saw earlier, we can do other operations on junctions. The operation will be executed on each one of the values in the junction and the result will be a new junction with the changed values:
```perl
use v6;

my $numbers = any(23, 42);
$numbers.perl.say;
$numbers++;
$numbers.perl.say;
```
这会打印该 junction的perl表现:
any(23, 42)
any(24, 43)
## Functions on Junctions
你也可以将 junctions 作为参数传递给函数。 The function will be executed on each value separately in an undefined order, and the result will be another junction. For example if we would like to create the 3 character version of the months we can use the following code:
```perl
use v6;
my $months = any ;
my $short_names = substr($months, 0, 3);
$short_names.perl.say;
```
Which should print
any("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",  "Sep", "Oct", "Nov", "Dec");
  