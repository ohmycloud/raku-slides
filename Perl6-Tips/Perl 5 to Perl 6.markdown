Perl 5 to Perl 6



ROADMAP

Already written or in preparation:
    00 介绍
    01  字符串、数组、散列
    02  类型
    03 控制结构
    04  子例程和签名
    05  对象和类
    06 上下文
    07 Rules 
    08 分支
    09  比较和智能匹配
    10   容器和绑定
    11  基本操作符
    12懒惰
    13  常规操作符
    14  MAIN子例程
    15 Twigils
    16 Enums 
    17 Unicode (-)
    18 Scoping作用域
    19 More Regexes 更多正则
    20 A Grammar for XML 
    21 Subset types 子集类型
    22 State of the Implementations
    23 Quoting and Parsing (-)
    24 Recude meta operator
    25 Cross meta operator
    26 Exceptions and control exceptions

(Things that are not or mostly not implemented in Rakudo are marked with (-) )

Things that I want to write about, but which I don't know well enough yet:
    Macros
    Meta Object Programming
    Concurrency
    IO

Things that I want to mention somewhere, but don't know where
    .perl method

I'll also update these lessons from time to time make sure they are not too outdated. AUTHOR

Moritz Lenz, http://perlgeek.de/ , moritz@faui2k3.org LINKS

Other documentation efforts can be found on http://perl6.org/documentation/ . 字符串，数组，散列

Sat Sep 20 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 01 - Strings, Arrays, Hashes; 概要
    my $five = 5;
    print "an interpolating string, just like in perl $five\n";
    say 'say() adds a newline to the output, just like in perl 5.10';
 
    my @array = 1, 2, 3, 'foo';
    my $sum = @array[0] + @array[1];
    if $sum > @array[2] {
        say "not executed";
    }
    my $number_of_elems = @array.elems;     # or +@array
    my $last_item = @array[ * -1]; # foo


     my $all_item = @array[ * ]; #   1 2 3 foo
  
    my $second_last_item = @array[ *-2 ]; # 3
    



>  my @last_item = @array[1,2,3];  # 数组切片
2 3 foo
>  my @last_item = @array[*,1,2,3];
1 2 3 foo 2 3 foo
>  my @last_item = @array[*,1,2,3,*-1];
1 2 3 foo 2 3 foo foo
>  my @last_item = @array[*,0,1,2,*-1];
1 2 3 foo 1 2 3 foo


    my %hash = foo => 1, bar => 2, baz => 3;
    say %hash{'bar'};                       # 2
    say %hash<bar>;                         # same with auto-quoting
    # 这是个错误: %hash{bar}
    # 它尝试调用尚未定义过的子例程 bar() DESCRIPTION

代码块中最后的分号是可选的 Strings字符串

插值的规则改变了一些，下面的东西会被插值：
    my $scalar = 6;
    my @array = 1, 2, 3;
    say "Perl $scalar";             # 'Perl 6'
    say "An @array[]";            # 'An 1 2 3', a so-called "Zen slice" 或 @array[*]
    say "@array[1]";                # '2'
    say "Code: { $scalar * 2 } " # 'Code: 12'

如果数组和散列后面跟着 索引 ，它们才会被插值。或者以圆括号结尾的方法调用 像$obj.method()， 空索引 会插值 整个 数据结构。

花括号中的代码块会作为代码执行，其结果会被插值。 数组

数组仍然使用@符号，当数组后面跟着索引，@a[…]是读取其存储的 项
    my @a = 5, 1, 2;            # 括号不再需要
    say @a[0];                     # 是的，项以@开始
    say @a[0, 2];                 # 切片仍然有效

列表使用逗号操作符构建

  1, is a list, (1) isn't.

因为任何东西都是对象，你可以在数组上调用方法：
    my @b = @a.sort;
     my @b = @a .sort.reverse         #  5 2 1
    @b.elems;                                # 项的数量
    if @b > 2 { say "yes" }             # 仍然有效
    @b.end;                                  # 最后一个索引的数值  代替  $#array
    my @c = @b.map({$_ * 2 });  # map也是一个方法

旧的引起结构qw/…/有一种简写形式：
    my @methods = < shift unshift push pop end delete sort map > ; 散列

Perl5的散列在列表上下文下是偶数列表，Perl6的散列在 列表 上下文中是键值对的列表。键值对儿也用于其他地方，像子例程的 具名参数 。

读取散列中的 项 和数组类似，也可以在散列上调用方法：
    my %drinks =
        France  => 'Wine',
        Bavaria => 'Beer',
        USA     => 'Coke';
 
    say "The people in France love ",  %drinks{'France'};
    my @countries = %drinks .keys.sort ;

注意，当你使用%hash{…}读取散列中的元素时，键不会像Perl5中那样被自动引起。所以 %hash{foo}不会访问索引 ＂foo＂，而是 调用了函数 foo() ,自动引起并没有消失，它只是有不同的语法：
    say %drinks<Bavaria> ; 最后的忠告

大部分内建方法都存在着方法和子例程两种形式。所以你既可以写 sort @array 也可以写 @array.sort

最后，你应该知道[ .. ]和{ . . .｝（直接出现在项的后面)就是使用特殊语法的方法调用，而不是绑定到数组和散列上的某个东西。那意味着它们没有绑定到特殊的符号上。
    my $a = [1, 2, 3];
    say $a[2];          # 3

这表明你不需要特别的解引用语法，并且同时你可以创建行为像数组、散列和子例程那样的对象。 SEE ALSO

http://perlcabal.org/syn/S02.html , http://perlcabal.org/syn/S29.html 类型

Sat Sep 20 22:40:00 2008 NAME

"Perl 5 to 6" Lesson 02 - Types 概要
    my Int $x = 3;
    $x = "foo";             # 错误，$x只能存储整数
    say $x.WHAT;        # 'Int()'
 
    # 检查类型：
    if $x ~~ Int {
        say '$x contains an Int'
    } DESCRIPTION

Perl6拥有类型。某种程度上，所有东西都是对象，并拥有一种类型。变量可以有类型常量, 但是它们没必要拥有类型

有一些你应该知道的基本类型
    'a string'      # 字符串
    2                  # 整数
    3.14             # 有理数
    (1, 2, 3)        # 序列




>   (1, 2, 3).WHAT()
(Parcel)
>   [1, 2, 3].WHAT()
(Array)
>   <1, 2, 3>.WHAT()
(Parcel)
>   {1, 2, 3}.WHAT()
(Block)



所有正常的内置类型都以一个 大写字母开头 。所有普通类型从Any继承，并且所有东西都是从Mu继承的。

你可以通过给声明添加一个类型名来 限制 变量能保存的值的类型：
    my Numeric $x = 3.4;
    my Int @a = 1, 2, 3;

把值存进“错误”的类型中会报错(例如，既不是指定的类型，也不是子类型)

作用在数组上的类型声明将类型应用到 数组的内容 上，所以，my Str @s申明了一个只能包含字符串的数组。

有些类型代表更特别类型的整个家族，例如整数（Int型），有理数（有理数型）和浮点型数字（数值型）都符合 Numeric  类型。 内省

调用  .WHAT  方法可以知道一个东西的类型
    say "foo".WHAT;     # Str()

然而，你想检查某个东西是否是指定的类型，有不同的方法，它把继承也考虑进去了，因此值得推荐
    i f $x ~~ Int {
        say 'Variable $x contains an integer';
    } MOTIVATION

The type system isn't very easy to grok in all its details, but there are good reasons why we need types:我们需要类型的原因 Programming safety编程安全

If you declare something to be of a particular type, you can be sure that you can perform certain operations on it. No need to check. Optimizability优化

When you have type informations at compile time, you can perform certain optimizations. Perl 6 doesn't have to be slower than C, in principle. Extensibility扩展

With type informations and multiple dispatch you can easily refine operators for particular types. SEE ALSO

http://perlcabal.org/syn/S02.html#Built-In_Data_Types , 基本控制结构

Sat Sep 20 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 03 - Basic Control Structures 概要
    if $percent > 100   {     # 条件 不再需要圆括号
        say "weird mathematics";
    }
    for 1..3 {
        # 使用 $_ 作为循环变量
        say 2 * $_;
    }
    for 1..3 -> $x {
        # 使用显示的循环变量
        say 2 * $x;
    }
 
    while $stuff.is_wrong {
        $stuff.try_to_make_right;
    }
 
    die "Access denied" unless $password eq "Secret"; DESCRIPTION

在 if ， while，for 等后面不再需要圆括号！

实际上不鼓励在条件周围使用圆括号，原因是 任何后面 紧跟（没有空白格）着开放圆括号的标识符都会被解析为子例程调用 。所以， if( $x < 3 ) 会尝试调用一个叫 if 的 函数 ，然而，if 后面跟着一个 空格 就修复这个问题了，不过省略圆括号更安全。 分支

if 大部分没变，你仍可以添加elsif 和 else分支。 unless仍然还在，但是后面不允许跟 else分支了 。
    my $sheep = 42;
    if $sheep == 0 {
        say "How boring";
    } elsif $sheep == 1 {
        say "One lonely sheep";
    } else {
        say "A herd, how lovely!";
    }

你也能将 if 和 unless用作语句修饰符，例如，在一个语句后面：
    say "you won" if $answer == 42; 循环

你可以像在Perl5中那样使用 next和 last操作循环。

for 循环现在只用来遍历列表。默认使用 $_ 作为topic 变量，除非显示地指定了循环变量。
    for 1..10 -> $x {
        say $x;
    }

  -> $x { ... }  叫做所谓的 "pointy block" ，那是一种像匿名散列的东西。

你也可以使用多个循环变量:
    for 0..5 -> $even, $odd {
        say "Even: $even \t Odd: $odd";
    }

这是一种遍历散列的好方法：
    my %h = a => 1, b => 2, c => 3;
    for %h.kv -> $key, $value {
        say "$key: $value";
    }

C风格的for循环现在叫做 loop(仅有的需要圆括号的循环结构)
    loop (my $x = 2; $x < 100; $x = $x**2) {
        say $x;
    } SEE ALSO

http://perlcabal.org/syn/S04.html#Conditional_statements 子例程和签名

Sat Sep 20 23:20:00 2008 NAME

"Perl 5 to 6" Lesson 04 - Subroutines and Signatures 概要
    # 不含签名的子例程 - perl 5 like
    sub print_arguments {
        say "Arguments:";
        for @_ {
            say "\t$_";
        }
    }
 
    # 使用固定数量和类型的签名：
    sub distance( Int $x1, Int $y1, Int $x2, Int $y2) {
        return sqrt ($x2-$x1) ** 2 + ($y2-$y1) ** 2;
    }
    say distance(3, 5, 0, 1);
 
    # 默认参数
    sub logarithm($num, $base = 2.7183 ) {
        return log($num) / log($base)
    }
    say logarithm(4);       # 第二个参数使用默认值 
    say logarithm(4, 2);    # 显式地指定第二个参数    
 
    # 具名参数
 
    sub doit( :$when , :$what ) {
        say "doing $what at $when";
    }
    doit(  what => 'stuff', when => 'once' );  # 'doing stuff at once'
    doit(  :when<noon>, :what('more stuff')  ); # 'doing more stuff at noon'
    # illegal: doit("stuff", "now") DESCRIPTION

参数可以含有类型限制

