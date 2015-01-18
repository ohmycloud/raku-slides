Perl6 vs Perl5 之我见Perl6 相对于 Perl5 做了革命性的改革，拥有丰富的语言特征、支持多线程、正则表达式更加灵活，而且仍然坚持 Perl 一贯理念：实用实用更实用。本篇文章将抽取一些 Perl6 中相对 Perl5 的增强部分，从主要的基本语法，结构方面对比 Perl6 和 Perl5，并给出实例，让您更好地理解 Perl6。正则表达部分内容庞大，故不在本文介绍范围内。
 评论：
代 文娟, 软件工程师, IBM


代文娟，IBM 西安实验室的软件工程师，来自 Analytic Decision Management 部门,专注于 SPSS Analytic Decision Management 产品的核心功能测试以自动化测试。






2013 年 11 月 18 日
+内容
前言 
Perl6 诞生 
START 
变量和类型 
类型 
操作符 
控制结构 
函数 
类 
小结 
参考资料 评论
前言


--------------------------------------------------------------------------------


Perl6 诞生
2000 年 7 月 19 号，在一场无聊沉闷的政治组织会议中，Jon Orwant 站在一边听了几分钟，然后很淡定的走向咖啡桌，拿起一个个杯子往对面的墙上扔去，边扔边说"我们得想办法激励社群，不然都完了，大家越来越无聊，都去做别的事了。我不管您们怎么做，可您们得搞些大事出来。"，然后他掉头就走，这场事件，触发了 Perl6 诞生的火苗。经过十年的磨砺，2010 年 7 月 29 号，Perl6 的第一个实现版 Rakudo Star 终于发布了，这头曾经背负重担的骆驼轻装上路了。


Perl5 是用 C 写的核心，虽然已经很成熟，但核心代码太庞大，充满了各种难以理解的调用，且对多线程、unicode 的支持并不好， Perl6 相对 Perl5 做出了革命性的变革，除了更完美的支持线程、unicode 之外，可靠信号控制在一开始设计的时候就已经被加进去，新的内核更小、速度更快、外部扩展 API 更加清晰，在过去的二进制兼容问题也会被彻底解决掉。




--------------------------------------------------------------------------------


START
安装 Perl6,可以从以下网址下载 http://rakudo.org/how-to-get-rakudo/， 安装步骤如下：


安装 Perl6
$ cd rakudo
$ perl Configure.pl --gen-parrot --gen-nqp
$ make
$ make install参数–gen-parrot 实际上是在调用 svn 或 git 生成合适的 Parrot 才能编译它，Parrot 是 Perl6 相关计划书中支援 Perl6 的 Virtual Machine，也就是说， Perl 程序将在 Parrot 上执行，程序所面对的是个共通的跨平台 Virtual Machine 环境，而不用考虑您所面对的 OS 环境，就像 Java、.NET 所使用的 VM 一样。参数-gen-nqp 会下载一份 NQP，NQP 是一个小型的 Perl6 编译器，用来构建 Rakudo，Rakudo 是用于 Parrot 虚拟机上的编译器。


安装完之后，进入安装目录，并运行./Perl6，当您在 $ 后面见到 > 时，您就进入了 Rakudo 的环境中，可以执行一些东西见到 Rakudo 的响应，如：


运行 Perl6
$./perl6
>say "Hello world!";
>Hello world!而在 Perl5 中，运行./perl 后直接停留在当前状态，不会进入用户交互状态。




--------------------------------------------------------------------------------


变量和类型
数组
Perl6 对数组和哈希的定义 无需括号 ，如:


Perl6 中数组定义
@a = "hello", "world";
say @a;


输出：


hello world


这里，say 函数是 Perl6 中新引入的一个函数，功能就是将一行文本打印到终端。


Hash
在 Perl6 中对哈希值的访问，键值如果用 双引号 则需用 {} , 如果 不用双引号 ，则需用 <> , 如：


Perl6 中 Hash 定义
my %a = "first" => 1, "second" => 2, "third" => 3;
say  %a {"first"} ;
say  %a <second> 输出：


1
2


如果不使用=>符号定义 hash，还可以使用副词语法，如下：


副词语法
my %bar = :first(1), :second(2), :third(3);


副词语法提供了为数值命名，在 Perl6 中不仅仅用在 hash，很多地方都会用。




--------------------------------------------------------------------------------


