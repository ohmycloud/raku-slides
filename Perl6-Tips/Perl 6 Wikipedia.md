

Perl 6 是 Perl 编程语言家族中的一员. 它仍旧在开发中, 几个解释器和编译器在同时进行. 它引入了很多现代和历史语言的元素. Perl 6 打算有很多实现. 和 Perl 5 兼容不是它的目标, 尽管兼容模式是它的计划书的一部分. Perl 6 的设计程序是从 2000 年开始的. 2015 年 9 月 预期会发布候选版, 并在 12 月 发布最终版.



Perl 6 第一个完成度最高的实现是 [Pugs](https://en.wikipedia.org/wiki/Pugs) , 开始于 2005 年, 今天已经有多个 Perl 6 实现的工程了. [Rakudo Perl](https://en.wikipedia.org/wiki/Rakudo_Perl) 是基于 NQP (Not Quite Perl) 并使用 [MoarVM](https://en.wikipedia.org/wiki/MoarVM) 或 [Java 虚拟机](https://en.wikipedia.org/wiki/Java_Virtual_Machine) 作为运行时环境的一个 Perl 6 实现, 并且每个月会发布一个新版本;  在 2010 年 七月, 该项目发布了第一次 Rakudo Star 分发,  一个有用和可用的 Perl 6 实现和相关东西的集合. Larry Wall 维护了一个众所周知的叫做 STD.pm6 的引用文法, 它是用 Perl 6 写的, 并使用 Perl 5 驱动 ([bootstrapped](https://en.wikipedia.org/wiki/Bootstrapping_(compilers)))



Niecza, 另一个主要的 Perl 6 实现, 专注于优化和效率研究. 它的目标是 [Common Language Infrastructure](https://en.wikipedia.org/wiki/Common_Language_Infrastructure)



## 历史

> 在 Perl 6 中, 我们决定修复语言而非修正使用者  — Larry Wall



Perl 6 的设计程序首先是在 2000.7.19 , 在 Perl 大会的第四天, 由 Larry Wall 在它的"洋葱头的状态 2000" 演讲上宣布的.  那时候, 主要的目标是移除语言中的"历史毒瘤”; 容易的事情应该保持容易, 困难的事情应该变得更简单, 不可能的事情应该变得可能.开始整理内部设计和 APIs. 程序开始于一系列[请求评论](https://en.wikipedia.org/wiki/Request_for_Comments) 或者 ‘RFCs’. 这个过程对所有贡献者公开, 让语言的各个方面都保持可变状态.



一旦 RFC 完成 , Larry Wall  评估并归类了每个请求（收到了 361个请求）。 他开始写了几个”启示”，他本来打算再写一部 Programming Perl 的。



有 3 个主要的场所来学习 Perl 6： [#perl6 IRC 频道](irc://irc.freenode.net/#perl6) ， [邮件列表](https://en.wikipedia.org/wiki/Mailing_list) 和 [Git 源代码仓库](https://en.wikipedia.org/wiki/Source_code_repository)



## 目标

解决 Perl 5 的历史毒瘤。过去那些年， Perl 6 在方向上经历了几个抉择。早期受 Python 和 Ruby 的影响引入了一些概念， 但是因为 Pugs 解释器是用 Haskell 写的， Perl 6 设计团队吸收了很多函数式编程的思想。



## 吉祥物

Perl 6 的吉祥物是一只蝴蝶，代表着 Perl 6 的虫子。 蝴蝶的翅膀上嵌入了类似字符 “P6”的螺旋形设计，那是 Perl 6 的昵称。



## 实现

到 2015 年， 只有 Rakudo Perl 还在活跃开发中。没有实现会成为 Perl 6 的官方实现；当然啦，"只要通过官方测试套件的实现就是 Perl 6”。



Rakudo Perl 是在几种虚拟机之上的 Perl 6 实现， 例如 MoarVM， Java 虚拟机，和 Javascript。 MoarVM 是为渐进类型编程语言设计的虚拟机，主要用于 Perl 6. 在 Perl 6 和 虚拟机之间有一个叫做 Not Quite Perl 或 NQP 的层， 它实现了解析 Perl 6 的 [Perl 6 规则](https://en.wikipedia.org/wiki/Perl_6_rules), 还有一个[抽象语法树](https://en.wikipedia.org/wiki/Abstract_syntax_tree) 和 特定后端的[代码生成](https://en.wikipedia.org/wiki/Code_generation_(compiler)). Perl 6 的大部分都是用 Perl 6 自身写成的， 或用它的子集 NQP 写成。 Rakudo 既不是一个完全自举的实现， 此时也不会有具体的计划让 Rakudo 成为一个 bootstrapping 编译器。



## 历史上的实现

那时候最早出现的 Perl 6 实现是 Pugs，它是用 Haskell 写的。Pugs 过去是完成度最高的 Perl 6 实现，但是自从 2007 年年中，它就基本上蛰伏了。 到 2014 年 11 月， Pugs 就不再被积极维护了。



2007 年，v6-MiniPerl6 (“mp6”） 和它的重新实现， v6-KindaPerl6 ("kp6”) 被写出来， 它使用Perl 5来驱动 Perl-6.0.0 STD。 STD 对于 Perl 6 是完整的 grammar， 并用 Perl 6 写成。 理论上， 任何能解析 STD并生成可执行代码的东西对于Perl 6 都是合适的驱动系统。 kp6 目前由 mp6 编译，并且能工作在多个后端上。 mp6 和 kp6 不是完全的 Perl 6 实现， 它们被设计为实现用于驱动一个完整 Perl 6 编译器的最少功能集合。



Yapsi 是一个 Perl 6 编译器， 并且运行时是用 Perl 6 自身写的。 作为结果， 为了运行，它要求先存在一个 Perl 6 解释器， 例如 Rakudo Star 的发布之一。



## 模块系统

Perl 6 计划书要求模块由名字，版本和作者标识。 只加载指定版本的模块， 或两个同名但版本或作者不同的版本。



## 相对 Perl 5来说主要的变化

Perl 5 和 Perl 6从根本上就是不同的两种语言，主要的变化是使新手和专家更容易掌握该语言， 使容易的事情更容易， 困难的事情变得可能。

### 计划书

Perl 6 是从计划书开始的。这意味着 Perl 6可以在需要时被重新实现。

### 类型系统

在 Perl 6 中， Perl 5 的动态类型系统通过额外的静态类型被增强了。 例如：

``` perl
 my Int $i = 0;
 my Rat $r = 3.142;
 my Str $s = "Hello, world";
```

然而， 静态类型仍旧是可选的， 所以编程人员可以不用任何显式的类型：

``` perl
 my $i = "25" + 10; # $i is 35
```

Perl 6 提供了混合类型系统， 靠这点儿， 程序员可以选择使用静态类型、使用动态类型、或混合使用这两种类型。

### 形式的子例程参数列表

Perl 5 定义子例程时一点儿也没使用形式参数。传递进来的子例程参数被存储到数组 `@_` 中，数组中的每个参数都是对应形式参数的别名，如果 `@_`  中的元素被修改了， 变化会被反映到原数据上。



Perl 6 引入了真正的形式参数。 在Perl 6 中， 子例程像这样定义：

``` perl
sub do_something(Str $thing, Int $other) {
     . . .
 }
```

就像在 Perl 5中那样， 形参（i.e. 参数列表中的变量）是实参（传递进来的值）的别名， 但是默认的， 这种别名是常量的，所以不能被修改。 它们可以被显式地声明为可读-可写，作为原值或原值的副本， 使用 `is rw` 或 `is copy` 指令。

### 参数传递模式

Perl 6 提供 3 种基本的参数传递模式

- 位置的

- 具名的

- Slurpy

  ​

位置参数是大多数编程语言中都使用的典型的有序参数列表。所有的参数也可以一种无序的方式， 通过使用它们的名字传递。 具名参数只能通过指定它们的名字被传递（即，它从来不会捕获位置参数），具名参数用一个前置的 `:` 标示。吞噬参数(由参数名字前面的 `*` 标示) 是 Perl 6 中创建可变函数的工具。吞噬散列会捕获剩下的按名字传递的参数， 而吞噬数组会捕获剩下的按位置传递的参数。



下面是一个使用 3 种参数传递模式的例子：

``` perl
 sub somefunction($a, $b, :$c, :$d, *@e) {
   . . .
 }

 somefunction(1, 2, :d(3), 4, 5, 6); # $a=1, $b=2, $d=3, @e=(4,5,6)
 somefunction(:b<2>, :a<1>);         # $a="1", $b="2"
```

诸如上面使用的位置参数，总是必须的， 除非它后面跟着一个 `?` 以标示它们是可选的。 具名参数默认是可选的， 但是能够通过在变量名的后面添加一个  `!` 把它标记为必选参数。吞噬参数总是可选的。

### Blocks 和 闭包

参数能被传递给任意的块儿， 这些块儿充当着闭包。 即， 举个例子， `for` 和 `while` 的循环变量可以被命名。在下面的例子中， 遍历一个列表， 每次 3 个元素，`$a,$b,$c` 作为变量被传递给循环的块儿。

``` perl
for @list -> $a, $b, $c {
     . . .
 }
```

这通常被引用为  `pointy sub`  或  `pointy block`,  箭头表现的几乎和 `sub` 关键字相同，它引入了一个匿名的闭包（或者用 Perl 5 的专业术语来说，引入了一个匿名子例程）。

### 符号不变性

在 Perl 5 中，变量名字前面的标点符号字符， 根据变量的使用方式而变化：

``` perl
# Perl 5 code
my @array = ('a', 'b', 'c');
my $element = $array[1];    # $element equals 'b',
my @extract = @array[1, 2]; # @extract equals ('b', 'c')
my $element = @array[1];    # 'b' comes with a warning (5.10 option)
```

在 Perl 6 中， 符号是不变的，这意味着，它不会根据它是一个数组还是一个数组元素而改变变量名前的符号：

``` perl
# Perl 6 code
my @array = 'a', 'b', 'c';
my $element = @array[1];    # $element equals 'b'
my @extract = @array[1];    # @extract equals ('b')
my @extract = @array[1, 2]; # @extract equals ('b', 'c')
```

Perl 5 中的变体是受英语中的数字契约和其它很多自然语言影响的：

``` perl
"This apple."                    # $a        CORRECT
"These apples."                  # @a        CORRECT
"This third apple."              # $a[3]     CORRECT
"These third apple."             # @a[3]     WRONG
```

然而， 当有了引用之后， 这种概念的映射就不起作用了， 因为它们可能引用的数据结构， 尽管它们是标量。 因此， 在单个 term 中，处理嵌套的数据结构可能既需要单数， 也需要复数形式的表达式：

``` perl
# Perl 5 code: retrieve a list from the leaf of a hash containing hashes that contain arrays
my @trans_verbs = @{ $dictionary{ 'verb' }{ 'transitive' } };
```

相比来说， 在 Perl 6 中：

``` perl
# Perl 6 code: retrieve a list from the leaf of a hash containing hashes that contain arrays
my @trans_verbs = %dictionary{ 'verb' }{ 'transitive' }.list;
```

### 面向对象编程

Perl 5 通过 blessing 机制支持面向对象的编程。 任何引用都可以被 blessed 到特定类的对象中。

例如， 一个封装了笛卡尔点的类可以这样写：

``` perl
class Point is rw {
   has $.x;
   has $.y;
 }

 my $point = Point.new( x => 1.2, y => -3.7 );

 # Now change x (note method "x" used as lvalue):
 $point.x = 2;
 say "Point is at X location: ", $point.x;
```

在 Perl 6 的专业术语中， `$.x` 叫做"属性”。有些语言叫这个 字段或成员。用于访问属性的方法叫做 “存取器”。自动存取器是自动创建的方法， 就像上面的 `x` 方法一样。 这些存取器函数返回属性的值。 当使用 `is rw` 修饰符声明一个类或单独的属性时，能传递一个新值给自动存取器来设置给属性， 或者它能作为一个左值被直接赋值（就像例子中的一样）。 自动存取器能被用户自定义的方法替换，程序员应该想要接口更丰富的属性。 属性只能在类的定义中被直接访问。 所有其它的访问方式必须经过存取器方法。

### Roles

Perl 6 中的 roles 具有 Java 中的接口、 Ruby 中的 mixins 和 Smalltalk 中 traits 的功能。 这些都很像类， 但是它们是完全抽象的。 这些 Roles 在和类一块儿使用时， 用于执行混合而不是添加到类的继承链中。 Roles 定义名义上的类型， 它们为行为和状态集合提供了语义上的名字。role 和 类的最重要的区别就是， 类是可继承的， 而 roles 不是。



本质上， role 是一束不使用继承，添加到类中的方法和属性。 role 甚至可以被添加到单独的对象中。这时， Perl 6 会创建一个匿名的子类， 并把 role 添加到子类中， 并把对象的类改为匿名的子类。



例如， 狗（Dog）是一种哺乳动物（Mammal）。Dogs 从 Mammals 那儿继承某些特征， 诸如乳腺和脊柱（通过 Mammals的父类， 脊椎动物 Vetebrate）。 Dogs 可能有几个不同类型的行为； 例如， 一个 Dog 可能是 Pet， Stray， 或 导盲犬。 然而， 这些只是一组可以添加给一个 Dog 的额外的行为； Cat 能等同于 一个 Pet 或 Stray， 举个例子， 因此， Dog 和 Mammal 是类， 而 Pet， Stray， 和 导盲犬是 roles。

``` perl
class Mammal is Vertebrate {
     . . .
 }
 class Dog is Mammal {
     . . .
 }
 role Pet {
     . . .
 }
 role Stray {
     . . .
 }
 role Guide {
     . . .
 }
```

通过使用 `does` 关键字把 Roles  添加到类中， 与继承的关键字 `is` 相对。关键字反应了两种功能的不同意义： role 混合给类一个行为的 role， 但是不继承表明它和 role 是同样的东西：

``` perl

 class GuideDog is Dog does Guide {
     . . .
 }   # Subclass composes role

 my $dog = new Dog;
 $dog does Guide;                         # Individual object composes role

```

尽管 role 和 类不同， 但它们都是类型， 所以 role 能出现在变量声明的地方， 这个地方通常会放置一个类。例如， 一个用于 Human 的 导盲犬 role 可以包含 Guide 类型的属性； 这个属性可以包含 一个 Guide Dog， 一个 Guide Horse， 一个 Guide Human， 或者甚至一个 Guide Machine。

``` perl
 class Human {
     has Dog $dog;                        # Can contain any kind of Dog, whether it does the
     ...                                  # Guide role or not
 }
 role Blind {
     has Guide $guide;                    # Can contain any object that does the Guide role,
     ...                                  # whether it is a Dog or something else
 }
```

### 正则表达式

主要文章 ： [Perl 6 rules](https://en.wikipedia.org/wiki/Perl_6_rules)

### 链式比较

Perl 6 允许链式比较， 即诸如下面这样的比较序列是被允许的：

``` perl
if 20 <= $temperature <= 25 {
     say "Room temperature is between 20 and 25!"
 }
```

### 惰性求值

Perl 6 使用列表的惰性列表求值技术，惰性求值已经是诸如 Haskell 等函数式编程语言的功能亮点了：

``` perl
@integers = 0..Inf; # integers from 0 to infinity
```

上面的代码在尝试把一个无限列表赋值给数组 `@integers` 时既不会崩溃， 也不会在尝试搜索某个限定的点以扩展列表时无限挂起。



这简化了很多普通的 Perl 6 任务， 包括输入/输出操作， 列表转换 和参数传递。

### Gather

跟惰性求值相关的就是使用 `gather` 和 `take` 构建惰性列表， 这跟 Python 中的生成器有点像。

``` perl
my $squares = gather for 0..Inf {
     take $_ * $_;
 };
```

`$squares` 会是一个平方数字的无限列表， 但是 `gather` 的惰性求值确保了值只在被访问时才被计算。

### Junctions

Perl 6 引入了 junctions 概念：由其它值混合而成的值。在 Perl 6 早期的设计中， 它们被叫做 “叠加”， 与量子物理中的量子叠加概念类似 — 波形能同时占据几种状态直到观测使它们坍缩。



在它们的最简单的形式中， 通过使用 junctive 操作符组合一组值来创建 junctions ：

``` perl
my $any_even_digit = 0 | 2 | 4 | 6 | 8; # any(0, 2, 4, 6, 8)
my $all_odd_digits = 1 & 3 & 5 & 7 & 9; # all(1, 3, 5, 7, 9)
```

`|` 表明一个要么等于它左边的参数， 要么等于它右边的参数的值。 `&` 表明一个即等于它左边的参数又等于它右边参数的值。这些值能像普通值那样用在任何代码中。 对 Junction 执行的操作会同等地作用在 junction 的每一个成员身上， 并根据 junctive 操作符进行组合。 所以, `("apple"|"banana") ~ "s"`  会产生 `"apples"|"bananas"`.  在比较操作中， junction 会返回单个 True 或 False。 `any` junction 会返回 true， 如果junction的任一元素的比较为真的话。 `all` junctions 会返回真， 如果 junction 的所有元素的比较为真的话。



Junctions 通过引入用于约束 junctions 类型的一般编程风格，也能用于极大地增强类型系统：

``` perl
sub get_tint(RGB_Color | CMYK_Color $color, Num $opacity) {
     . . .
 }
 sub store_record(Record & Storable $rec) {
     . . .
 }
```

### Autothreading

Junctions 是无序的， `1|2|3` 和 `3|2|1` 代表相同的值。没有顺序意味着 Perl 6 编译器能并行地选择计算 junctive 表达式。例如， 代码：

``` perl
 if $string ~~ all(@list_of_regexes) {
     . . .
 }
```

将会对编译器表明， 字符串和一组正则表达式的所有匹配能被并发地被执行， 可能在单独的线程中。这个功能被授予 `autothreading`. autothreading 的并行化尚未在任一编译器中实现。

### 宏

Perl 6 会利用 Lisp-like 的宏概念。 这种宏的强大源自这样的事实， 它像高级数据结构一样操作程序， 而非像普通的文本那样。

Perl 6 中宏的定义很像子例程或方法定义， 能作用在未解析的字符串上、AST 那样预解析的代码、或两者的组合。 一个宏定义就像这样：

``` perl
 macro hello($what) {
   quasi { say "Hello { {{{$what}}} }" };
 }
```

### Examples

Hello World

``` perl
say 'Hello, world';
```

### 快速排序

一个使用函数式编程范式的有效实现能使用 Perl 6 简洁地写出：

``` perl
 # Empty list sorts to the empty list
 multi quicksort([]) { () }

 # Otherwise, extract first item as pivot...
 multi quicksort([$pivot, *@rest]) {
     # Partition.
     my @before = @rest.grep(* < $pivot);
     my @after  = @rest.grep(* >= $pivot);

     # Sort the partitions.
     (quicksort(@before), $pivot, quicksort(@after))
 }
```

### 汉诺塔

在计算机科学上汉诺塔通常用于介绍递归编程。这个实现使用 Perl 6 的多重分派机制和参数限制：

``` perl
multi sub hanoi(0, $, $, $) { }                         # No disk, so do not do anything
multi sub hanoi($n, $a = 'A', $b = 'B', $c = 'C') {     # Start with $n disks and three pegs A, B, C
     hanoi $n - 1, $a, $c, $b;                          # firstly move top $n - 1 disks from A to B
     say "Move disk $n from peg $a to peg $c";          # then move last disk from A to C
     hanoi $n - 1, $b, $a, $c;                          # lastly move $n - 1 disks from B to C
 }
```