参数默认是只读的。  那能使用所谓的 “特征” 改变：
    sub try-to-reset($bar) {
        $bar = 2;       # forbidden
    }
 
    my $x = 2;
    sub reset($bar is rw ) {
        $bar = 0;         # allowed
    }
    reset($x); say $x;    # 0
 
    sub quox($bar is copy ){   # 不明白这里copy的用法
        $bar = 3;
    }
    quox($x); # 3
    say $x    # still 0

通过在参数后面添加一个问号？，可以让参数变成可选的。或提供一个默认值
    sub foo($x, $y? ) {  # 可选参数
        if $y .defined {
            say "Second parameter was supplied and defined";
        }
    }
 
    sub bar($x, $y = 2 * $x) {
        ...
    }  具名参数

当你像这样    my_sub($first, $second)  引用一个子例程时，$first参数绑定到前面的第一个参数，$second参数绑定给后面的第二个参数，这就是它们被叫做位置参数的原因。

有时候，名字比数值更容易记住，这就是Perl6为什么拥有具名参数：
    my $r = Rectangle .new (
            x       => 100,
            y       => 200,
            height => 23,
            width  => 42,
            color  => 'black'
    );

为了定义一个具名参数，你仅需要在签名列表里把冒号 : 放在参数之前
    sub area( :$width , :$height ) {
        return $width * $height;
    }
    area(width => 2,  height => 3);
    area(height => 3, width => 2 ); # the same
    area( :height(3), :width(2) );    # the same

最后的例子使用了所谓的冒号对语法，
    :draw-perimeter                 # same as "draw-perimeter => True"
    :!transparent                      # same as "transparent => False"

在具名变量的申明中，变量的名字也被用作参数的名字。然而，你可以使用不一样的名字
    sub area(:width($w), :height($h)){
        return $w * $h;
    }
    area(width => 2,  height => 3); Slurpy 参数

你可以定义所谓的 slurp参数(在所有普通参数后面)，它会用光剩下的任何参数：
    sub tail ($first, * @rest){
        say "First: $first";
        say "Rest: @rest[]";
    }
    tail(1, 2, 3, 4);           # "First: 1\nRest: 2 3 4\n"

具名的slurp参数是通过在 散列 前面添加一个 星号 来声明的：
    sub order-meal($name, * % extras) {  # 剩余的参数全部存在散列 %extras 里面，名字作为键。
        say "I'd like some $name, but with a few modifications:";
        say %extras .keys .join(', ');  # 只有键，键值为undef
    }
 
    order-meal('beef steak', : vegetarian , : well-done );


# I'd like some beef steak, but with a few modifications:
# vegetarian, well-done


>   order-meal('beef steak', :vegetarian, :well-done, :jiaozi, :nice, :rice, :good);


# I'd like some beef steak, but with a few modifications:
# vegetarian, well-done, jiaozi, nice, rice, good 插值

数组默认不会在 参数列表 中被插值，所以Perl6中你可以这样写：
    sub a( $scalar1 , @list, $scalar2 ) { # @list 不会吃光剩下所有的参数
        say $scalar2;
    }
 
    my @list = "foo", "bar";
    a(1, @list, 2);                  # 2

这也意味着，默认你不能将列表用于参数列表：
    my @indexes = 1, 4;
    say "abc" .substr (@indexes)       # 做不到你想要的

真正发生的是，第一个参数应该是一个整数，并且强制为一个整数。就像你这样写一样   "abc" . substr( @indexes.elems )

    你可以使用前缀  | 达到你想要的行为
    say "abcdefgh".substr( | @indexes ) # bcde,与 "abcdefgh".substr(1, 4) 一样 Multi Subs

你真的可以使用同一个名字（但带有不同参数列表）定义 mutiple subs：
    multi sub my_substr($str) { ... }                          # 1
    multi sub my_substr($str, $start ) { ... }                  # 2
    multi sub my_substr($str, $start, $end ) { ... }            # 3
    multi sub my_substr($str, $start, $end, $subst ) { ... }    # 4

现在，不管你什么时候调用一个子例程，能匹配上述参数列表的子例程会被选中执行。

multis 不仅可以在量上不同（例如参数数量），还可以是不同的参数类型：
    multi sub frob( Str $s) { say "Frobbing String $s"  }
    multi sub frob( Int $i) { say "Frobbing Integer $i" }
 
    frob("x");      # Frobbing String x
    frob(2);        # Frobbing Integer 2 MOTIVATION



没有人会怀疑显式的子例程签名的有用性：打字更 少 ，重复的参数检查更少，代码自行记录更多。命名参数的值也已经讨论过。

它还允许有用的自省。例如，当你传递一个块或子例程给 Array.Sort ，而那一段代码只需要一个参数，它会 自动为您完成   一个Schwartzian转换（见http://en.wikipedia.org/wiki/Schwartzian_transform ）- 这样的功能在Perl 5中是 不可能的 ，由于缺乏显式的签名，这意味着 sort 永远不知道代码块需要多少个参数。

多重分派是非常有用的，因为它们允许使用新类型重写内置函数。让我们假设你想有一个版本的Perl 6，一种本地化的能正确处理土耳其字符串的 Perl 6，这对大小写转换有着不同寻常的规则。

你可以只介绍一种新类型 TurkishStr ，并为内置函数添加多重分派， 而不是修改语言：




       multi uc(TurkishStr $s) { ... }

现在，所有你需要做的就是让你的字符串类型跟他们的语言相关，那么你可以像正常的内置函数一样使用 uc 了。

由于操作符也是子例程，这些改进对于操作符也有效。

SEE ALSO

http://perlcabal.org/syn/S06.html 对象和类

Tue Sep 23 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 05 - Objects and Classes 概要
    class Shape {
        method area { ... }    # literal '...'
        has $.colour is rw;
    }
 
    class Rectangle is Shape {
        has $.width;
        has $.height;
 
        method area {
            $!width * $!height;
        }
    }
 
    my $x = Rectangle.new(
            width   => 30.0,
            height  => 20.0,
            colour  => 'black',
        );
    say $x.area;                # 600
    say $x.colour;              # black
    $x.colour = 'blue'; DESCRIPTION

Perl 6 has an object model that is much more fleshed out than the Perl 5 one. It has keywords for creating classes, roles, attributes and methods, and has encapsulated private attributes and methods. In fact it's much closer to the Moose Perl 5 module (which was inspired by the Perl 6 object system).

There are two ways to declare classes
    class ClassName;
    # class definition goes here

The first one begins with class ClassName; and stretches to the end of the file. In the second one the class name is followed by a block, and all that is inside the block is considered to be the class definition.
    class YourClass {
        # class definition goes here
    }
    # more classes or other code here Methods

Methods are declared with the method keyword. Inside the method you can use the term self to refer to the object on which the method is called (the invocant ).

You can also give the invocant a different name by adding a first parameter to the signature list and append a colon : to it.

Public methods can be called with the syntax $object.method if it takes no arguments, and $object.method(@args) or $object.method: @args if it takes arguments.
    class SomeClass {
        # these two methods do nothing but return the invocant
        method foo {
            return self;
        }
        method bar(SomeClass $s: ) {
            return $s;
        }
    }
    my SomeClass $x .= new;
    $x.foo.bar                      # same as $x

(The my SomeClass $x .= new is actually a shorthand for my SomeClass $x = SomeClass.new . It works because the type declaration fills the variable with a "typo object" of SomeClass , which is an object representing the class.)

Methods can also take additional arguments just like subs.

Private methods can be declared with method !methodname , and called with self!method_name .
    class Foo {
        method !private($frob) {
            return "Frobbed $frob";
        }
 
        method public {
            say self!private("foo");
        }
    }

Private methods can't be called from outside the class. Attributes

Attributes are declared with the has keyword, and have a "twigil", that is a special character after the sigil. For private attributes that's a bang ! , for public attributes it's the dot . . Public attributes are just private attributes with a public accessor. So if you want to modify the attribute, you need to use the ! sigil to access the actual attribute, and not the accessor (unless the accessor is marked is rw ).
    class SomeClass {
        has $!a;
        has $.b;
        has $.c is rw;
 
        method set_stuff {
            $!a = 1;    # ok, writing to attribute from within the clas
            $!b = 2;    # same
            $.b = 3;    # ERROR, can't write to ro-accessor
        }
 
        method do_stuff {
            # you can use the private name instead of the public one
            # $!b and $.b are really the same thing
            return $!a + $!b + $!c;
        }
    }
    my $x = SomeClass.new;
    say $x.a;       # ERROR!
    say $x.b;       # ok
    $x.b = 2;       # ERROR!
    $x.c = 3;       # ok Inheritance

Inheritance is done through an is trait.
    class Foo is Bar {
        # class Foo inherits from class Bar
        ...
    }

All the usual inheritance rules apply - methods are first looked up on the direct type, and if that fails, on the parent class (recursively). Likewise the type of a child class is conforming to that of a parent class:
        class Bar { }
        class Foo is Bar { }
        my Bar $x = Foo.new();   # ok, since Foo ~~ Bar

In this example the type of $x is Bar , and it is allowed to assign an object of type Foo to it, because "every Foo is a Bar ".

Classes can inherit from multiple other classes:
    class ArrayHash is Hash is Array {
        ...
    }

Though multiple inheritance also comes with multiple problems, and people usually advise against it. Roles are often a safer choice. Roles and Composition

In general the world isn't hierarchical, and thus sometimes it's hard to press everything into an inheritance hierarchy. Which is one of the reasons why Perl 6 has Roles. Roles are quite similar to classes, except you can't create objects directly from them, and that composition of multiple roles with the same method names generate conflicts, instead of silently resolving to one of them, like multiple inheritance does.

While classes are intended primarily for type conformance, roles are the primary means for code reuse in Perl 6.
    role Paintable {
        has $.colour is rw;
        method paint { ... }
    }
    class Shape {
        method area { ... }
    }
 
    class Rectangle is Shape does Paintable {
        has $.width;
        has $.height;
        method area {
            $!width * $!height;
        }
        method paint() {
            for 1..$.height {
                say 'x' x $.width;
            }
        }
    }
 
    Rectangle.new(width => 8, height => 3).paint; SEE ALSO

http://perlcabal.org/syn/S12.html http://perlcabal.org/syn/S14.html http://www.jnthn.net/papers/2009-yapc-eu-roles-slides.pdf http://en.wikipedia.org/wiki/Perl_6#Roles 上下文

Wed Sep 24 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 06 - Contexts 概要
    my @a = <a b c>;
    my $x = @a;
    say $x[2];          # c
    say (~2).WHAT;      # (Str)
    say +@a;                 # 3
    if @a < 10 { say "short array"; } DESCRIPTION

当你写一些像这样的东西时：
    $x = @a

在 Per5 中 $x没有 @a 包含的信息多，它只包含数组@a中项的个数。要保留所有的信息，你必须显示地使用一个引用 :$x = \@a. 在Perl6中确是相反的，默认地，你不会失去任何东西，可以 用标量存储着数组 。通过引入普通的项上下文（在Perl 5中叫做标量上下文）和更特殊的数字、整数和字符串上下文能让这变得可能。空上下文和列表上下文保持不变。

你能够使用特殊的语法强制某种上下文
    语法         上下文
 
    ~stuff       字符串
    ?stuff       布尔 (逻辑的)
    +stuff       数字
    -stuff       数字(并且是负的)
    $( stuff )   普通的项上下文
    @( stuff )   列表上下文
    %( stuff )   散列上下文
     stuff.tree  树上下文 树上下文