类型
在 Perl 5 中，$scalar 的标量只能包含二种东西引用或值，这值可以是任何东西，可以是整数、字符、数字、日期和您的名字，这通常是非常方便的，但并不明确。在 Perl6 中给您机会修改标量的类型 。如果您这个值比较特别，您可以直接放个类型名在 my 和 $variable 的中间。像下面的例子，是在设置值一定要是一个 Int 型的数据，来节约 cpu 判断类型的时间，和让您更少在程序上出错。


my Int $days = 24;


Perl6 提供了很多内置数据类型，最基础的有：


Bool : 布尔值，是枚举类型，只能是 true 或者 false。Int: 整数型。Array: 数组类型，通过整数索引。Hash: 哈希类型，通过字符串名索引。Num: 浮点数值。Complex: 复杂数据类型，如虚数。Pair: 将字符串名和数据对象的绑定。Str: 字符串数据对象。我们可以通过 WHAT 函数来判断数据的类型，如：


WHAT 函数
my $a=3; 
say $a.WHAT


输出：


Int()此外，我们还可以通过一些特殊操作符对数据类型进行转换，如：


数据类型转换
my $num = +("3");  //+()将字符转换为数值
my @arr = @("key" => "value");   //@()将 hash 转换为数组 ？
my $sca = $(2..4) ;//$()将列表转换为标量，这里 sca 为列表元素个数 3  ？
my $str = ~3; //~()将数值转换为字符
my %hash = %("a","1","b","2");//%()将列表转换为哈希
--------------------------------------------------------------------------------


操作符
拼接
Perl6 中使用~进行字符串的拼接，如：


字符串拼接
my Int $num = 5;
my Str $str = "I have " ~ $foo ~ " chapters to write";
say $str; //这里~会将 5 转换为 string 再拼接输出：


I have 5 chapters to write


匹配
Perl6 的字符串匹配使用~~，如：


字符串匹配
"c" ~~ /c/;     # 返回 true, 字符"c" 匹配正则表达式/c/
--------------------------------------------------------------------------------




控制结构
格式
Perl6 中的控制符关键字后必须有空格，否则会被解析为函数 ，如：


控制体格式
if($x<5) {    //错误，会调用 if 函数
}
if ( $x <5) {  //正确
}


given/when
Perl6 引入新的控制体 Given/When，它类似 c 语言中的 switch/case,如：


given/when 用法
given $guess {
when 10 { say ‘$guess is the number 10’; }
when "hello" { say ‘$guess is the string "hello"’; }
when Bool { say ‘$guess is the _oolean quantity ‘ ~ $guess; }
}
以上的代码会将 guess 变量先匹配 10，如果不是，再匹配"hello",最后判断是否是布尔类型。


for /loop
在 Perl 5 中，提供了 foreach 的关键字，当然您也能写成 for 的关键字来实现象 C 风格的循环。在 Perl 6 中，这些全都改变了。现在 for 是专用来进行列表的迭代。foreach 就不再使用了，如：


for 用法
for 1, 2, 3, 4 { .say }
这是一个最简单清晰的语法的例子。在这 并没有使用括号来包起整个列表的语句，像这种写法可以贯穿整个 Perl 6 .。通常比起 Perl 5 来您没有必要写那么多的括号了。这个循环中的值会默认存到 $_ 。在这个方法调用的 say 其实就是 $_.say，注意在 Perl 6 中，您不能直接只打一个 say 的调用而不加参数，默认情况下会使用 $_ 来传参，您需要使用 .say ，要么明确的指定是 $_。


而那个 C 风格的循环处理使用了新的关键字 loop，如：


loop 用法
loop (my $i = 1; $i<= 10; $i++) {
print $i;
}


repeat/while
Perl6 引入了 repeat/while 控制体，相当于 c 语言中的 do/while，如：


repeat/while 用法
My $n = 3;
repeat {
say $n;
} while $n <3;


以上代码会执行循环体一次。




--------------------------------------------------------------------------------


函数
定义
Perl6 在定义函数时，显示了参数，这是非常灵活的。因为它不会对参数做任何默认的处理，程序会全部传给您来进行处理，并增加返回值关键字 return,，这点更像 c 语言定义函数，如：


函数定义
sub mysub ( $x ) {
     My $y = $x/2;
      Return $y;
}


除此之外，还 允许定义可选参数及参数默认值 ，对于 可选参数 需要在参数后加 ? ， 对于定义 参数默认值 则直接在参数后直接加 = default value ，如：


参数设置
sub mysub($first, $second? , $third = 4 );


这里参数$second 是可选参数， 默认值为 undef ，而参数$third 是必填参数，且默认值为 4。


重载
Perl 6 还允许定义相同名字的函数，但需要参数不同，并需要加上 multi 关键字 ，如：


函数重载
multi sub double( Int $x) {
my $y = $x * 2;
say "Doubling an Integer $x: $y";
return $x * 2;
}
 
multi sub double( Num $x) {
my $y = $x * 2;
say "Doubling a Number $x: $y";
return $x * 2;
}
 
my $foo = double(5);        # Doubling an Integer 5: 10
my $bar = double(3.5);      # Doubling a Number 3.5: 7


块和闭包
在 Perl5 中，想要访问不同范围内的变量，只能通过 my、our、local 来定义变量的作用范围，而 Perl6 通过增加 $OUTER 和 $CALLER 使访问变量更加灵活，这里对于一个代码块来说使用$OUTER 找到上一层范围同名的变量， 如：


$OUTER 使用
my $x = 5;
{
   my $x = 6;
   say $x;           # 6
   say $OUTER::x    # 5
}


对于 函数 来说，使用的是$CALLER 来找到对应的变量，如：


$CALLER 使用
my $x = 5;
my_Subroutine(7);
 
sub my_Subroutine($x) {
   say $x;         # 7
   say $CALLER::x; # 5
}
--------------------------------------------------------------------------------


类
定义
Perl6 拥有了真正概念上的类和对象，公有变量可以使用符号，私有变量使用符号 ! ， 并将以前的方法调用符 -> 变为 .     如：


类定义
class MyClass {
        has $!private;
        has @.public;


        # and with write accessor
        has $.stuff is rw;


        method bark {
            if self.can(‘bark’) {
                say "Something doggy";
            }
        }
}


以上代码中，使用一个 class 的关键字定义类。如果您有学过 Perl5 的话，您能想到这有点像包(package)的变种。接下来，使用 has 的关键字来声明属性访问器方法。 这个"."的东西名叫 twigil 。Twigil 是用来告诉您 指定变量的作用域 。它是"属性 + 存取方法"的组合。接下来是方法的使用，并介绍使用 method 的关键字。在对象中的方法像包中的子函数，不同之处在于方法是放在类的方法列表的条目中。它还能自动取得调用者(invocant)，所以您如果没有在参数列表中加入参数，它是会给自我传递过去，在 Perl 5 中需要我们显示的写 $self = shift。


对于以前在 Perl5 中使用的大部分函数都已经转换为方法，如得到字符串长度,调用 chars 方法：My $len = $string.chars 和排序数组，调用 sort 方法：Print @array.sort ;


构造函数
Perl5 的构造函数是类的子程序，它返回与类名相关的一个引用，将类名与引用相结合称为 bless 一个对象。Perl6 所有的类都使用名叫 new 的默认的构造器，它会自动的映射命名参数到属性，所有传进的参数会存到属性中，如：


构造函数
my $comer = family. new (name => 'Jack', age=>23); 
say $fido.name;  # Jack继承
Perl6 的继承直接使用 is+父类名就可以，如：


继承
class MySubClass is MyClass {
        method bark {
                say "Something wow!";
        }
}






小结

我们将以上内容总结对比为如下表： Perl6 与 Perl5 对比一览表 类别 Perl6 Perl5
 命令运行 支持交互 不支持交互
 数组定义 @a = “hello”, “world”; @a = (“hello”, “world”;)
 哈希定义 %a = “first” => 1, “second” => 2; or
 %a = :first(1),:second(2); %a = (“first” => 1, “second” => 2);
 哈希访问 %a{“first”} or %a<first> $a{“first”}
 字符拼接 “hello “ ~ “ world” “hello”.”world”
 匹配 “c” ~~/c/ “c” =~/c/
 数据类型 Bool, Array, Int, Num, Pair,Complex, Str 等 Scalar, Array, Hash
 控制结构 given/when 无
 for foreach
 loop for
 repeat/while while
 函数重载 参数不同，并需要加上 multi 关键字 无
 变量作用域 my, our, local, $OUTER, $CALLER my , our, local
 类定义 使用 class，支持公有变量和私有变量 使用 package
 构造函数 new() 引用＋bless()
 方法调用 使用. 使用->
 继承 is 父类名（使用的是 class） use 父类名（使用的是 package）
总结

本文从 Perl6 的诞生来由讲起，从变量、类型、操作符、控制结构、函数、类六个方面介绍了 Perl6 的改进，并给出实例，最后总结对比在 Perl5 中的差异点的使用方法。从这些改进中，可以看出 Perl6 在字符处理方面更加轻便、灵活，且从结构上成为真正意义上的面向对象语言。

来源： < Perl6 vs Perl5 之我见 >  