在早期的Perl 6 中，存在着 很多 两种版本的内置函数，一种函数返回一个展开的列表，一种函数返回数组列表。现在 通过返回一个 Parcel 对象列表， 这个问题被解决了，根据上下文，Parcel 对象可能会被展开，也可能不展开。看看中缀操作符 Z（zip的缩写），它从两个列表中交替取出元素：
    my @a = <a b c> Z <1 2 3>;
    say @a.join;                # a1b2c3

这里发生的情况是，第一条语句的右边返回了  ('a', 1), ('b', 2), ('c', 3) , 并赋值给一个数组，这儿提供了 列表 上下文，所以展开了内部的 块 。另一方面，如果你这样写：
    my @t = (<a b c> Z <1 2 3>).tree;
    say +@t;  # 3

那么 @t 现在包含 3 个元素 ，每个元素都是 没有展开的数组 。
    for @t -> @inner {
        say "first: @inner[0]  second: @inner[1]"
    }

Produces the output
    first: a  second: 1
    first: b  second: 2
    first: c  second: 3 SEE ALSO

http://perlcabal.org/syn/S02.html#Context http://perlgeek.de/blog-en/perl-6/immutable-sigils-and-context.html 正则 (also called "rules")

Thu Sep 25 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 07 - Regexes (also called "rules") 概要
    grammar URL {
        token TOP {
            <schema> '://'
            [<ip> | <hostname> ]
            [ ':' <port>]?
            '/' <path>?
        }
        token byte {
            (\d**1..3) <? { $0 < 256 } >
        }
        token ip {
            <byte> [\. <byte> ] ** 3
        }
        token schema {
            \w+
        }
        token hostname {
            (\w+) ( \. \w+ )*
        }
        token port {
            \d+
        }
        token path {
            <[ a..z A..Z 0..9 \-_.!~*'():@&=+$,/ ]>+
        }
    }
 
    my $match = URL.parse('http://perl6.org/documentation/');
    say $match<hostname>;       # perl6.org DESCRIPTION

我们不再叫它正则表达式了。 因为他们比Perl5中的正则还不规则。

正则表达式 有 3 大改变和加强： 语法更清新

很多小的改变让rules更容易写。例如现在点  .  能匹配任意字符 ，老的语法（除新行外的任意字符）能用 \N 完成。 修饰符 现在用在正则的 开头 了， 非捕获分组是  [ . . . ] , 这比旧的 (?: . . . )语法更容易读写。


嵌套捕获和匹配对象

在 Perl5 中，像这样的一个成功的匹配  (a(b))(c)，  会把 ab 放到 $1 中，把 b 放到 $2 中，把 c 放到 $3 中. 在 Perl 6 中这改了，现在   $0 ( 从 0 开始计数 ) 包含 ab ， 并且  $0[0]  或  $/[0][0]  包含   b,   $1  捕获 c 。 So each nesting level of parenthesis is reflected in a new nesting level in the result match object.

所有匹配的变量都是  $/ 的别名，这就是所谓的 匹配对象，它自然包含完整的匹配树。 具名正则和语法

你可以像声明 subs和methods 一样，使用名字声明正则。你可以在其他 rules 的内部用 <name> 引用它们。并且你可以将多个正则放到 grammars 里面,它就像类一样，并且支持继承和构造。这些变化让Perl 6的正则和grammars币Perl 5 的正则更容易写，更容易维护。

         所有这些变化可以讲的很深入，但是这里只能浅尝辄止。 Syntax clean up

字母字符（例如 下划线、数字、和所有的 Unicode 字符 ） 是字面匹配的，Letter characters (ie underscore, digits and all Unicode letters) match literally, and have a special meaning (they are metasyntactic ) when escaped with a backslash. For all other characters it's the other way round - they are metasyntactic unless escaped.
    literal         metasyntactic
    a  b  1  2      \a \b \1 \2
    \* \: \. \?     *  :  .  ?

Not all metasyntactic tokens have a meaning (yet). It is illegal to use those without a defined meaning.

另外一种在正则里转义字符串的方法：使用引号。
    m/'a literal text: $#@!!'/

上面已经提到 . 的 语法已经改变了，并且 [ . . . ] 现在构造的是 非捕获分组。字符集是 <[ . . . ]> , 而 排除字符集是 <-[ . . . ]>  。 ^  和  $  总是匹配字符串的开头和结尾。 ^^ 和 $$ 匹配 行的开头和结尾。

这意味着  /s  和  /m  修饰符消失了，修饰符现在 放在 正则的开头了，以这种记法给出：（冒号:修饰符 ,副词语法）
    if "abc" ~~ m :i /B/ {
        say "Match";
    }

  这碰巧是 colon pair 记法 ，以至于你可以使用它来向子例程传递具名参数.

修饰符有短和长两种形式。 旧的修饰符 /x 现在是默认的，空白被忽略。
    short   long            meaning
    -------------------------------
    :i      :ignorecase        忽略大小写（以前是 /i )
    :m    :ignoremark      忽略记号 ( 重音，分音符号等 )
    :g     :global               尽可能多的匹配 (/g)
    :s      :sigspace           正则中的每个空格都匹配
                                                 (optional) white space
    :P5     :Perl5              回到与 Perl 5 兼容的 正则语法、
    :4x     :x(4)                 匹配 4 次。（其它数字同样有效）
    : 3rd     :nth(3)            第 3 个 匹配
    :ov     :overlap          像 :g, 但也考虑重叠的匹配。
    :ex     :exhaustive     以所有可能的方式匹配
              :ratchet           不回溯。

  :sigspace 需要多解释一下，  它使用<.ws> (即它调用规则ws但不保存它的结果)。你可以复写那个规则。默认，needs a bit more explanation. It replaces all whitespace in the pattern with <.ws> (that is it calls the rule ws without keeping its result). You can override that rule. By default it matches one or more whitespaces if it's enclosed in word characters, and zero or more otherwise.

(There are more new modifiers, but probably not as important as the listed ones). The Match Object  匹配对象

Every match generates a so-called match object, which is stored in the special variable $/ . It is a versatile thing. In boolean context it returns Bool::True if the match succeeded. In string context it returns the matched string, when used as a list it contains the positional captures, and when used as a hash it contains the named captures. The .from and .to methods contain the first and last string position of the match respectively.
    if 'abcdefg' ~~ m/(.(.)) (e | bla ) $<foo> = (.) / {
        say $/[0][0];              # d
        say $/[0];                  # cd
        say $/[1];                  # e
        say $/<foo>             # f
    }

$0 , $1 etc are just aliases for $/[0] , $/[1] etc. Likewise $/<x> and $/{'x'} are aliased to $<x> .

Note that anything you access via $/[...] and $/{...} is a match object (or a list of Match objects) again. This allows you to build real parse trees with rules. Named Regexes and Grammars

Regexes can either be used with the old style m/.../ , or be declared like subs and methods.
    regex a { ... }
    token b { ... }
    rule  c { ... }

The difference is that token implies the :ratchet modifier (which means no backtracking, like a (?> ... ) group around each part of the regex in perl 5), and rule implies both :ratchet and :sigspace .

To call such a rule (we'll call them all rules, independently with which keyword they were declared) you put the name in angle brackets: <a> . This implicitly anchors the sub rule to its current position in the string, and stores the result in the match object in $/<a> , ie it's a named capture. You can also call a rule without capturing its result by prefixing its name with a dot: <.a> .

A grammar is a group of rules, just like a class (see the 概要 for an example). Grammars can inherit, override rules and so on.
    grammar URL::HTTP is URL {
        token schema { 'http' }
    } MOTIVATION

Perl 5 regexes are often rather unreadable, the grammars encourage you to split a large regex into more readable, short fragments. Named captures make the rules more self-documenting, and many things are now much more consistent than they were before.

Finally grammars are so powerful that you can parse about every programming language with them, including Perl 6 itself. That makes the Perl 6 grammar easier to maintain and to change than the Perl 5 one, which is written in C and not changeable at parse time. SEE ALSO

http://perlcabal.org/syn/S05.html

http://perlgeek.de/en/article/mutable-grammar-for-perl-6

http://perlgeek.de/en/article/longest-token-matching Junctions

Fri Sep 26 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 07 - Junctions 概要
    my $x = 4;
    if $x == 3|4 {
        say '$x is either 3 or 4'
    }
    say ((2|3|4)+7).perl        # (9|10|11) DESCRIPTION

Junctions are superpositions of unordered values. Operations on junctions are executed for each item of the junction separately (and maybe even in parallel), and the results are assembled in a junction of the same type.

The junction types only differ when evaluated in boolean context. The types are   any , all , one and none .
    Type    Infix operator
    any     |
    one     ^
    all     &

1 | 2 | 3 is the same as any(1..3) .  # any -> 任意一个
    my Junction $weekday = any <Monday Tuesday Wednesday
                                Thursday Friday Saturday Sunday>
    if $day eq $weekday {
        say "See you on $day";
    }

In this example the eq operator is called with each pair $day, 'Monday' , $day, 'Tuesday' etc. and the result is put into an any -junction again . As soon as the result is determined (in this case, as soon as one comparison returns True ) it can abort the execution of the other comparisons.

This works not only for operators, but also for routines :
    if 2 == sqrt(4 | 9 | 16) {
        say "YaY";
    }

To make this possible, junctions stand outside the normal type hierarchy (a bit):
                      Mu
                    /    \
                   /      \
                 Any     Junction
               /  |  \
            All other types

If you want to write a sub that takes a junction and doesn't autothread over it, you have to declare the type of the parameter either as Mu or Junction
    sub dump_yaml( Junction $stuff) {
        # we hope that YAML can represent junctions ;-)
        ....
    }

A word of warning: junctions can behave counter-intuitive sometimes. With non-junction types $a != $b and !($a == $b) always mean the same thing. If one of these variables is a junction, that might be different:
    my Junction $b = 3 | 2;
    my $a = 2;
    say "Yes" if   $a != $b ;       # Yes
    say "Yes" if !($a == $b);       # no output

2 != 3 is true, thus $a != 2|3 is also true. On the other hand the $a == $b comparison returns a single Bool value ( True ), and the negation of that is False . MOTIVATION

Perl aims to be rather close to natural languages, and in natural language you often say things like "if the result is $this or $that" instead of saying "if the result is $this or the result is $that". Most programming languages only allow (a translation of) the latter, which feels a bit clumsy. With junctions Perl 6 allows the former as well.

It also allows you to write many comparisons very easily that otherwise require loops.

As an example, imagine an array of numbers, and you want to know if all of them are non-negative. In Perl 5 you'd write something like this:
    # Perl 5 code:
    my @items = get_data();
    my $all_non_neg = 1;
    for (@items){
        if ($_ < 0) {
            $all_non_neg = 0;
            last;
        }
    }
    if ($all_non_neg) { ... }

Or if you happen to know about List::MoreUtils
    use List::MoreUtils qw(all);
    my @items = get_data;
    if (all { $_ >= 0 } @items) { ...  }

In Perl 6 that is short and sweet:
    my @items = get_data();
    if all(@items) >= 0 { ... } A Word of Warning

很多人对 junctions 很兴奋，并使用它们来做很多事，如果你尝试从 junction 中提取 items，你正在走在错误的道路上，你应该使用集合代替。

It is a good idea to use junctions as smart conditions, but trying to build a solver for equations based on the junction autothreading rules is on over-extortion and usually results in frustration. SEE ALSO

http://perlcabal.org/syn/S03.html#Junctive_operators 比较和匹配

Sat Sep 27 22:20:00 2008 NAME

"Perl 5 to 6" Lesson 09 - Comparing and Matching 概要
    "ab"    eq      "ab"    True
    "1.0"   eq      "1"     False
    "a"     ==      "b"     failure, because "a" isn't numeric
    "1"     ==      1.0     True
    1       ===     1       True
    [1, 2]  ===     [1, 2]  False
    $x = [1, 2];
    $x      ===     $x      True
    $x      eqv     $x      True
    [1, 2]  eqv     [1, 2]  True
    1.0     eqv     1       False
 
    'abc'   ~~      m/a/    Match object, True in boolean context
    'abc'   ~~      Str     True
    'abc'   ~~      Int     False
    Str     ~~      Any     True
    Str     ~~      Num     False
    1       ~~      0..4    True
    -3      ~~      0..4    False DESCRIPTION

Perl 6 still has string comparison operators ( eq , lt , gt , le , ge , ne ; cmp is now called leg ) that evaluate their operands in string context. Similarly all the numeric operators from Perl 5 are still there.

Since objects are more than blessed references, a new way for comparing them is needed. === returns only true for identical values. For immutable types like numbers or Strings that is a normal equality tests, for other objects it only returns True if both variables refer to the same object (like comparing memory addresses in C++).

eqv tests if two things are equivalent, ie if they are of the same type and have the same value. In the case of containers (like Array or Hash ), the contents are compared with eqv . Two identically constructed data structures are equivalent. Smart matching

Perl 6 has a "compare everything" operator, called "smart match" operator, and spelled ~~ . It is asymmetrical, and generally the type of the right operand determines the kind of comparison that is made.

For immutable types it is a simple equality comparison. A smart match against a type object checks for type conformance. A smart match against a regex matches the regex. Matching a scalar against a Range object checks if that scalar is included in the range.

There are other, more advanced forms of matching: for example you can check if an argument list ( Capture ) fits to the parameter list ( Signature ) of a subroutine, or apply file test operators (like -e in Perl 5).

What you should remember is that any "does $x fit to $y?"-Question will be formulated as a smart match in Perl 6. SEE ALSO

http://perlcabal.org/syn/S03.html#Smart_matching 容器和值

Wed Oct 15 22:00:00 2008 NAME

"Perl 5 to 6" Lesson 10 - Containers and Values 概要
    my ($x, $y); # 注意my后面有个空格
    $x := $y;  # 现在报错
    $y = 4;
    say $x;             # 4
    if $x =:= $y {
        say '$x and $y are different names for the same thing'
    } DESCRIPTION

Perl6区分不同的容器，值可以存储在容器中。

一个普通的变量是一个容器，它可以有一些诸如类型限制、存储限制（例如只读）的属性，并且最后它能被关联到其它容器。

将值放到容器中叫做赋值，而将两个容器关联起来叫做绑定。

    my @a = 1, 2, 3;
    my Int $x = 4;
    @a[0] := $x;       # 现在 @a[0] 和 $x 是相同的值
    @a[0] = 'Foo';   # Error 'Type check failed'

像 Int 和 Str 这样的类型是不可变的，例如这些类型的对象不会被改变；但是你仍然可以改变变量（即容器），它存储着这些值：
    my $a = 1;
    $a = 2;     # 这里没有惊讶

使用   ::= 操作符，能够在编译时完成绑定。

你可以使用 =:= 操作符检查两种东西是否绑定在一块。 MOTIVATION

导入导出子例程、类型和变量是通过关联来完成的。Perl 6 提供了一个简单的操作符，来代替很难把握的魔法一样的 typeglob 关联。 SEE ALSO

http://perlcabal.org/syn/S03.html#Item_assignment_precedence Perl 5 操作符的变化

Thu Oct 16 22:00:00 2008 NAME

"Perl 5 to 6" Lesson 11 - Changes to Perl 5 Operators 概要
    # 位运算符
    5   +| 3;        # 7
    5   +^ 3;       # 6
    5   +& 3;       # 1
    "b" ~| "d";     # 'f'
 
    # 字符串连接
    'a' ~ 'b';      # 'ab'
 
    # 文件测试
    if '/etc/passwd' .path ~~ :e { say "exists" }
 
    # 重复
    'a' x 3;        # 'aaa'
    'a' xx 3;       # 'a', 'a', 'a'
 
    # 三元操作符，条件操作符
    my ($a, $b) = 2, 2;
    say $a == $b ?? 2 * $a !! $b - $a;
 
    # 链式比较
    my $angle = 1.41;
    if 0 <= $angle < 2 * pi { ... } DESCRIPTION

所有的数字操作符 ( + , - , / , * , ** , % )仍然没有变化。

由于|，^和＆现在构建分支，按位运算符有一个变化过的语法。 他们现在包含一个上下文前缀，所以， 例如 +|  是用在 数值上下文中的逐位  或运算

他们现在包含一个上下文前缀，因此，例如 +| 是 数字上下文下的按位或运算，并且〜^是字符串的补位运算。位移位运算符以同样的方式改变了。

字符串连接符现在是 ~ 了，点 . 用于 方法调用。

文件测试现在制定了 Pair 记法，Perl 5 中的 -e 现在是 :e . 如果 除了 $_ 的某个东西可能用作文件名称，他可以通过    $filename.path ~~ :e 来提供。

重复操作符 x 现在分割成2个操作符了： x 用于重复字符串， xx 用于重复 列表。

以前的三元操作符  $condition ? $true : $false ,现在变为   $condition ?? $true !! $false .

比较操作符现在可以链接了，所以你可以这样写   $a < $b < $c，它会得到你想做的。 SEE ALSO

http://perlcabal.org/syn/S03.html#Changes_to_Perl_5_operators Laziness 惰性

Fri Oct 17 22:00:00 2008 NAME

"Perl 5 to 6"第12课- 惰性

概要
    my @integers = 1..*;  # 在脚本里面，1..*后面不用跟 1;
    for @integers -> $i {
        say $i;
        last if $i % 17 == 0;
    }
结果：
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
    
my @even := map { 2 * $_ }, 0..* ;
    my @stuff := gather {
        for 0 .. Inf {
            take 2 ** $_;
        }
    } DESCRIPTION

Perl 程序员通常很懒，它们的列表也是。

这里的懒惰意思是，求值被尽可能地延迟。当你写下一些诸如  @a := map BLOCK, @b , 那个 BLOCK块根本不会立即执行，只有当你开始访问 @a 里面的元素时，map  实际才执行那个代码块，然后按需要来填充 @a。

注意这里用了绑定而非赋值：赋值给数组可能会强制及早求值（除非编译器知道这个列表将是一个无限列表），而绑定绝对不会。

惰性允许你处理无限列表：只要你对全部参数处理，它们只取所需（已经被计算过的）

陷阱是:测定列表的长度或对列表进行排序会终止懒惰 -- 如果列表是无限的，它很可能会无限循环下去，或者在能被测定时舍弃。

一般地，所有的标量转换是积极的，非懒惰的。

惰性防止了不必要的计算，因此能够在保持代码简洁的同时增加性能。

在Perl5中，当你一行一行地读取文件时，你不会使用 ( <HANDLE> ),因为它将整个文件读到了内存中，然后才开始遍历。使用 惰性，这就不是问题了：
    my $file = open '/etc/passwd';
    for $file.lines -> $line {
        say $line;
    }

因为  $file.lines 是一个惰性列表，行只是物理上按需从磁盘中读取。  (当然，缓冲不算). gather/take

A very useful construct for creating lazy lists is gather { take } . It is used like this:
    my @list := gather {
        while True {
            # some computations;
            take $result;
        }
    }

gather BLOCK returns a lazy list. When items from @list are needed, the BLOCK is run until take is executed. take is just like return, and all take n items are used to construct @list . When more items from @list are needed, the execution of the block is resumed after take .

gather/take is dynamically scoped, so it is possible to call take outside of the lexical scope of the gather block:
    my @list = gather {
        for 1..10 {
            do_some_computation($_);
        }
    }
 
    sub do_some_computation($x) {
        take $x * ($x + 1);
    }

Note that gather can act on a single statement instead of a block too:
    my @list = gather for 1..10 {
        do_some_computation($_);
    } Controlling Laziness

Laziness has its problems (and when you try to learn Haskell you'll notice how weird their IO system is because Haskell is both lazy and free of side effects), and sometimes you don't want stuff to be lazy. In this case you can just prefix it with eager .
    my @list = eager map { $block_with_side_effects }, @list;

On the other hand only lists are lazy by default. But you can also make lazy scalars:
    my $ls = lazy { $expansive_computation }; MOTIVATION

In computer science most problems can be described with a tree of possible combinations, in which a solution is being searched for. The key to efficient algorithms is not only to find an efficient way to search, but also to construct only the interesting parts of the tree.

With lazy lists you can recursively define this tree and search in it, and it automatically constructs only these parts of the tree that you're actually using.

In general laziness makes programming easier because you don't have to know if the result of a computation will be used at all - you just make it lazy, and if it's not used the computation isn't executed at all. If it's used, you lost nothing. SEE ALSO

http://perlcabal.org/syn/S02.html#Lists  普通操作符

Sat Oct 18 22:00:00 2008 NAME

"Perl 5 to 6" Lesson 13 - Custom Operators 概要
    multi sub postfix: <!>( Int $x) {
        my $factorial = 1;
        $factorial *= $_ for 2..$x;
        return $factorial;
    }
 
    say 5!;                     # 120 DESCRIPTION

操作符就是有着不寻常的名字的函数，就像大侠不是普通人一样，它们有一些额外的属性，比如优先级和结合性。Perl6通常有这样的模式 项 中缀操作符 项，这里，项可以前置前缀操作符，也可以在后面跟着后缀操作符，或   postcircumfix 操作符。
    1 + 1               中缀
    +1                   前缀
    $x++               后缀
    <a b c>           环缀
    @a[1]              postcircumfix

操作符的名字也不限于“特殊”字符，它们可以包含除空白字符以外的任何字符。

操作符那个长长的名字是它的类型（比如 infix），后面跟着一个冒号和一个字符串直接量或一个符号列表或一个符号，例如， infix: <+>,是 1+2 中的操作符。另外一个例子是  postcircumfix:<[ ]> , 它是 @a[0] 中的操作符。

这些知识已经够你定义新的操作符了：
    multi sub prefix: <€> ( Int  $x) {  # 原文 Str 有误
        2 *  $x;
    }
    say €4;                         # 8 Precedence

In an expression like $a + $b * $c the infix:<*> operator has tighter precedence than infix:<+> , which is why the expression is evaluated as $a + ($b * $c) .

The precedence of a new operator can be specified in comparison to to existing operators:
    multi sub infix:<foo> is equiv(&infix:<+>) { ...  }
    mutli sub infix:<bar> is tighter(&infix:<+>) { ... }
    mutli sub infix:<baz> is looser(&infix:<+>) { ... } Associativity

Most infix operators take only two arguments. In an expression like 1 / 2 / 4 the associativity of the operator decides the order of evaluation. The infix:</> operator is left associative, so this expression is parsed as (1 / 2) / 4 . for a right associative operator like infix:<**> (exponentiation) 2 ** 2 ** 4 is parsed as 2 ** (2 ** 4) .

Perl 6 has more associativities: none forbids chaining of operators of the same precedence (for example 2 <=> 3 <=> 4 is forbidden), and infix:<,> has list associativity. 1, 2, 3 is translated to infix:<,>(1; 2; 3) . Finally there's the chain associativity: $a < $b < $c translates to ($a < $b) && ($b < $c) .
    multi sub infix:<foo> is tighter(&infix:<+>)
                          is assoc('left')
                          ($a, $b) {
        ...
    } Postcircumfix and Circumfix

Postcircumfix operators are method calls:
    class OrderedHash is Hash {
        method postcircumfix:<{ }>(Str $key) {
            ...
        }
    }

If you call that as $object{$stuff} , $stuff will be passed as an argument to the method, and $object is available as self .

Circumfix operators usually imply a different syntax (like in my @list = <a b c>; ), and are thus implemented as macros:
    macro circumfix:«< >»($text) is parsed / <-[>]>+ / {
        return $text.comb(rx/\S+/);
    }

The is parsed trait is followed by a regex that parses everything between the delimiters. If no such rule is given, it is parsed as normal Perl 6 code (which is usually not what you want if you introduce a new syntax). Str.comb searches for occurrences of a regex and returns a list of the text of all matches. "Overload" existing operators

Most (if not all) existing operators are multi subs or methods, and can therefore be customized for new types. Adding a multi sub is the way of "overloading" operators.
    class MyStr { ... }
    multi sub infix:<~>(MyStr $this, Str $other) { ... }

This means that you can write objects that behave just like the built in "special" objects like Str , Int etc. MOTIVATION

Allowing the user to declare new operators and "overload" existing ones makes user defined types just as powerful and useful as built in types. If the built in ones turn out to be insufficient, you can replace them with new ones that better fit your situation, without changing anything in the compiler.

It also removes the gap between using a language and modifying the language. SEE ALSO

http://perlcabal.org/syn/S06.html#Operator_overloading

If you are interested in the technical background, ie how Perl 6 can implement such operator changes and other grammar changes, read http://perlgeek.de/en/article/mutable-grammar-for-perl-6 . The MAIN sub

Sun Oct 19 22:00:00 2008 NAME

"Perl 5 to 6" Lesson 14 - The MAIN sub 概要
  # file doit.pl
 
  #!/usr/bin/perl6
  sub MAIN($path, :$force, :$recursive, :$home = '~/') {
      # do stuff here
  }
 
  # command line
  $ ./doit.pl --force --home=/home/someoneelse file_to_process DESCRIPTION

Calling subs and running a typical Unix program from the command line is visually very similar: you can have positional, optional and named arguments.

You can benefit from it, because Perl 6 can process the command line for you, and turn it into a sub call. Your script is normally executed (at which time it can munge the command line arguments stored in @*ARGS ), and then the sub MAIN is called, if it exists.

If the sub can't be called because the command line arguments don't match the formal parameters of the MAIN sub, an automatically generated usage message is printed.

Command line options map to subroutine arguments like this:
  -name                   :name
  -name=value             :name<value>
 
  # remember, <...> is like qw(...)
  --hackers=Larry,Damian  :hackers<Larry Damian> 
 
  --good_language         :good_language
  --good_lang=Perl        :good_lang<Perl>
  --bad_lang PHP          :bad_lang<PHP>
 
  +stuff                  :!stuff
  +stuff=healty           :stuff<healthy> but False

The $x = $obj but False means that $x is a copy of $obj , but gives Bool::False in boolean context.

So for simple (and some not quite simple) cases you don't need an external command line processor, but you can just use sub MAIN for that. MOTIVATION

The motivation behind this should be quite obvious: it makes simple things easier, similar things similar, and in many cases reduces command line processing to a single line of code: the signature of MAIN . SEE ALSO

http://perlcabal.org/syn/S06.html#Declaring_a_MAIN_subroutine contains the specification. Twigils

Mon Oct 20 22:00:00 2008 NAME

"Perl 5 to 6" Lesson 15 - Twigils 概要
  class Foo {
      has $.bar;
      has $!baz;
  }
 
  my @stuff = sort { $^b[1] <=> $^a[1]}, [1, 2], [0, 3], [4, 8];
  my $block = { say "This is the named 'foo' parameter: $:foo" };
  $block(:foo<bar>);
 
  say "This is file $?FILE on line $?LINE"
 
  say "A CGI script" if %*ENV.exists('DOCUMENT_ROOT'); DESCRIPTION

Some variables have a second sigil, called twigil . It basically means that the variable isn't "normal", but differs in some way, for example it could be differently scoped.

You've already seen that public and private object attributes have the . and ! twigil respectively; they are not normal variables, they are tied to self .

The ^ twigil removes a special case from perl 5. To be able to write
  # beware: perl 5 code
  sort { $a <=> $b } @array

the variables $a and $b are special cased by the strict pragma. In Perl 6, there's a concept named self-declared positional parameter , and these parameters have the ^ twigil. It means that they are positional parameters of the current block, without being listed in a signature. The variables are filled in lexicographic (alphabetic) order:
  my $block = { say "$^c $^a $^b" };
  $block(1, 2, 3);                # 3 1 2

So now you can write
  @list = sort { $^b <=> $^a }, @list;
  # or:
  @list = sort { $^foo <=> $^bar }, @list;

Without any special cases.

And to keep the symmetry between positional and named arguments, the : twigil does the same for named parameters, so these lines are roughly equivalent:
  my $block = { say $:stuff }
  my $sub   = sub (:$stuff) { say $stuff }

The ? twigil stands for variables and constants that are known at compile time, like $?LINE for the current line number (formerly __LINE__ ), and $?DATA is the file handle to the DATA section.

Contextual variables can be accessed with the * twigil, so $*IN and $*OUT can be overridden dynamically.

A pseudo twigil is < , which is used in a construct like $<capture> , where it is a shorthand for $/<capture> , which accesses the Match object after a regex match. MOTIVATION

When you read Perl 5's perlvar document, you can see that it has far too many variables, most of them global, that affect your program in various ways.

The twigils try to bring some order in these special variables, and at the other hand they remove the need for special cases. In the case of object attributes they shorten self.var to $.var (or @.var or whatever).

So all in all the increased "punctuation noise" actually makes the programs much more consistent and readable. Enums 枚举

Wed Nov 26 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 16 -枚举 概要
  enum bit Bool <False True>;
  my $value = $arbitrary_value but True;
  if $value {
      say "Yes, it's true";       # will be printed
  }
 
  enum Day ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
  if custom_get_date().Day == Day::Sat | Day::Sun {
      say "Weekend";
  } DESCRIPTION

Enums are versatile beasts. They are low-level classes that consist of an enumeration of constants, typically integers or strings (but can be arbitrary).

These constants can act as subtypes, methods or normal values. They can be attached to an object with the but operator, which "mixes" the enum into the value:
  my $x = $today but Day::Tue;

You can also use the type name of the Enum as a function, and supply the value as an argument:
  $x = $today but Day($weekday);

Afterwards that object has a method with the name of the enum type, here Day :
  say $x.Day;             # 1

The value of first constant is 0, the next 1 and so on, unless you explicitly provide another value with pair notation:
  Enum Hackers (:Larry<Perl>, :Guido<Python>, :Paul<Lisp>);

You can check if a specific value was mixed in by using the versatile smart match operator, or with .does :
  if $today ~~ Day::Fri {
      say "Thank Christ it's Friday"
  }
  if $today.does(Fri) { ... }

Note that you can specify the name of the value only (like Fri ) if that's unambiguous, if it's ambiguous you have to provide the full name Day::Fri . MOTIVATION

Enums replace both the "magic" that is involved with tainted variables in Perl 5 and the return "0 but True" hack (a special case for which no warning is emitted if used as a number). Plus they give a Bool type.

Enums also provide the power and flexibility of attaching arbitrary meta data for debugging or tracing. SEE ALSO

http://perlcabal.org/syn/S12.html#Enumerations Unicode

Thu Nov 27 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 17 - Unicode 概要
  (none)    DESCRIPTION

Perl 5's Unicode model suffers from a big weakness: it uses the same type for binary and for text data. For example if your program reads 512 bytes from a network socket, it is certainly a byte string. However when (still in Perl 5) you call uc on that string, it will be treated as text. The recommended way is to decode that string first, but when a subroutine receives a string as an argument, it can never surely know if it had been encoded or not, ie if it is to be treated as a blob or as a text.

Perl 6 on the other hand offers the type buf , which is just a collection of bytes, and Str , which is a collection of logical characters.

Logical character is still a vague term. To be more precise a Str is an object that can be viewed at different levels: Byte , Codepoint (anything that the Unicode Consortium assigned a number to is a codepoint), Grapheme (things that visually appear as a character) and CharLingua (language defined characters).

For example the string with the hex bytes 61 cc 80 consists of three bytes (obviously), but can also be viewed as being consisting of two codepoints with the names LATIN SMALL LETTER A (U+0041) and COMBINING GRAVE ACCENT (U+0300), or as one grapheme that, if neither my blog software nor your browser kill it, looks like this: à .

So you can't simply ask for the length of a string, you have to ask for a specific length:
  $str.bytes;
  $str.codes;
  $str.graphs;

There's also method named chars , which returns the length in the current Unicode level (which can be set by a pragma like use bytes , and which defaults to graphemes).

In Perl 5 you sometimes had the problem of accidentally concatenating byte strings and text strings. If you should ever suffer from that problem in Perl 6, you can easily identify where it happens by overloading the concatenation operator:
  sub GLOBAL::infix:<~> is deep (Str $a, buf $b)|(buf $b, Str $a) {
      die "Can't concatenate text string «"
          ~ $a.encode("UTF-8")
            "» with byte string «$b»\n";
  } Encoding and Decoding

The specification of the IO system is very basic and does not yet define any encoding and decoding layers, which is why this article has no useful 概要 section. I'm sure that there will be such a mechanism, and I could imagine it will look something like this:
  my $handle = open($filename, :r, :encoding<UTF-8>); Regexes and Unicode

Regexes can take modifiers that specify their Unicode level, so m:codes/./ will match exactly one codepoint. In the absence of such modifiers the current Unicode level will be used.

Character classes like \w (match a word character) behave accordingly to the Unicode standard. There are modifiers that ignore case ( :i ) and accents ( :a ), and modifiers for the substitution operators that can carry case information to the substitution string ( :samecase and :sameaccent , short :ii , :aa ). MOTIVATION

It is quite hard to correctly process strings with most tools and most programming languages these days. Suppose you have a web application in perl 5, and you want to break long words automatically so that they don't mess up your layout. When you use naive substr to do that, you might accidentally rip graphemes apart.

Perl 6 will be the first mainstream programming language with built in support for grapheme level string manipulation, which basically removes most Unicode worries, and which (in conjunction with regexes) makes Perl 6 one of the most powerful languages for string processing.

The separate data types for text and byte strings make debugging and introspection quite easy. SEE ALSO

http://perlcabal.org/syn/S32/Str.html Scoping

Fri Nov 28 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 18 -作用域 概要
    for 1 .. 10 -> $a {
        # $a在这是可见的
    }
    # $a 在这不可见
 
    while my $b = get_stuff() {
        # $b visible here
    }
    # $b still visible here
 
    my $c = 5;
    {
        my $c = $c;
        # $c is undef here
    }
    # $c is 5 here
 
    my $y;
    my $x = $y + 2 while $y = calc();
    # $x still visible DESCRIPTION Lexical Scoping

Scoping in Perl 6 is quite similar to that of Perl 5. A Block introduces a new lexical scope. A variable name is searched in the innermost lexical scope first, if it's not found it is then searched for in the next outer scope and so on. Just like in Perl 5 a my variable is a proper lexical variable, and an our declaration introduces a lexical alias for a package variable.

But there are subtle differences: variables are exactly visible in the rest of the block where they are declared, variables declared in block headers (for example in the condition of a while loop) are not limited to the block afterwards.

Also Perl 6 only ever looks up unqualified names (variables and subroutines) in lexical scopes.

If you want to limit the scope, you can use formal parameters to the block:
    if calc() -> $result {
        # you can use $result here
    }
    # $result not visible here

Variables are visible immediately after they are declared, not at the end of the statement as in Perl 5.
    my $x = .... ;
            ^^^^^
            $x visible here in Perl 6
            but not in Perl 5 Dynamic scoping

The local adjective is now called temp , and if it's not followed by an initialization the previous value of that variable is used (not undef ).

There's also a new kind of dynamically scoped variable called a hypothetical variable. If the block is left with an exception, then the previous value of the variable is restored. If not, it is kept. Context variables

Some variables that are global in Perl 5 ( $! , $_ ) are context variables in Perl 6, that is they are passed between dynamic scopes.

This solves an old Problem in Perl 5. In Perl 5 an DESTROY sub can be called at a block exit, and accidentally change the value of a global variable, for example one of the error variables:
   # Broken Perl 5 code here:
   sub DESTROY { eval { 1 }; }
 
   eval {
       my $x = bless {};
       die "Death\n";
   };
   print $@ if $@;         # No output here

In Perl 6 this problem is avoided by not implicitly using global variables.

(In Perl 5.14 there is a workaround that protects $@ from being modified, thus averting the most harm from this particular example.) Pseudo-packages

If a variable is hidden by another lexical variable of the same name, it can be accessed with the OUTER pseudo package
    my $x = 3;
    {
        my $x = 10;
        say $x;             # 10
        say $OUTER::x;      # 3
        say OUTER::<$x>     # 3
    }

Likewise a function can access variables from its caller with the CALLER and CONTEXT pseudo packages. The difference is that CALLER only accesses the scope of the immediate caller, CONTEXT works like UNIX environment variables (and should only be used internally by the compiler for handling $_ , $! and the like). To access variables from the outer dynamic scope they must be declared with is context . MOTIVATION

It is now common knowledge that global variables are really bad, and cause lots of problems. We also have the resources to implement better scoping mechanism. Therefore global variables are only used for inherently global data (like %*ENV or $*PID ).

The block scoping rules haven been greatly simplified.

Here's a quote from Perl 5's perlsyn document; we don't want similar things in Perl 6:
NOTE: The behaviour of a "my" statement modified with a statement
modifier conditional or loop construct (e.g. "my $x if ...") is
 undefined.  The value of the "my" variable may be "undef", any
 previously assigned value, or possibly anything else.  Don't rely on
 it.  Future versions of perl might do something different from the
 version of perl you try it out on.  Here be dragons. SEE ALSO

S04 discusses block scoping: http://perlcabal.org/syn/S04.html .

S02 lists all pseudo packages and explains context scoping: http://perlcabal.org/syn/S02.html#Names . Regexes strike back

Sat Nov 29 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 19 - Regexes strike back 概要
    # normal matching:
    if 'abc' ~~ m/../ {
        say $/;                 # ab
    }
 
    # match with implicit :sigspace modifier
    if 'ab cd ef'  ~~ mm/ (..) ** 2 / {
        say $1;                 # cd
    }
 
    # substitute with the :sigspace modifier
    my $x = "abc     defg";
    $x ~~ ss/c d/x y/;
    say $x;                     # abx     yefg DESCRIPTION

Since the basics of regexes are already covered in lesson 07, here are some useful (but not very structured) additional facts about Regexes. Matching

You don't need to write grammars to match regexes, the traditional form m/.../ still works, and has a new brother, the mm/.../ form, which implies the :sigspace modifier. Remember, that means that whitespaces in the regex are substituted by the <.ws> rule.

The default for the rule is to match \s+ if it is surrounded by two word-characters (ie those matching those \w ), and \s* otherwise.

In substitutions the :samespace modifier takes care that whitespaces matched with the ws rule are preserved. Likewise the :samecase modifier, short :ii (since it's a variant of :i ) preserve case.
    my $x = 'Abcd';
    $x ~~ s:ii/^../foo/;
    say $x;                     # Foocd
    $x = 'ABC'
    $x ~~ s:ii/^../foo/;
    say $x                      # FOO

This is very useful if you want to globally rename your module Foo , to Bar , but for example in environment variables it is written as all uppercase. With the :ii modifier the case is automatically preserved.

It copies case information on a character by character. But there's also a more intelligent version; when combined with the :sigspace (short :s ) modifier, it tries to find a pattern in the case information of the source string. Recognized are .lc , .uc , .lc.ucfirst , .uc.lcfirst and .lc.capitaliz ( Str.capitalize uppercases the first character of each word). If such a pattern is found, it is also applied to the substitution string.
    my $x = 'The Quick Brown Fox';
    $x ~~ s :s :ii /brown.*/perl 6 developer/;
    # $x is now 'The Quick Perl 6 Developer' Alternations

Alternations are still formed with the single bar | , but it means something else than in Perl 5. Instead of sequentially matching the alternatives and taking the first match, it now matches all alternatives in parallel, and takes the longest one.
    'aaaa' ~~ m/ a | aaa | aa /;
    say $/                          # aaa

While this might seem like a trivial change, it has far reaching consequences, and is crucial for extensible grammars. Since Perl 6 is parsed using a Perl 6 grammar, it is responsible for the fact that in ++$a the ++ is parsed as a single token, not as two prefix:<+> tokens.

The old, sequential style is still available with || :
    grammar Math::Expression {
        token value {
            | <number>
            | '('
              <expression>
              [ ')' || { fail("Parenthesis not closed") } ]
        }
 
        ...
    }

The { ... } execute a closure, and calling fail in that closure makes the expression fail. That branch is guaranteed to be executed only if the previous (here the ')' ) fails, so it can be used to emit useful error messages while parsing.

There are other ways to write alternations, for example if you "interpolate" an array, it will match as an alternation of its values:
    $_ = '12 oranges';
    my @fruits = <apple orange banana kiwi>;
    if m:i:s/ (\d+) (@fruits)s? / {
        say "You've got $0 $1s, I've got { $0 + 2 } of them. You lost.";
    }

There is yet another construct that automatically matches the longest alternation: multi regexes. They can be either written as multi token name or with a proto :
    grammar Perl {
        ...
        proto token sigil { * }
        token sigil:sym<$> { <sym> }
        token sigil:sym<@> { <sym> }
        token sigil:sym<%> { <sym> }
        ...
 
       token variable { <sigil> <twigil>? <identifier> }
   }

This example shows multiple tokens called sigil , which are parameterized by sym . When the short name, ie sigil is used, all of these tokens are matched in an alternation. You may think that this is a very inconvenient way to write an alternation, but it has a huge advantage over writing '$'|'@'|'%' : it is easily extensible:
    grammar AddASigil is Perl {
        token sigil:sym<!> { <sym> }
    }
    # wow, we have a Perl 6 grammar with an additional sigil!

Likewise you can override existing alternatives:
    grammar WeirdSigil is Perl {
        token sigil:sym<$> { '°' }
    }

In this grammar the sigil for scalar variables is ° , so whenever the grammar looks for a sigil it searches for a ° instead of a $ , but the compiler will still know that it was the regex sigil:sym<$> that matched it.

In the next lesson you'll see the development of a real, working grammar with Rakudo. A grammar for (pseudo) XML

Fri Dec  5 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 20 - A grammar for (pseudo) XML 概要
    grammar XML {
        token TOP   { ^ <xml> $ };
        token xml   { <text> [ <tag> <text> ]* };
        token text {  <-[<>&]>* };
        rule tag   {
            '<'(\w+) <attributes>*
            [
                | '/>'                 # a single tag
                | '>'<xml>'</' $0 '>'  # an opening and a closing tag
            ]
        };
        token attributes { \w+ '="' <-["<>]>* '"' };
    }; DESCRIPTION

So far the focus of these articles has been the Perl 6 language, independently of what has been implemented so far. To show you that it's not a purely fantasy language, and to demonstrate the power of grammars, this lesson shows the development of a grammar that parses basic XML, and that runs with Rakudo.

Please follow the instructions on http://rakudo.org/how-to-get-rakudo/ to obtain and build Rakudo, and try it out yourself. Our idea of XML

For our purposes XML is quite simple: it consists of plain text and nested tags that can optionally have attributes. So here are few tests for what we want to parse as valid "XML", and what not:
    my @tests = (
        [1, 'abc'                       ],      # 1
        [1, '<a></a>'                   ],      # 2
        [1, '..<ab>foo</ab>dd'          ],      # 3
        [1, '<a><b>c</b></a>'           ],      # 4
        [1, '<a href="foo"><b>c</b></a>'],      # 5
        [1, '<a empty="" ><b>c</b></a>' ],      # 6
        [1, '<a><b>c</b><c></c></a>'    ],      # 7
        [0, '<'                         ],      # 8
        [0, '<a>b</b>'                  ],      # 9
        [0, '<a>b</a'                   ],      # 10
        [0, '<a>b</a href="">'          ],      # 11
        [1, '<a/>'                      ],      # 12
        [1, '<a />'                     ],      # 13
    );
 
    my $count = 1;
    for @tests -> $t {
        my $s = $t[1];
        my $M = XML.parse($s);
        if !($M  xor $t[0]) {
            say "ok $count - '$s'";
        } else {
            say "not ok $count - '$s'";
        }
        $count++;
    }

This is a list of both "good" and "bad" XML, and a small test script that runs these tests by calling XML.parse($string) . By convention the rule that matches what the grammar should match is named TOP .

(As you can see from test 1 we don't require a single root tag, but it would be trivial to add this restriction). Developing the grammar

The essence of XML is surely the nesting of tags, so we'll focus on the second test first. Place this at the top of the test script:
    grammar XML {
        token TOP   { ^ <tag> $ }
        token tag   {
            '<' (\w+) '>'
            '</' $0   '>'
        }
    };

Now run the script:
    $ ./perl6 xml-01.pl
    not ok 1 - 'abc'
    ok 2 - '<a></a>'
    not ok 3 - '..<ab>foo</ab>dd'
    not ok 4 - '<a><b>c</b></a>'
    not ok 5 - '<a href="foo"><b>c</b></a>'
    not ok 6 - '<a empty="" ><b>c</b></a>'
    not ok 7 - '<a><b>c</b><c></c></a>'
    ok 8 - '<'
    ok 9 - '<a>b</b>'
    ok 10 - '<a>b</a'
    ok 11 - '<a>b</a href="">'
    not ok 12 - '<a/>'
    not ok 13 - '<a />'

So this simple rule parses one pair of start tag and end tag, and correctly rejects all four examples of invalid XML.

The first test should be easy to pass as well, so let's try this:
   grammar XML {
       token TOP   { ^ <xml> $ };
       token xml   { <text> | <tag> };
       token text  { <-[<>&]>*  };
       token tag   {
           '<' (\w+) '>'
           '</' $0   '>'
       }
    };

(Remember, <-[...]> is a negated character class.)

And run it:
    $ ./perl6 xml-03.pl
    ok 1 - 'abc'
    not ok 2 - '<a></a>'
    (rest unchanged)

Why in the seven hells did the second test stop working? The answer is that Rakudo doesn't do longest token matching yet (update 2013-01: it does now), but matches sequentially. <text> matches the empty string (and thus always), so <text> | <tag> never even tries to match <tag> . Reversing the order of the two alternations would help.

But we don't just want to match either plain text or a tag anyway, but random combinations of both of them:
    token xml   { <text> [ <tag> <text> ]*  };

( [...] are non-capturing groups, like (?: ... ) is in Perl 5).

And low and behold, the first two tests both pass.

The third test, ..<ab>foo</ab>dd , has text between opening and closing tag, so we have to allow that next. But not only text is allowed between tags, but arbitrary XML, so let's just call <xml> there:
    token tag   {
        '<' (\w+) '>'
        <xml>
        '</' $0   '>'
    }
 
    ./perl6 xml-05.pl
    ok 1 - 'abc'
    ok 2 - '<a></a>'
    ok 3 - '..<ab>foo</ab>dd'
    ok 4 - '<a><b>c</b></a>'
    not ok 5 - '<a href="foo"><b>c</b></a>'
    (rest unchanged)

We can now focus on attributes (the href="foo" stuff):
    token tag   {
        '<' (\w+) <attribute>* '>'
        <xml>
        '</' $0   '>'
    };
    token attribute {
        \w+ '="' <-["<>]>* \"
    };

But this doesn't make any new tests pass. The reason is the blank between the tag name and the attribute. Instead of adding \s+ or \s* in many places we'll switch from token to rule , which implies the :sigspace modifier:
    rule tag   {
        '<'(\w+) <attribute>* '>'
        <xml>
        '</'$0'>'
    };
    token attribute {
        \w+ '="' <-["<>]>* \"
    };

Now all tests pass, except the last two:
    ok 1 - 'abc'
    ok 2 - '<a></a>'
    ok 3 - '..<ab>foo</ab>dd'
    ok 4 - '<a><b>c</b></a>'
    ok 5 - '<a href="foo"><b>c</b></a>'
    ok 6 - '<a empty="" ><b>c</b></a>'
    ok 7 - '<a><b>c</b><c></c></a>'
    ok 8 - '<'
    ok 9 - '<a>b</b>'
    ok 10 - '<a>b</a'
    ok 11 - '<a>b</a href="">'
    not ok 12 - '<a/>'
    not ok 13 - '<a />'

These contain un-nested tags that are closed with a single slash / . No problem to add that to rule tag :
    rule tag   {
        '<'(\w+) <attribute>* [
            | '/>'
            | '>' <xml> '</'$0'>'
        ]
    };

All tests pass, we're happy, our first grammar works well. More hacking

Playing with grammars is much more fun that reading about playing, so here's what you could implement:
plain text can contain entities like &amp;
I don't know if XML tag names are allowed to begin with a number, but the current grammar allows that. You might look it up in the XML specification, and adapt the grammar if needed.
plain text can contain <![CDATA[ ... ]]> blocks, in which xml-like tags are ignored and < and the like don't need to be escaped
Real XML allows a preamble like <?xml version="0.9" encoding="utf-8"?> and requires one root tag which contains the rest (You'd have to change some of the existing test cases)
You could try to implement a pretty-printer for XML by recursively walking through the match object $/ . (This is non-trivial; you might have to work around a few Rakudo bugs, and maybe also introduce some new captures).


(Please don't post solutions to this as comments in this blog; let others have the same fun as you had ;-).

Have fun hacking. MOTIVATION

It's powerful and fun SEE ALSO

Regexes are specified in great detail in S05: http://perlcabal.org/syn/S05.html .

More working examples for grammars can be found at https://github.com/moritz/json/ (check file lib/JSON/Tiny/Grammar.pm). Subset Types

Sat Dec  6 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 21 - Subset Types 概要
    subset Squares of Int where { .sqrt.Int**2 == $_ };
 
    multi sub square_root(Squares $x --> Int) {
        return $x.sqrt.Int;
    }
    multi sub square_root(Num $x --> Num) {
        return $x.sqrt;
    } DESCRIPTION

Java programmers tend to think of a type as either a class or an interface (which is something like a crippled class), but that view is too limited for Perl 6. A type is more generally a constraint of what a values a container can constraint. The "classical" constraint is it is an object of a class X or of a class that inherits from X . Perl 6 also has constraints like the class or the object does role Y , or this piece of code returns true for our object . The latter is the most general one, and is called a subset type:
    subset Even of Int where { $_ % 2 == 0 }
    # Even can now be used like every other type name
 
    my Even $x = 2;
    my Even $y = 3; # type mismatch error

(Try it out, Rakudo implements subset types).

You can also use anonymous subtypes in signatures:
    sub foo (Int where { ... } $x) { ... }
    # or with the variable at the front:
    sub foo ($x of Int where { ... } ) { ... } MOTIVATION

Allowing arbitrary type constraints in the form of code allows ultimate extensibility: if you don't like the current type system, you can just roll your own based on subset types.

It also makes libraries easier to extend: instead of dying on data that can't be handled, the subs and methods can simply declare their types in a way that "bad" data is rejected by the multi dispatcher. If somebody wants to handle data that the previous implementation rejected as "bad", he can simple add a multi sub with the same name that accepts the data. For example a math library that handles real numbers could be enhanced this way to also handle complex numbers.


Quoting and Parsing 引起和解析

Mon Dec  8 23:00:00 2008 NAME

"Perl 5 to 6" Lesson 23 - Quoting and Parsing 概要
    my @animals = <dog cat tiger>
    # or
    my @animals = qw /dog cat tiger/;
    # or
 
    my $interface = q {eth0};
    my $ips = q :s :x /ifconfig $interface/;  # 组合副词，标量能插值，能将命令执行结果插值。
 
    # -----------
 
    sub if {
        warn "if() calls a sub\n";
    }
    if(); 描述 引号

Perl6有强大的引起字符串机制，你对字符串想要什么样的特性有精确的控制。Perl5有单引号，双引号，和 qw() (单引号，用空白分割）、q( .. )、qq( ... )

Perl6,反过来定义了一个叫做 Q 的操作符，它拥有各种修饰符。 :b （反斜线）修饰符允许像 \n 这样带反斜线的转义序列的插值， :s 修饰符允许标量变量的插值， :c 允许 （“1 + 2 = { 1 + 2 }”）等闭包的插值。

  :w  按单词进行分割，就像 Perl5中的  qw/.../  所做的一样.

你可以任意组合那些修饰符（其实是副词）。例如，你希望有这种形式的 qw/ .. /, 只对标量进行插值，而不对其它任何变量插值？没问题：
    my $stuff = "honey";
    my @list = Q :w :s /milk toast $stuff with \t funny \n escapes/;
    say @list[*-1];                     # prints with \t funny \n escapes

下面是可用的修饰符的一个清单，大部分是直接从 S02 偷过来的，所有这些修饰符都有一个长名，这里我省略了。
    特性:
        :q          插值 \\, \q and \'
        :b          其它反斜线转义序列，比如 \n, \t
    操作:
        :x           作为shell命令执行，返回执行结果
        :w          按空白分割字符串
        :ww        按空白分割字符串，Split on whitespaces, with quote protection
    变量插值
        :s          对标量进行插值 ($stuff)
        :a          对数组插值 (@stuff[])
        :h          对散列插值 (%stuff{})
        :f           对函数插值  (&stuff())
    其它
        :c          对闭包插值   ({code})
        :qq       使用 :s, :a, :h, :f, :c, :b 插值
        :regex  解析为正则

快捷形式让你的生活更美好：
    q       Q:q
    qq      Q:qq
    m       Q:regex

如果引号符号是短形式的话，你可以省略第一个冒号，并将它写作单个词：
符号     short for
    qw          q:w
    Qw          Q:w
    qx          q:x
    Qc          Q:c
    # and so on.

然而，你不能在 Perl6中使用  qw(...)了，因为它会被解析为对名为 qw的子例程的调用。 解析

这就是解析发挥作用的地方：形如  identifier(...)  的结构都会被解析为子例程调用，是的，每个。
    if($x<3)

被解析为对子例程 if 的调用。你可以使用空白消除歧义：
    if ($x < 3) { say '<3' }

或者就省略括号好了
    if $x < 3 { say '<3' } SEE ALSO

http://perlcabal.org/syn/S02.html#Literals  Reduction 元操作符

Tue Dec  9 23:00:00 2008 NAME

"Perl 5 to 6"第 24 课 - The Reduction Meta Operator 概要
    say [+] 1, 2, 3;       # 6
    say [+] ();              # 0
    say [~] <a b>;      # ab
    say [**] 2, 3, 4;      # 2417851639229258349412352
 
    [\+] 1, 2, 3, 4        # 1, 3, 6, 10
    [\**] 2, 3, 4           # 4, 81, 2417851639229258349412352
 
    if [<=] @list {
        say "ascending order";
    } Description

The reduction meta operator [...] can enclose any associative infix operator, and turn it into a list operator. This happens as if the operator was just put between the items of the list, so [op] $i1, $i2, @rest returns the same result as if it was written as $i1 op $i2 op @rest[0] op @rest[1] ... .

This is a very powerful construct that promotes the plus + operator into a sum function, ~ into a join (with empty separator) and so on. It is somewhat similar to the List.reduce function, and if you had some exposure to functional programming, you'll probably know about foldl and foldr (in Lisp or Haskell). Unlike those [...] respects the associativity of the enclosed operator, so [/] 1, 2, 3 is interpreted as (1 / 2) / 3 (left associative), [**] 1, 2, 3 is handled correctly as 1 ** (2**3) (right associative).

就像所有其他的操作符一样空白是禁止的，你可以写[+],但不能说 [ + ] .

因为比较操作符能够链接起来，你也可以这样写：
    if    [==] @nums { say "all nums in @nums are the same" }
    elsif [<]  @nums { say "@nums is in strict ascending order" }
    elsif [<=] @nums { say "@nums is in ascending order"}

You can even reduce the assignment operator:
    my @a = 1..3;
    [=] @a, 4;          # same as @a[0] = @a[1] = @a[2] = 4;

注意  [...]  总是返回标量，所以 [,] @list 实际上与  [@list] 相同。 获取部分结果

这样的元操作符有一种使用反斜杠的特殊的形式，像这样： [\+].  它返回一个列表，列表中每个元素取自计算结果的一部分. 所以  [\+] 1..3  返回列表   1, 1+2, 1+2+3 , 这自然是  1, 3, 6 .
    [\~] 'a' .. 'd'     # <a ab abc abcd>

因为右结合性的操作符是从右向左进行计算的，你仍旧像原来那样获取部分结果：
    [\**] 1..3;         # 3, 2**3, 1**(2**3), which is 3, 8, 1

  可以组合多个 reduction 操作符：
    [~] [\**] 1..3;     # "381" MOTIVATION

Programmers are lazy, and don't want to write a loop just to apply a binary operator to all elements of a list. List.reduce does something similar, but it's not as terse as the meta operator ( [+] @list would be @list.reduce(&infix:<+>) ), and takes care of the associativity of the operator.

If you're not convinced, play a bit with it (pugs mostly implements it), it's real fun. SEE ALSO

http://perlcabal.org/syn/S03.html#Reduction_operators , http://www.perlmonks.org/?node_id=716497 交叉元操作符

Tue May 26 22:00:00 2009 NAME

"Perl 5 to 6" Lesson 25 - The Cross Meta Operator 概要
    for <a b> X 1..3 -> $a, $b {
        print "$a: $b   ";
    }
    # output: a: 1  a: 2  a: 3  b: 1  b: 2  b: 3
 
    .say for <a b c> X 1, 2;
    # output: a1\n a2\n b1\n b2\n c1\n c2\n
    # (with real newlines instead of \n) DESCRIPTION

The cross operator X returns the Cartesian product of two or more lists, which means that it returns all possible tuples where the first item is an item of the first list, the second item is an item of second list etc.

If an operator follows the X , then this operator is applied to all tuple items, and the result is returned instead. So 1, 2 X+ 3, 6 will return the values 1+3, 1+6, 2+3, 2+6 (evaluated as 4, 7, 5, 8 of course). MOTIVATION

It's quite common that one has to iterate over all possible combinations of two or more lists, and the cross operator can condense that into a single iteration, thus simplifying programs and using up one less indentation level.

The usage as a meta operator can sometimes eliminate the loops altogether. SEE ALSO

http://perlcabal.org/syn/S03.html#Cross_operators , 异常处理和控制异常

Thu Jul  9 09:00:02 2009 NAME

"Perl 5 to 6" Lesson 26 - Exceptions and control exceptions 概要
    try {
        die "OH NOEZ";
 
         CATCH {
            say "there was an error: $!";
        }
    } DESCRIPTION

Exceptions are, contrary to their name, nothing exceptional. In fact they are part of the normal control flow of programs in Perl 6.

Exceptions are generated either by implicit errors (for example dividing by zero, calling a non-existing method, type check failures) or by explicitly calling die or other functions.

When an exception is thrown, the program searches for CATCH statements or try blocks in the caller frames, unwinding the stack all the way (that means it forcibly returns from all routines called so far). If no CATCH or try is found, the program terminates, and prints out a hopefully helpful error message. If one was found, the error message is stored in the special variable $! , and the CATCH block is executed (or in the case of a try without a CATCH block the try block returns undef ).

So far exceptions might still sound exceptional, but error handling is integral part of each non-trivial application. But even more, normal return statements also throw exceptions!

They are called control exceptions , and can be caught with CONTROL blocks, or are implicitly caught at each routine declaration.

Consider this example:
    use v6;
    my $block = -> { return "block"; say "still here" };
 
    sub s {
        $block.();
        return "sub";
    }
 
    say s();

Here the return "block" throws a control exception, causing it to not only exit the current block (and thus not printing still here on the screen), but also exiting the subroutine, where it is caught by the sub s... declaration. The payload, here a string, is handed back as the return value, and the say in the last line prints it to the screen.

Embedding the call $block.() in a try { ... } block or adding a CONTROL { ... } block to the body of the routine causes it to catch the exception.

Contrary to what other programming languages do, the CATCH / CONTROL blocks are within the scope in which the error is caught (not on the outside), giving it full access to the lexical variables, which makes it easier to generate useful error message, and also prevents DESTROY blocks from being run before the error is handled. Unthrown exceptions

Perl 6 embraces the idea of multi threading, and in particular automated parallelization. To make sure that not all threads suffer from the termination of a single thread, a kind of "soft" exception was invented.

When a function calls fail($obj) , it returns a special value of undef , which contains the payload $obj (usually an error message) and the back trace (file name and line number). Processing that special undefined value without check if it's undefined causes a normal exception to be thrown.
    my @files = </etc/passwd /etc/shadow nonexisting>;
    my @handles = hyper map { open($_) }, @files;

In this example the hyper operator tells map to parallelize its actions as far as possible. When the opening of the nonexisting file fails, an ordinary die "No such file or directory" would also abort the execution of all other open operations. But since a failed open calls fail("No such file or directory" instead, it gives the caller the possibility to check the contents of @handles , and it still has access to the full error message .

If you don't like soft exceptions, you say use fatal; at the start of the program and cause all exceptions from fail() to be thrown immediately. MOTIVATION

A good programming language needs exceptions to handle error conditions. Always checking return values for success is a plague and easily forgotten.

Since traditional exceptions can be poisonous for implicit parallelism, we needed a solution that combined the best of both worlds: not killing everything at once, and still not losing any information. 常见的Perl6数据处理惯用语

Thu Jul 22 13:34:26 2010 NAME

"Perl 5 to 6"第27 课 - Common Perl 6 data processing idioms 概要
  # create a hash from a list of keys and values:
  # solution 1: 切片
  my %hash; %hash{@keys} = @values;
  # solution 2:元操作符
  my %hash = @keys Z=> @values;
 
  # create a hash from an array, with
  # true value for each array item:
  my %exists = @keys Z=> 1 xx *;
 
 my @keys=('a','b','c','d');
a b c d
my %exists = @keys Z=> 1 xx *;
("a" => 1, "b" => 1, "c" => 1, "d" => 1).hash


  # 限制值在一个给定的区间内，这里是 0..10.
  my $x = -2;
  say 0 max $x min 10;
 
  # 作调试：输出变量的内容,
  #包含它的名字, 到 STDERR
  注意:$x.perl;
 
  # sort case-insensitively
  say @list.sort: *.lc;
 
  # mandatory attributes
  class Something {
      has $.required = die "Attribute 'required' is mandatory";
  }
  Something.new(required => 2); # no error
  Something.new()               # BOOM DESCRIPTION

Learning the specification of a language is not enough to be productive with it. Rather you need to know how to solve specific problems. Common usage patterns, called idioms , helps you not having to re-invent the wheel every time you're faced with a problem.

So here a some common Perl 6 idioms, dealing with data structures. Hashes
  # create a hash from a list of keys and values:
  # solution 1: slices
  my %hash; %hash{@keys} = @values;
  # solution 2: meta operators
  my %hash = @keys Z=> @values;

The first solution is the same you'd use in Perl 5: assignment to a slice. The second solution uses the zip operator Z , which joins to list like a zip fastener: 1, 2, 3 Z 10, 20, 30 is 1, 10, 2, 20, 3, 30 . The Z=> is a meta operator, which combines zip with => (the Pair construction operator). So 1, 2, 3 Z=> 10, 20, 30 evaluates to 1 => 10, 2 => 20, 3 => 30 . Assignment to a hash variable turns that into a Hash.

For existence checks, the values in a hash often doesn't matter, as long as they all evaluate to True in boolean context. In that case, a nice way to initialize the hash from a given array or list of keys is
  my %exists = @keys Z=> 1 xx *;

which uses a lazy, infinite list of 1s on the right-hand side, and relies on the fact that Z ends when the shorter list is exhausted. Numbers

Sometimes you want to get a number from somewhere, but clip it into a predefined range (for example so that it can act as an array index).

In Perl 5 you often end up with things like $a = $b > $upper ? $upper : $b , and another conditional for the lower limit. With the max and min infix operators, that simplifies considerably to
  my $in-range = $lower max $x min $upper;

because $lower max $x returns the larger of the two numbers, and thus clipping to the lower end of the range.

Since min and max are infix operators, you can also clip infix:
$x max= 0;
$x min= 10; Debugging

Perl 5 has Data::Dumper, Perl 6 objects have the .perl method. Both generate code that reproduces the original data structure as faithfully as possible.

:$var generates a Pair ("colonpair"), using the variable name as key (but with sigil stripped). So it's the same as var => $var . note() writes to the standard error stream, appending a newline. So note :$var.perl is quick way of obtaining the value of a variable for debugging; purposes, along with its name. Sorting

Like in Perl 5, the sort built-in can take a function that compares two values, and then sorts according to that comparison. Unlike Perl 5, it's a bit smarter, and automatically does a transformation for you if the function takes only one argument.

In general, if you want to compare by a transformed value, in Perl 5 you can do:
    # WARNING: Perl 5 code ahead
    my @sorted = sort { transform($a) cmp transform($b) } @values;
 
    # or the so-called Schwartzian Transform:
    my @sorted = map { $_->[1] }
                 sort { $a->[0] cmp $b->[0] }
                 map { [transform($_), $_] }
                 @values

The former solution requires repetitive typing of the transformation, and executes it for each comparison. The second solution avoids that by storing the transformed value along with the original value, but it's quite a bit of code to write.

Perl 6 automates the second solution (and a bit more efficient than the naiive Schwartzian transform, by avoiding an array for each value) when the transformation function has arity one, ie accepts one argument only:
    my @sorted = sort &transform, @values; Mandatory Attributes

The typical way to enforce the presence of an attribute is to check its presence in the constructor - or in all constructors, if there are many.

That works in Perl 6 too, but it's easier and safer to require the presence at the level of each attribute:
    has $.attr = die "'attr' is mandatory";

This exploits the default value mechanism. When a value is supplied, the code for generating the default value is never executed, and the die never triggers. If any constructor fails to set it, an exception is thrown. MOTIVATION


Currying  

Sun Jul 25 09:17:10 2010 NAME

"Perl 5 to 6" Lesson 28 - Currying 柯里化 概要
  use v6;
 
  my &f := & substr.assuming('Hello, World');
  say f(0, 2);                # He
  say f(3, 2);                # lo
  say f(7);                   # World
 
  say <a b c>.map: * x 2;     # aabbcc
  say <a b c>.map: *. uc;      # ABC


<a b c>.[1]
b
<a b c>.[2]
c
<a b c>.[0]
a


 for ^10 {
      print <R G B>.[$_ % *];  # RGBRGBRGBR
  } DESCRIPTION

Currying or partial application is the process of generating a function from another function or method by providing only some of the arguments. This is useful for saving typing, and when you want to pass a callback to another function.

Suppose you want a function that lets you extract substrings from "Hello, World" easily. The classical way of doing that is writing your own function:
  sub f(*@a) {
      substr('Hello, World', | @a)
  } Currying with assuming

Perl 6 provides a method assuming on code objects, which applies the arguments passed to it to the invocant, and returns the partially applied function.
  my &f := &substr.assuming('Hello, World');

Now f(1, 2) is the same as substr('Hello, World', 1, 2) .

assuming also works on operators, because operators are just subroutines with weird names. To get a subroutine that adds 2 to whatever number gets passed to it, you could write
  my &add_two := &infix:<+>.assuming(2);

But that's tedious to write, so there's another option. Currying with the Whatever-Star
  my &add_two := * + 2;
  say add_two(4);         # 6

The asterisk, called Whatever , is a placeholder for an argument, so the whole expression returns a closure. Multiple Whatevers are allowed in a single expression, and create a closure that expects more arguments, by replacing each term * by a formal parameter. So * * 5 + * is equivalent to -> $a, $b { $a * 5 + $b } .
  my $c = * * 5 + *;
  say $c(10, 2);                # 52

Note that the second * is an infix operator, not a term, so it is not subject to Whatever-currying.

The process of lifting an expression with Whatever stars into a closure is driven by syntax, and done at compile time. This means that
  my $star = *;
  my $code = $star + 2

does not construct a closure, but instead dies with a message like
  Can't take numeric value for object of type Whatever

Whatever currying is more versatile than .assuming , because it allows to curry something else than the first argument very easily:
  say  ~(1, 3).map: 'hi' x *    # hi hihihi

This curries the second argument of the string repetition operator infix x , so it returns a closure that, when called with a numeric argument, produces the string hi as often as that argument specifies.

The invocant of a method call can also be Whatever star, so
  say <a b c>.map: *.uc;      # ABC

involves a closure that calls the uc method on its argument. MOTIVATION

Perl 5 could be used for functional programming, which has been demonstrated in Mark Jason Dominus' book Higher Order Perl .

Perl 6 strives to make it even easier, and thus provides tools to make typical constructs in functional programming easily available. Currying and easy construction of closures is a key to functional programming, and makes it very easy to write transformation for your data, for example together with map or grep .  
